module Docs
  class Angular
    class EntriesV2Filter < Docs::EntriesFilter
      def get_name
        if slug.start_with?('tutorial') || slug.start_with?('guide')
          name = at_css('.nav-list-item.is-selected, header.hero h1').content.strip
        else
          name = at_css('header.hero h1').content.strip
        end

        name = name.split(':').first

        if mod
          if name == 'Index'
            return slug.split('/')[1..-2].join('/')
          elsif name == 'Angular'
            return slug.split('/').last.split('-').first
          end
        end

        subtitle = at_css('.hero-subtitle').try(:content)
        breadcrumbs = css('.breadcrumbs li').map(&:content)[2..-2]

        name.prepend "#{breadcrumbs.join('.')}#" if breadcrumbs.present? && breadcrumbs[0] != name
        name << '()' if %w(Function Method Constructor).include?(subtitle)
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
          type = at_css('.nav-title.is-selected').content.strip
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
        return @mod if defined?(@mod)
        @mod = slug[/api\/([\w\-\.]+)\//, 1]
        @mod.remove! 'angular2.' if @mod
        @mod
      end
    end
  end
end
