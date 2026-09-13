module Docs
  class Cyclejs < UrlScraper
    self.name = 'Cycle.js'
    self.slug = 'cyclejs'
    self.type = 'cyclejs'
    self.release = '23.1.0'
    self.base_url = 'https://cycle.js.org/'
    self.root_path = 'index.html'
    self.initial_paths = %w(
      getting-started.html
      model-view-intent.html
      streams.html
      drivers.html
      components.html
      basic-examples.html
      dialogue.html
      releases.html
      api/index.html
      api/run.html
      api/rxjs-run.html
      api/most-run.html
      api/dom.html
      api/html.html
      api/http.html
      api/history.html
      api/isolate.html
      api/state.html
    )

    self.links = {
      home: 'https://cycle.js.org/',
      code: 'https://github.com/cyclejs/cyclejs'
    }

    html_filters.push 'cyclejs/clean_html', 'cyclejs/entries'

    options[:only_patterns] = [
      /\Aindex\.html\z/,
      /\Agetting-started\.html\z/,
      /\Amodel-view-intent\.html\z/,
      /\Astreams\.html\z/,
      /\Adrivers\.html\z/,
      /\Acomponents\.html\z/,
      /\Abasic-examples\.html\z/,
      /\Adialogue\.html\z/,
      /\Areleases\.html\z/,
      /\Aapi\//
    ]

    options[:download_images] = false
    options[:attribution] = <<-HTML
      &copy; 2014&ndash;present Cycle.js contributors.<br>
      Licensed under the MIT License.
    HTML

    def get_latest_version(opts)
      get_npm_version('@cycle/dom', opts)
    end

    private

    def parse(response)
      document = Parser.new(response.body).html
      markdown = document.at_css('script#markdown')

      return super unless markdown

      html = markdown_renderer.render(markdown.content.strip)
      title = document.at_css('title').try(:content).try(:strip)
      [Parser.new("<html><head><title>#{title}</title></head><body>#{html}</body></html>").html, title]
    end

    def markdown_renderer
      require 'redcarpet'
      @markdown_renderer ||= Redcarpet::Markdown.new(
        Redcarpet::Render::HTML.new(with_toc_data: true),
        autolink: true,
        fenced_code_blocks: true,
        no_intra_emphasis: true,
        tables: true
      )
    end
  end
end
