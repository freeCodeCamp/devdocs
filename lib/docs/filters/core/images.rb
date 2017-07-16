# frozen_string_literal: true

module Docs
  class ImagesFilter < Filter
    include Instrumentable

    def self.optimize_image_data(data)
      @image_optim ||= ImageOptim.new
      @image_optim.optimize_image_data(data)
    end

    def call
      return doc if context[:download_images] == false

      @@cache ||= {}

      doc.css('img[src]').each do |node|
        src = node['src']

        if @@cache.key?(src)
          node['src'] = @@cache[src] unless @@cache[src] == false
          next
        end

        @@cache[src] = false

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

            image = response.body

            unless context[:optimize_images] == false
              image = self.class.optimize_image_data(image) || image
            end

            size = image.bytesize

            if size > max_size
              instrument 'too_big.image', url: url, size: size
              next
            end

            image = Base64.strict_encode64(image)
            image.prepend "data:#{response.mime_type};base64,"
            node['src'] = @@cache[src] = image
          end
        rescue => exception
          instrument 'error.image', url: url, exception: exception
        end
      end

      doc
    end

    private

    def max_size
      @max_size ||= context[:max_image_size] || 100.kilobytes
    end
  end
end
