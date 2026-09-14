module Docs
  class FileScraper < Scraper
    SOURCE_DIRECTORY = File.expand_path '../../../../../docs', __FILE__

    Response = Struct.new :body, :url

    class << self
      def inherited(subclass)
        super
        subclass.base_url = base_url
      end
    end

    self.base_url = 'http://localhost/'

    html_filters.push 'clean_local_urls'

    def source_directory
      @source_directory ||= File.join(SOURCE_DIRECTORY, self.class.path)
    end

    # Parses the pages in forked workers when Docs.jobs is greater than one.
    # Threads wouldn't help: the filters spend their time inside Nokogiri,
    # which holds on to the GVL. The pages are independent, so each worker
    # parses the ones it's given and sends the results back to this process,
    # which remains the only one writing to the store.
    def build_pages(&block)
      jobs = Docs.jobs.to_i
      return super if jobs < 2 || !Process.respond_to?(:fork)

      assert_source_directory_exists
      build_pages_in_parallel(jobs, &block)
    end

    private

    def build_pages_in_parallel(jobs)
      history = Set.new initial_urls.map(&:downcase)
      queue = initial_urls.dup # urls waiting for a worker
      order = initial_urls.dup # urls in the order their pages are yielded
      results = {}
      yielded = 0

      instrument 'running.scraper', urls: initial_urls

      workers = spawn_workers(jobs)
      idle = workers.dup
      busy = {}

      until queue.empty? && busy.empty?
        while queue.any? && idle.any?
          worker = idle.shift
          url = queue.shift
          busy[worker[:results]] = [worker, url]
          Marshal.dump(url, worker[:requests])
          worker[:requests].flush
        end

        IO.select(busy.keys).first.each do |io|
          worker, url = busy.delete(io)
          idle.push worker
          results[url] = receive_page(io, url)
        end

        # Yield the pages in the order their urls were discovered and queue the
        # links they contain at that point, so that the documentation doesn't
        # depend on the order in which the workers happen to finish.
        while yielded < order.length && results.key?(order[yielded])
          url = order[yielded]
          yielded += 1
          next unless data = results.delete(url)
          yield data
          next unless data[:internal_urls].present?
          next_urls = data[:internal_urls].select { |next_url| history.add?(next_url.downcase) }
          next if next_urls.empty?
          instrument 'queued.scraper', urls: next_urls
          queue.concat(next_urls)
          order.concat(next_urls)
        end
      end
    ensure
      stop_workers(Array(workers))
    end

    def spawn_workers(jobs)
      workers = []
      jobs.times { workers << spawn_worker(workers) }
      workers
    end

    def spawn_worker(spawned)
      requests_reader, requests_writer = IO.pipe
      results_reader, results_writer = IO.pipe

      pid = fork do
        requests_writer.close
        results_reader.close
        # Close the pipes of the workers spawned before this one, otherwise they
        # keep a copy of the write end of their own request pipe open and never
        # see it being closed.
        spawned.each do |worker|
          worker[:requests].close
          worker[:results].close
        end
        work(requests_reader, results_writer)
        exit! 0
      end

      requests_reader.close
      results_writer.close

      { pid: pid, requests: requests_writer, results: results_reader }
    end

    def stop_workers(workers)
      # Close every pipe before reaping: the workers stop when their request
      # pipe is closed, and the ones writing a result get an EPIPE.
      workers.each do |worker|
        worker[:requests].close unless worker[:requests].closed?
        worker[:results].close unless worker[:results].closed?
      end

      workers.each do |worker|
        Process.waitpid(worker[:pid])
      rescue Errno::ECHILD
        nil
      end
    end

    # Runs in a forked worker.
    def work(requests, results)
      # The parent process does the reporting; the subscribers inherited from
      # it would write to the same terminal, each with its own progress bar.
      ActiveSupport::Notifications.notifier = ActiveSupport::Notifications::Fanout.new
      Docs.rescue_errors = false

      loop do
        url = begin
          Marshal.load(requests)
        rescue EOFError
          break
        end

        page = begin
          [:page, handle_response(request_one(url))]
        rescue => e
          [:error, e.class.name, e.message, e.backtrace]
        end

        begin
          Marshal.dump(page, results)
          results.flush
        rescue Errno::EPIPE, IOError
          break
        end
      end
    end

    def receive_page(io, url)
      type, *payload = begin
        Marshal.load(io)
      rescue EOFError
        raise "The worker parsing #{url} died"
      end

      if type == :error
        error = worker_error(*payload)
        raise error unless Docs.rescue_errors
        instrument 'error.doc', exception: error, url: url
        payload = [nil]
      end

      data = payload.first
      instrument data ? 'process_response.scraper' : 'ignore_response.scraper',
                 response: Response.new(nil, url)
      data
    end

    # Exceptions don't always survive Marshal, so the workers send their class
    # name, message and backtrace instead.
    def worker_error(name, message, backtrace)
      error = begin
        klass = name.constantize
        klass.new(message) if klass.is_a?(Class) && klass <= Exception
      rescue StandardError
        nil
      end

      error ||= RuntimeError.new("#{name}: #{message}")
      error.set_backtrace(backtrace)
      error
    end

    # Override in a scraper to fetch the original documentation files into
    # #source_directory when they're missing, usually by calling
    # #download_and_extract. See Docs::Dart for an example.
    def download_source
      false
    end

    # Downloads an archive and moves it into #source_directory. Pass the
    # subdirectory holding the documents when they aren't at the archive's root,
    # and a destination to unpack somewhere else than #source_directory. Note
    # that the destination is replaced, so the one holding the documents has to
    # be unpacked before those nested inside it.
    def download_and_extract(url, subdirectory = nil, destination: source_directory)
      instrument 'info.doc', msg: %(Downloading #{url}...)
      archive = Archive.download(url)

      instrument 'info.doc', msg: %(Extracting the documentation files to "#{destination}"...)
      Archive.unpack(archive, destination, directory: subdirectory)
    ensure
      FileUtils.rm_f(archive) if archive
    end

    def assert_source_directory_exists
      return if Dir.exist?(source_directory)

      download_source
      return if Dir.exist?(source_directory)

      raise SetupError, "The #{self.class.name} scraper requires the original documentation files to be stored in the \"#{source_directory}\" directory."
    end

    def request_one(url)
      assert_source_directory_exists
      Response.new read_file(File.join(source_directory, url_to_path(url))), URL.parse(url)
    end

    def request_all(urls)
      assert_source_directory_exists
      queue = [urls].flatten
      until queue.empty?
        result = yield request_one(queue.shift)
        queue.concat(result) if result.is_a? Array
      end
    end

    def process_response?(response)
      response.body.present?
    end

    def url_to_path(url)
      url.remove(base_url.to_s)
    end

    def read_file(path)
      File.read(path)
    rescue
      instrument 'warn.doc', msg: "Failed to open file: #{path}"
      nil
    end
  end
end
