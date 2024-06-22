module Docs
  class Perl
    class CleanHtmlFilter < Filter
      def call
        css('h1, h2, h3, h4').each do |node|
          node.name = node.name.sub(/\d/) { |i| i.to_i + 1 }
        end

        css('pre > code').each do |node|
          node.parent['data-language'] = 'perl'
          node.content = node.content
        end

        css('dl > dt').each do |node|
          case slug
          when 'perlfunc'
            node['class'] = 'function'
          when 'perlvar'
            node['class'] = 'variable'
          end
        end

        doc
      end
    end
  end
end
