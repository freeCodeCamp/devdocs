module Docs
  class EsToolkit < FileScraper
    self.name = "es-toolkit"
    self.slug = "es_toolkit"
    self.type = "simple"
    self.links = {
      code: "https://github.com/toss/es-toolkit",
      home: "https://es-toolkit.slash.page",
    }

    options[:attribution] = <<-HTML
      &copy; 2024-2025, Viva Republica<br>
      Licensed under the MIT License.
    HTML

    def get_latest_version(opts)
      get_github_tags("toss", "es-toolkit", opts).first["name"]
    end

    def build_pages(&block)
      internal("docs/intro.md", path: "index", &block)
      Dir.chdir(source_directory) do
        Dir["docs/reference/**/*.md"]
      end.each { internal(_1, &block) }
    end

    protected

    def internal(filename, path: nil, &block)
      path ||= filename[%r{docs/reference/(.*/.*).md$}, 1]

      # calculate name/type
      if path != "index"
        name = filename[%r{([^/]+).md$}, 1]
        type = path.split("/")[0..-2]
        type = type.map(&:capitalize).join(" ")
        # really bad way to sort
        type = type.gsub(/^(Compat|Error)\b/, "\u2063\\1") #  U+2063 INVISIBLE SEPARATOR
      else
        name = type = nil
      end

      # now yield
      entries = [Entry.new(name, path, type)]
      output = render(filename)
      store_path = "#{path}.html"
      yield({entries:, output:, path:, store_path:})
    end

    # render/style HTML
    def render(filename)
      s = md.render(request_one(filename).body)

      # kill all links, they don't work
      s.gsub!(%r{<a href="[^"]+">(.*?)</a>}, "<span>\\1</span>")

      # syntax highlighting
      s.gsub!(%r{<pre><code class="typescript">}, "<pre data-language='typescript'><code class='typescript'>")

      # h3 => h4
      s.gsub!(%r{(</?h)3>}, "\\14>")

      # manually add attribution
      link = "#{self.class.links[:home]}#{filename.gsub(/^docs/,'').gsub(/md$/,'html')}"
      s += <<~HTML
        <div class="_attribution">
          <p class="_attribution-p">
            #{options[:attribution]}
            <br>
            <a href="#{link}" class="_attribution-link">
              #{link}
            </a>
          </p>
        </div>
      HTML
      s
    end

    def md
      @md ||= Redcarpet::Markdown.new(
        Redcarpet::Render::HTML,
        autolink: true,
        fenced_code_blocks: true,
        tables: true
      )
    end
  end
end
