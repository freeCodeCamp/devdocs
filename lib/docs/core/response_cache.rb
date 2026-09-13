require 'base64'
require 'fileutils'
require 'json'
require 'time'

module Docs
  # Stores the responses fetched by a scraper on the filesystem so that
  # subsequent runs are served from disk instead of hitting the network.
  #
  # Each scraper gets its own directory (tmp/cache/<slug>) in which every
  # response is stored as an HTTP Archive (HAR) entry:
  # http://www.softwareishard.com/blog/har-12-spec/
  #
  # An archive is a log of many entries; keeping one entry per file instead
  # means the cache stays incremental (a run that's interrupted keeps whatever
  # it fetched, and reading one page doesn't parse the whole archive), at the
  # cost of the files not being valid archives on their own.
  #
  # Run `thor docs:clean` to throw the cached responses away.
  class ResponseCache
    # Written to every cache directory, so that .clean can tell the scraper
    # caches apart from the other things living in tmp/cache (e.g. the assets
    # cache of the web app).
    MARKER_FILENAME = '.scraper_cache'

    EXTENSION = '.json'

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
      entry = JSON.parse File.read(path_for(request), encoding: Encoding::UTF_8)
      response = Typhoeus::Response.new(deserialize(entry))
      response.cached = true
      response
    rescue Errno::ENOENT
      nil
    rescue StandardError
      # Ignore (and overwrite) entries we can't make sense of.
      nil
    end

    # Stores the response of the given request.
    def set(request, response)
      return unless cache_response?(response)

      prepare
      file = path_for(request)
      temp = "#{file}.#{Process.pid}.tmp"
      File.binwrite temp, JSON.pretty_generate(serialize(request, response))
      File.rename temp, file
    end

    def path_for(request)
      File.join path, "#{request.cache_key}#{EXTENSION}"
    end

    private

    # Responses that aren't plain successes are left out, so that transient
    # failures don't stick around forever.
    def cache_response?(response)
      !response.mock && !response.cached? && response.code == 200
    end

    # Redirections are followed transparently, so an entry only ever holds the
    # last response of a chain. The url it ended up at doesn't fit anywhere in
    # the spec, hence the custom field; HAR reserves the underscore prefix for
    # those. Fields we don't collect are left at -1 or empty, as prescribed.
    def serialize(request, response)
      wait = (response.starttransfer_time.to_f * 1000).round
      receive = (response.total_time.to_f * 1000).round - wait

      { 'startedDateTime' => Time.now.utc.iso8601(3),
        'time' => wait + receive,
        'request' => {
          'method' => request.options.fetch(:method, :get).to_s.upcase,
          'url' => request.base_url.to_s,
          'httpVersion' => '',
          'cookies' => [],
          'headers' => name_value_pairs(request.options[:headers]),
          'queryString' => name_value_pairs(request.options[:params]),
          'headersSize' => -1,
          'bodySize' => 0 },
        'response' => {
          'status' => response.code,
          'statusText' => response.status_message.to_s,
          'httpVersion' => response.http_version ? "HTTP/#{response.http_version}" : '',
          'cookies' => [],
          'headers' => name_value_pairs(response.headers),
          'content' => content(response),
          'redirectURL' => '',
          'headersSize' => -1,
          'bodySize' => response.body.to_s.bytesize },
        'cache' => {},
        'timings' => { 'send' => -1, 'wait' => wait, 'receive' => receive },
        '_effectiveUrl' => response.effective_url.to_s }
    end

    def deserialize(entry)
      response = entry['response']
      { code: response['status'],
        headers: header_hash(response['headers']),
        body: body(response['content']),
        effective_url: entry['_effectiveUrl'],
        return_code: :ok,
        total_time: entry['time'].to_f / 1000 }
    end

    def content(response)
      body = response.body.to_s
      text = body.dup.force_encoding(Encoding::UTF_8)
      result = { 'size' => body.bytesize,
                 'mimeType' => (response.headers || {})['Content-Type'].to_s }

      if text.valid_encoding?
        result['text'] = text
      else
        # The spec's way out for bodies that aren't valid JSON strings.
        result['text'] = Base64.strict_encode64(body)
        result['encoding'] = 'base64'
      end

      result
    end

    # Responses come off the wire as binary, and are handed back as such, so
    # that scrapers see the same thing whether or not the cache was used.
    def body(content)
      text = content['text'].to_s
      content['encoding'] == 'base64' ? Base64.strict_decode64(text) : text.b
    end

    def name_value_pairs(hash)
      (hash || {}).flat_map do |name, value|
        Array(value).map { |value| { 'name' => name.to_s, 'value' => value.to_s } }
      end
    end

    def header_hash(pairs)
      (pairs || []).each_with_object({}) do |pair, hash|
        name, value = pair['name'], pair['value']
        hash[name] = hash.key?(name) ? Array(hash[name]) << value : value
      end
    end

    def prepare
      return if @prepared
      FileUtils.mkdir_p path
      FileUtils.touch File.join(path, MARKER_FILENAME)
      @prepared = true
    end
  end
end
