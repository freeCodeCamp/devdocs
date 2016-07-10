module Docs
  class Erlang
    class PreCleanHtmlFilter < Filter
      def call
        css('.flipMenu li[title] > a').remove unless subpath.start_with?('erts') # perf

        css('.REFTYPES').each do |node|
          node.name = 'pre'
        end

        css('span.bold_code', 'span.code').each do |node|
          node.name = 'code'
          node.inner_html = node.inner_html.strip.gsub(/\s+/, ' ')
        end

        doc
      end
    end
  end
end
