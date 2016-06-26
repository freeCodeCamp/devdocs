module Docs
  class Angular
    class EntriesFilter < Docs::EntriesFilter
      def get_name
        name = at_css('header.hero h1').content.strip
        name = name.split(':').first

        if mod
          if name == 'Testing'
            return "#{mod.capitalize} Testing"
          elsif name == 'Index' || name == 'Angular'
            return mod
          end
        end

        name << '()' if at_css('.status-badge').try(:content) == 'Function'
        name
      end

      def get_type
        if slug.start_with?('guide/')
          'Guide'
        elsif slug.start_with?('cookbook/')
          'Cookbook'
        elsif slug == 'glossary'
          'Guide'
        else
          type = at_css('.is-nav-title-selected').content.strip
          type.remove! ' Reference'
          type << ": #{mod}" if mod
          type
        end
      end

      INDEX = Set.new

      def include_default_entry?
        INDEX.add?([name, type].join(';')) ? true : false # ¯\_(ツ)_/¯
      end

      private

      def mod
        @mod ||= slug[/api\/([\w\-]+)\//, 1]
      end
    end
  end
end
