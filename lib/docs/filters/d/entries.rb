module Docs
  class D
    class EntriesFilter < Docs::EntriesFilter
      def get_name
        name = at_css('h1').content

        if base_url.path == '/spec/'
          index = css('.subnav li a').to_a.index(at_css(".subnav li a[href='#{result[:path]}']")) + 1
          name.prepend "#{index}. "
        end

        name
      end

      def get_type
        return 'Reference' if base_url.path == '/spec/'

        if name.start_with?('etc') || name.start_with?('core.stdc.')
          name.split('.')[0..2].join('.')
        elsif name.start_with?('ddmd')
          'ddmd'
        elsif name.start_with?('rt')
          'rt'
        else
          name.split('.')[0..1].join('.')
        end
      end

      def additional_entries
        return [] if root_page? || base_url.path == '/spec/'

        entries = []

        if entries.empty?
          css('.quickindex[id]').each do |node|
            name = node['id'].remove(/quickindex\.?/)
            next if name.empty? || name =~ /\.\d+\z/ || name =~ /\A([^\.]+)\.\1\z/
            entries << ["#{self.name}.#{name}", name]
          end
        end

        entries
      end
    end
  end
end
