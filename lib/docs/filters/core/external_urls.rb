# frozen_string_literal: true

module Docs
  class ExternalUrlsFilter < Filter

    def call
      if context[:external_urls]

        css('a').each do |node|

          next unless anchorUrl = node['href']

          # avoid links already converted to internal links
          next if anchorUrl.match?(/\.\./)

          if context[:external_urls].is_a?(Proc)
            node['href'] = context[:external_urls].call(anchorUrl)
            next
          end

          url = URI(anchorUrl)

          context[:external_urls].each do |host, name|
            if url.host.to_s.match?(host)
              node['href'] = '/' + name + url.path.to_s + '#' + url.fragment.to_s
            end
          end

        end
      end

      doc
    end

  end
end
