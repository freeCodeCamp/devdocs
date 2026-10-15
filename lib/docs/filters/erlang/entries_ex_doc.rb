module Docs
  class Erlang
    class EntriesExDocFilter < Docs::EntriesFilter
      def get_name
        if module_page?
          at_css('.top-heading h1 > span').content.strip
        elsif app
          "#{title} (#{app})"
        else
          title
        end
      end

      def get_type
        if app.nil?
          group = context[:system_groups][File.basename(subpath, '.html')]
          group.present? ? "Guide: #{group}" : 'Guides'
        elsif module_page? && %w(erts stdlib).include?(app) && entry_nodes.length >= 10
          "#{app}/#{name}"
        else
          app
        end
      end

      def additional_entries
        return [] unless module_page?

        entry_nodes.map do |node|
          id = node['id']
          name = id.sub(/\A[tc]:/, '')
          name.prepend "#{self.name}:"
          name << ' (type)' if id.start_with?('t:')
          name << ' (callback)' if id.start_with?('c:')
          [name, id]
        end
      end

      def entry_nodes
        @entry_nodes ||= css('section.detail[id]')
      end

      def title
        at_css('.top-heading h1').content.strip.gsub(/\s+/, ' ')
      end

      def module_page?
        at_css('.top-heading h1 > small.app-vsn').present?
      end

      def app
        subpath[/\Alib\/([^\/]+)-[^\/-]+\//, 1] || ('erts' if subpath.start_with?('erts-'))
      end
    end
  end
end
