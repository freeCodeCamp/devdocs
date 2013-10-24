module Docs
  class FileScraper < Scraper
    Response = Struct.new :body, :url

    class << self
      attr_accessor :dir
    end

    private

    def request_one(url)
      Response.new read_file(file_path_for(url)), URL.parse(url)
    end

    def request_all(start_url)
      queue = [start_url]
      until queue.empty?
        result = yield request_one(queue.shift)
        queue.concat(result) if result.is_a? Array
      end
    end

    def process_response?(response)
      response.body.present?
    end

    def file_path_for(url)
      File.join self.class.dir, url.sub(base_url.to_s, '')
    end

    def read_file(path)
      File.read(path) rescue nil
    end
  end
end
