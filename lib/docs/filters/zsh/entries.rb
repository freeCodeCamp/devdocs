module Docs
  class Zsh
    class EntriesFilter < Docs::EntriesFilter
      def get_name
        extract_header_text(at_css('h1.chapter').content)
      end

      def additional_entries
        entries = []
        used_fns = []
        
        css('h2.section').each do |node|
          type = get_type
          # Linkable anchor sits above <h2>.
          a = node.xpath('preceding-sibling::a').last
          header_text = extract_header_text(node.content)

          case type
          when 'Zsh Modules'
            module_name = header_text.match(/The (zsh\/.* Module)/)&.captures&.first
            header_text = module_name if module_name.present?
          when 'Calendar Function System'
            header_text << ' (Calendar)'
          end

          entries << [header_text, a['name'], type] unless header_text.start_with?('Description')
        end

        # Functions are documented within <dl> elements.
        # Names are wrapped in <dt>, details within <dd>.
        # <dd> can also contain anchors for the next function.
        doc.css('> dl').each do |node|
          type = get_type
          fn_names = node.css('> dt')
          node.css('dd a[name]').each_with_index do |anchor, i|
            if fn_names[i].present? && anchor['name'].present?
              fn_names[i]['id'] = anchor['name']

              # Groups of functions are sometimes comma-delimited.
              # Strip arguments, flags, etc. from function name.
              # Skip flag-only headers.
              fn_names[i].inner_html.split(', ').each do |fn|
                fn.gsub!(/<(?:tt|var)>(.+?)<\/(?:tt|var)>/, '\1')
                fn = fn.split(' ').first
                fn.gsub!(/(?:[\[\(]).*(?:[\]\)]).*$/, '')

                # Add context for operators.
                fn << " (#{type})" if fn.length == 1

                if fn.present? && !fn.match?(/^[\-\[]/) && !used_fns.include?(fn)
                  used_fns << fn
                  entries << [fn, anchor['name'], type]
                end
              end
            end
          end
        end

        entries
      end

      def get_type
        extract_header_text(at_css('h1.chapter').content)
      end

      private

      # Extracts text from a string, dropping indices preceding it.
      def extract_header_text(str)
        str.match(/^[\d\.]* (.*)$/)&.captures&.first
      end
    end
  end
end
