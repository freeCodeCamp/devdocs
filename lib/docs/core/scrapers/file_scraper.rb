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

    private

    def assert_source_directory_exists
      unless Dir.exist?(source_directory)
        raise SetupError, "The #{self.class.name} scraper requires the original documentation files to be stored in the \"#{source_directory}\" directory."
      end
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
