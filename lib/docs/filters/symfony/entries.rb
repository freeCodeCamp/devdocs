module Docs
  class Symfony
    class EntriesFilter < Docs::EntriesFilter
      def get_name
        name = at_css('h1').content.strip
        name.remove! 'Symfony\\'
        name << " (#{namespace})" if name.gsub! "#{namespace}\\", ''
        name
      end

      def get_type
        return 'Exceptions' if slug =~ /exception/i
        return 'Testing' if slug =~ /test/i
        namespace
      end

      def namespace
        @namespace ||= begin
          path = slug.remove('Symfony/').remove(/\/\w+?\z/).split('/')
          upto = 1
          upto = 2 if path[1] == 'Form' && path[2] == 'Extension'
          upto = 2 if path[1] == 'HttpFoundation' && path[2] == 'Session'
          path[0..upto].join('\\')
        end
      end

      IGNORE_METHODS = %w(get set)

      def additional_entries
        return [] if initial_page?
        return [] if type == 'Exceptions'
        return [] if self.name.include?('Legacy') || self.name.include?('Loader')

        entries = []
        base_name = self.name.remove(/\(.+\)/).strip

        css('h3[id^="method_"]').each do |node|
          next if node.at_css('.location').content.start_with?('in')

          name = node['id'].remove('method_')
          next if name.start_with?('_') || IGNORE_METHODS.include?(name)

          name.prepend "#{base_name}::"
          name << "() (#{namespace})"

          entries << [name, node['id']]
        end

        entries.size > 1 ? entries : []
      end

      def include_default_entry?
        !initial_page?
      end
    end
  end
end
