# frozen_string_literal: true

require 'base64'
require 'image_optim'

module Docs
  class ImagesFilter < Filter
    include Instrumentable

    DEFAULT_MAX_SIZE = 120_000 # 120 kilobytes

    PNG_SIGNATURE = "\x89PNG\r\n\x1a\n".b
    CWEBP_COMMAND = %w(cwebp -quiet -lossless -z 9 -m 6 -metadata none -o - -- -).freeze

    def self.optimize_image_data(data)
      @image_optim ||= ImageOptim.new
      @image_optim.optimize_image_data(data)
    end

    # Losslessly re-encodes a PNG as WebP, which is usually 10-50% smaller.
    # Returns nil when the data isn't a PNG we can convert, when cwebp isn't
    # available, or when the result would be bigger than the original.
    def self.convert_to_webp(data)
      return unless png?(data)
      webp = IO.popen(CWEBP_COMMAND, 'r+b', err: File::NULL) do |io|
        io.write(data)
        io.close_write
        io.read
      end
      webp if $?.success? && !webp.empty? && webp.bytesize < data.bytesize
    rescue SystemCallError
      nil
    end

    def self.png?(data)
      return false unless data.byteslice(0, PNG_SIGNATURE.bytesize)&.b == PNG_SIGNATURE
      # cwebp silently keeps the first frame of an animated PNG
      idat = data.index('IDAT'.b)
      idat.nil? || !data.byteslice(0, idat).include?('acTL'.b)
    end

    def self.cache
      @cache ||= {}
    end

    def call
      return doc if context[:download_images] == false

      doc.css('img[src]').each do |node|
        src = node['src']

        if self.class.cache.key?(src)
          node['src'] = self.class.cache[src] unless self.class.cache[src] == false
          next
        end

        self.class.cache[src] = false

        next if src.start_with? 'data:image/'
        url = Docs::URL.parse(src)
        url.scheme = 'https' if url.scheme.nil?
        next unless url.scheme == 'http' || url.scheme == 'https'

        begin
          Request.run(url) do |response|
            unless response.success?
              instrument 'broken.image', url: url, status: response.code
              next
            end

            unless response.mime_type.start_with?('image/')
              instrument 'invalid.image', url: url, content_type: response.mime_type
              next
            end

            size = response.content_length

            if size > (context[:max_image_size] || DEFAULT_MAX_SIZE)
              instrument 'too_big.image', url: url, size: size
              next
            end

            image = response.body
            mime_type = response.mime_type

            unless context[:optimize_images] == false
              image = self.class.optimize_image_data(image) || image
            end

            if webp = self.class.convert_to_webp(image)
              image = webp
              mime_type = 'image/webp'
            end

            size = image.bytesize

            if size > (context[:max_image_size] || DEFAULT_MAX_SIZE)
              instrument 'too_big.image', url: url, size: size
              next
            end

            image = Base64.strict_encode64(image)
            image.prepend "data:#{mime_type};base64,"
            node['src'] = self.class.cache[src] = image
          end
        rescue => exception
          instrument 'error.image', url: url, exception: exception
        end
      end

      doc
    end
  end
end
