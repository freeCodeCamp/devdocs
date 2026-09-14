# frozen_string_literal: true

require 'base64'

module Docs
  class ImagesFilter < Filter
    include Instrumentable

    DEFAULT_MAX_SIZE = 120_000 # 120 kilobytes

    PNG_SIGNATURE = "\x89PNG\r\n\x1a\n".b
    GIF_SIGNATURES = ['GIF87a'.b, 'GIF89a'.b].freeze
    JPEG_SIGNATURE = "\xff\xd8\xff".b

    # WebP q=80 is roughly equivalent to JPEG q=90, and -sharp_yuv keeps the
    # edges of the screenshots and diagrams documentation is full of crisp.
    JPEG_QUALITY = 80

    CWEBP_LOSSLESS_COMMAND = %w(cwebp -quiet -lossless -z 9 -m 6 -metadata none -o - -- -).freeze
    CWEBP_LOSSY_COMMAND = %W(cwebp -quiet -q #{JPEG_QUALITY} -m 6 -sharp_yuv -metadata none -o - -- -).freeze
    GIF2WEBP_COMMAND = %w(gif2webp -quiet -m 6 -metadata none -o - -- -).freeze

    # image_optim belongs to the docs bundle group, which the app leaves out;
    # `Bundler.require :default, :docs` in docs.rb loads it for the scrapers,
    # which are the only ones optimizing anything.
    def self.optimize_image_data(data)
      @image_optim ||= ImageOptim.new
      @image_optim.optimize_image_data(data)
    end

    # Re-encodes a PNG or GIF as lossless WebP and a JPEG as lossy WebP, all of
    # which are usually smaller. Returns nil when the data isn't an image we can
    # convert, when the encoder isn't available, or when the result would be
    # bigger than the original.
    def self.convert_to_webp(data)
      command = webp_command(data)
      return unless command
      webp = IO.popen(command, 'r+b', err: File::NULL) do |io|
        io.write(data)
        io.close_write
        io.read
      end
      webp if $?.success? && !webp.empty? && webp.bytesize < data.bytesize
    rescue SystemCallError
      nil
    end

    def self.webp_command(data)
      if png?(data)
        CWEBP_LOSSLESS_COMMAND
      elsif gif?(data)
        # unlike cwebp, gif2webp keeps every frame of an animation
        GIF2WEBP_COMMAND
      elsif starts_with?(data, JPEG_SIGNATURE)
        CWEBP_LOSSY_COMMAND
      end
    end

    def self.png?(data)
      return false unless starts_with?(data, PNG_SIGNATURE)
      # cwebp silently keeps the first frame of an animated PNG
      idat = data.index('IDAT'.b)
      idat.nil? || !data.byteslice(0, idat).include?('acTL'.b)
    end

    def self.gif?(data)
      GIF_SIGNATURES.any? { |signature| starts_with?(data, signature) }
    end

    def self.starts_with?(data, signature)
      data.byteslice(0, signature.bytesize)&.b == signature
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
