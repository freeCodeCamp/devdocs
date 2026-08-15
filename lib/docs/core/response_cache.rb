require 'fileutils'

module Docs
  # Stores the responses fetched by a scraper on the filesystem so that
  # subsequent runs are served from disk instead of hitting the network.
  #
  # Each scraper gets its own directory (tmp/cache/<slug>) in which every
  # response is stored under the request's cache key. Run `thor docs:clean`
  # to throw the cached responses away and fetch everything anew.
  class ResponseCache
    # Written to every cache directory, so that .clean can tell the scraper
    # caches apart from the other things living in tmp/cache (e.g. the assets
    # cache of the web app).
    MARKER_FILENAME = '.scraper_cache'

    # Deletes the cache directory of every scraper.
    def self.clean
      Dir[File.join(Docs.cache_path, '*', MARKER_FILENAME)].each do |marker|
        FileUtils.rm_rf File.dirname(marker)
      end
    end

    attr_reader :path

    def initialize(path)
      @path = path
    end

    # Returns the response stored for the given request, or nil.
    def get(request)
      response = Typhoeus::Response.new(Marshal.load(File.binread(path_for(request))))
      response.cached = true
      response
    rescue Errno::ENOENT
      nil
    rescue StandardError, TypeError, ArgumentError
      # Ignore (and overwrite) entries written by an older version.
      nil
    end

    # Stores the response of the given request.
    def set(request, response)
      return unless cache_response?(response)

      prepare
      file = path_for(request)
      temp = "#{file}.#{Process.pid}.tmp"
      File.binwrite temp, Marshal.dump(serialize(request, response))
      File.rename temp, file
    end

    def path_for(request)
      File.join path, request.cache_key
    end

    private

    # Responses that aren't plain successes are left out, so that transient
    # failures don't stick around forever.
    def cache_response?(response)
      !response.mock && !response.cached? && response.code == 200
    end

    def serialize(request, response)
      { url: request.base_url.to_s,
        effective_url: response.effective_url.to_s,
        code: response.code,
        headers: response.headers.try(:to_h) || {},
        body: response.body,
        return_code: response.return_code,
        total_time: response.total_time }
    end

    def prepare
      return if @prepared
      FileUtils.mkdir_p path
      FileUtils.touch File.join(path, MARKER_FILENAME)
      @prepared = true
    end
  end
end
