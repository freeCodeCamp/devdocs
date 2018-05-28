module Docs
  class FileScraper < Scraper
    Response = Struct.new :body, :url

    class << self
      attr_accessor :dir

      def inherited(subclass)
        super
        subclass.base_url = base_url
        subclass.dir = dir
      end
    end

    self.base_url = 'http://localhost/'

    html_filters.push 'clean_local_urls'

    private

    def request_one(url)
      Response.new read_file(file_path_for(url)), URL.parse(url)
    end

    def request_all(urls)
      queue = [urls].flatten
      until queue.empty?
        result = yield request_one(queue.shift)
        queue.concat(result) if result.is_a? Array
      end
    end

    def process_response?(response)
      response.body.present?
    end

    def file_path_for(url)
      File.join self.class.dir, url.remove(base_url.to_s)
    end

    def read_file(path)
      File.read(path)
    rescue
      instrument 'warn.doc', msg: "Failed to open file: #{path}"
      nil
    end
  end
end
