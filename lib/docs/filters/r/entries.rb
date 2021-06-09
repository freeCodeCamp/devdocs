module Docs
  class R
    class EntriesFilter < Docs::EntriesFilter

      PKG_INDEX_ENTRIES = Hash.new []

      def call
        if slug_parts[-1] == '00Index'
          dir = File.dirname(result[:subpath])
          css('tr a').each do |link|
            PKG_INDEX_ENTRIES[link['href']] += [link.text]
            next if link['href'] == link.text
            context[:replace_paths][File.join(dir, "#{link.text}.html")] = File.join(dir, "#{link['href']}.html")
          end
        end

        super
      end

      def slug_parts
        slug.split('/')
      end

      def is_package?
        slug_parts[0] == 'library'
      end

      def is_manual?
        slug_parts[1] == 'manual'
      end

      def get_name
        return at_css('h2').content if is_package?
        title = at_css('h1.settitle')
        title ? title.content : at_css('h1, h2').content
      end

      def get_type
        return slug_parts[1] if is_package?
        return at_css('h1.settitle').content if is_manual?
      end

      def include_default_entry?
        is_package? and not slug_parts[-1] == '00Index'
      end

      def manual_section(node)
        title = node.content.sub /^((Appendix )?[A-Z]|[0-9]+)(\.[0-9]+)* /, ''
        title unless ['References', 'Preface', 'Acknowledgements'].include?(title) or title.end_with?(' index')
      end

      def additional_entries
        if is_package? and slug_parts[-1] != '00Index'
          page = slug_parts[-1]
          return [page] + PKG_INDEX_ENTRIES.fetch(page, [])
        end

        return [] unless is_manual?

        entries = []
        unless slug_parts[-1].downcase == 'r-intro'
          # Single top-level category
          css('div.contents > ul a').each do |link|
            link_name = manual_section(link)
            entries << [link_name, link['href'].split('#')[1], name] unless link_name.nil?
          end
        else
          # Split 1st level of manual into different categories
          css('div.contents > ul > li').each do |node|
            type = manual_section(node.at_css('a'))
            next if type.nil?
            node.css('> ul a').each do |link|
              link_name = link.content.sub /^[0-9A-Z]+(\.[0-9]+)* /, ''
              entries << [link_name, link['href'].split('#')[1], type]
            end
          end
        end
        return entries
      end

      private
    end
  end
end
