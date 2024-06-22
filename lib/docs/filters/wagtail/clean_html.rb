module Docs
  class Wagtail
    class CleanHtmlFilter < Filter
      def call
        @doc = at_css('main > section', 'main')

        # footer contains links like about,contact us etc which
        # are not needed in documentation so removed
        doc.search('footer').each do |footer|
          footer.remove
        end

        # aside bar contains the search bar and navigation links
        # which are not needed
        doc.search('aside').each do |aside|
          aside.remove
        end

        # header contains links which are not needed(see sourch code of Wagtail docs)
        doc.search('header').each do |head|
          head.remove
        end

        # nav bar contains the search bar and navigation links(older versions)
        # which are not needed
        doc.search('nav.wy-nav-side').each do |nav|
          nav.remove
        end

        # removing unimportant links(older versions)
        doc.search('nav.wy-nav-top').each do |nav|
          nav.remove
        end

        # removing unimportant links from header of very old versions
        doc.search('ul.wy-breadcrumbs').each do |ul|
          ul.remove
        end

        # removing release notes
        doc.search('li.toctree-l1').each do |li|
          li.remove if li.to_s.include? 'Release notes'
        end

        # removing release notes(older versions)
        doc.search('dl').each do |dl|
          dl.remove
        end

        # removing scripts and style
        css('script', 'style', 'link').remove
        css('hr').remove
        # Make proper table headers
        css('td.header').each do |node|
          node.name = 'th'
        end

        # Remove code highlighting
        css('pre').each do |node|
          node.content = node.content
        end

        doc
      end
    end
  end
end
