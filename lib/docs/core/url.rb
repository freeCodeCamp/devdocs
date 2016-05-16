require 'uri'
require 'pathname'

module Docs
  class URL < URI::Generic
    PARSER = URI::Parser.new

    def initialize(*args)
      if args.empty?
        super(*Array.new(9))
      elsif args.length == 1 && args.first.is_a?(Hash)
        args.first.assert_valid_keys URI::Generic::COMPONENT
        super(*args.first.values_at(*URI::Generic::COMPONENT))
      else
        super
      end
    end

    def self.parse(url)
      return url if url.kind_of? self
      new(*PARSER.split(url), PARSER)
    end

    def self.join(*args)
      PARSER.join(*args)
    end

    def join(*args)
      self.class.join self, *args
    end

    def merge!(hash)
      return super unless hash.is_a? Hash
      hash.assert_valid_keys URI::Generic::COMPONENT
      hash.each_pair do |key, value|
        send "#{key}=", value
      end
      self
    end

    def merge(hash)
      return super unless hash.is_a? Hash
      dup.merge!(hash)
    end

    def origin
      if scheme && host
        origin = "#{scheme}://#{host}"
        origin.downcase!
        origin << ":#{port}" if port
        origin
      else
        nil
      end
    end

    def normalized_path
      path == '' ? '/' : path
    end

    def subpath_to(url, options = nil)
      url = self.class.parse(url)
      return unless origin == url.origin

      base = path
      dest = url.path

      if options && options[:ignore_case]
        base = base.downcase
        dest = dest.downcase
      end

      if base == dest
        ''
      elsif dest.start_with? File.join(base, '')
        url.path[(path.length)..-1]
      end
    end

    def subpath_from(url, options = nil)
      self.class.parse(url).subpath_to(self, options)
    end

    def contains?(url, options = nil)
      !!subpath_to(url, options)
    end

    def relative_path_to(url)
      url = self.class.parse(url)
      return unless origin == url.origin

      base_dir = Pathname.new(normalized_path)
      base_dir = base_dir.parent unless path.end_with? '/'

      dest = url.normalized_path
      dest_dir = Pathname.new(dest)

      if dest.end_with? '/'
        dest_dir.relative_path_from(base_dir).to_s.tap do |result|
          result << '/' if result != '.'
        end
      else
        dest_dir.parent.relative_path_from(base_dir).join(dest.split('/').last).to_s
      end
    end

    def relative_path_from(url)
      self.class.parse(url).relative_path_to(self)
    end
  end
end
