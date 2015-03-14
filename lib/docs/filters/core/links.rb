module Docs
  class LinksFilter < Filter
    def call
      html.prepend(links_html) if root_page? && links
      html
    end

    NAMES = {
      home: 'Homepage',
      code: 'Source code'
    }

    def links_html
      links = self.links.map do |name, link|
        %(<li><a href="#{link}" class="_toc-link">#{NAMES[name]}</a></li>)
      end

      <<-HTML.strip_heredoc
      <div class="_toc">
        <div class="_toc-title">Resources</div>
        <ul class="_toc-list">#{links.join}</ul>
      </div>
      HTML
    end
  end
end
