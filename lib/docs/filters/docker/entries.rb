module Docs
  class Docker
    class EntriesFilter < Docs::EntriesFilter
      NAME_BY_SUBPATH = {
        'engine/' => 'Engine',
        'compose/' => 'Compose',
        'machine/' => 'Machine',
        'notary/' => 'Notary'
      }

      def get_name
        return NAME_BY_SUBPATH[subpath] if NAME_BY_SUBPATH[subpath]
        return at_css('h1').content unless nav_link

        name = nav_link.content.strip
        name.capitalize! if name == 'exoscale'
        name.remove! ' (base command)'

        if name =~ /\A[a-z\-\s]+\z/
          name.prepend 'docker-compose ' if subpath =~ /compose\/reference\/./
          name.prepend 'docker-machine ' if subpath =~ /machine\/reference\/./
        else
          name << " (#{product})" if name !~ /#{product}/i && !subpath.start_with?('get-started')
        end

        name
      end

      def get_type
        return NAME_BY_SUBPATH[subpath] if NAME_BY_SUBPATH[subpath]
        return 'Get Started'         if subpath.start_with?('get-started')
        return 'Engine: CLI'         if subpath.start_with?('engine/reference/commandline/')
        return 'Engine: Admin Guide' if subpath.start_with?('engine/admin/')
        return 'Engine: Security'    if subpath.start_with?('engine/security/')
        return 'Engine: Extend'      if subpath.start_with?('engine/extend/')
        return 'Engine: Tutorials'   if subpath.start_with?('engine/tutorials/')
        product
      end

      def nav_link
        return @nav_link if defined?(@nav_link)
        @nav_link = at_css('.currentPage')
      end

      def product
        @product ||= subpath.split('/').first.capitalize
      end
    end
  end
end
