module Docs
  class Docker
    class EntriesOldFilter < Docs::EntriesFilter
      NAME_BY_SUBPATH = {
        'engine/' => 'Engine',
        'compose/' => 'Compose',
        'machine/' => 'Machine'
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
          name << " (#{product})" if name !~ /#{product}/i
        end

        name
      end

      TYPE_BY_SUBPATH = {
        'engine/' => 'Engine',
        'compose/' => 'Compose',
        'machine/' => 'Machine'
      }

      def get_type
        return TYPE_BY_SUBPATH[subpath] if TYPE_BY_SUBPATH[subpath]
        return 'Engine: CLI'         if subpath.start_with?('engine/reference/commandline/')
        return 'Engine: Admin Guide' if subpath.start_with?('engine/admin/')
        return 'Engine: Security'    if subpath.start_with?('engine/security/')
        return 'Engine: Extend'      if subpath.start_with?('engine/extend/')
        return 'Engine: Get Started' if subpath.start_with?('engine/getstarted')
        return 'Engine: Tutorials'   if subpath.start_with?('engine/tutorials/')
        return product if !nav_link && subpath =~ /\A\w+\/[\w\-]+\/\z/

        leaves = nav_link.ancestors('li.leaf').reverse
        return product if leaves.length <= 2

        type = leaves[0..1].map { |node| node.at_css('> a').content.strip }.join(': ')
        type.remove! %r{\ADocker }
        type.remove! ' Engine'
        type.sub! %r{Command[\-\s]line reference}i, 'CLI'
        type.sub! 'CLI reference', 'CLI'
        type
      end

      def nav_link
        return @nav_link if defined?(@nav_link)
        @nav_link = at_css('.currentPage')

        unless @nav_link
          link = at_css('#DocumentationText li a')
          return unless link
          link = at_css(".docsidebarnav_section a[href='#{link['href']}']")
          return unless link
          @nav_link = link.ancestors('.menu-closed').first.at_css('a')
        end

        @nav_link
      end

      def product
        @product ||= subpath.split('/').first.capitalize
      end
    end
  end
end
