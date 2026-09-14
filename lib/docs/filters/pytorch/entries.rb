module Docs
  class Pytorch
    class EntriesFilter < Docs::EntriesFilter
      def get_breadcrumbs
        breadcrumbs = schema_breadcrumbs
        return breadcrumbs unless breadcrumbs.empty?

        breadcrumbs = if at_css('.pytorch-breadcrumbs')
          css('.pytorch-breadcrumbs > li').map { |node|
            node.content.delete_suffix(' >').strip
          }
        else
          css('.bd-breadcrumbs > li').map { |node|
            text = node.content.strip
            text.empty? && node.at_css('.fa-home') ? 'Docs' : text
          }
        end.reject { |item| item.nil? || item.empty? }

        if breadcrumbs.last&.end_with?('.')
          resolved_name = at_css('h1').content.delete_suffix('#').strip
          breadcrumbs[-1] = resolved_name
        end

        breadcrumbs
      end

      def get_name
        get_breadcrumbs[-1]
      end

      def get_type
        breadcrumbs = get_breadcrumbs

        if schema_breadcrumbs.any?
          breadcrumbs.size > 2 ? breadcrumbs[-2] : breadcrumbs[-1]
        elsif at_css('.pytorch-breadcrumbs')
          breadcrumbs[1]
        else
          breadcrumbs.size > 2 ? breadcrumbs[2] : breadcrumbs[1]
        end
      end

      def include_default_entry?
        schema_breadcrumbs.any? || get_breadcrumbs.size >= 2
      end

      def additional_entries
        return [] if root_page?

        entries = []
        css('dl').each do |node|
          dt = node.at_css('dt')
          if dt == nil
            next
          end
          id = dt['id']
          if id == name or id == nil
            next
          end

          case node['class']
          when 'py method', 'py function'
            entries << [id + '()', id]
          when 'py class', 'py attribute', 'py property'
            entries << [id, id]
          end
        end

        entries
      end

      private

      def schema_breadcrumbs
        @schema_breadcrumbs ||= css(
          '[itemtype="https://schema.org/BreadcrumbList"] [itemprop="itemListElement"]'
        ).filter_map do |node|
          name = node.at_css('[itemprop="name"]')
          next unless name

          text = Nokogiri::HTML.fragment(name['content'] || name.content).text.strip
          dangling_text = node.text.strip.delete_suffix('">') if name['content']
          text = "#{text} #{dangling_text}" if dangling_text.present?
          text
        end.reject(&:empty?)
      end
    end
  end
end
