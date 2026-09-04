module Docs
  class EsToolkit < FileScraper
    self.name = "es-toolkit"
    self.slug = "es_toolkit"
    self.type = "simple"
    self.links = {
      code: "https://github.com/toss/es-toolkit",
      home: "https://es-toolkit.dev",
    }
    self.release = '1.52.0'

    options[:attribution] = <<-HTML
      &copy; 2024-2026, Viva Republica<br>
      Licensed under the MIT License.
    HTML

    def get_latest_version(opts)
      get_github_tags("toss", "es-toolkit", opts).first["name"][1..]
    end

    # The reference lives under docs/reference for the main entry points and
    # under docs/<namespace>/reference for the secondary ones. Translations
    # (docs/ja, docs/ko, docs/zh_hans) are deliberately left out.
    NAMESPACES = %w[compat fp iterator server types]

    # Namespaces whose capitalized name isn't just #capitalize.
    NAMESPACE_NAMES = {"fp" => "FP"}

    def build_pages(&block)
      internal("docs/intro.md", path: "index", &block)
      Dir.chdir(source_directory) do
        Dir["docs/reference/**/*.md", *NAMESPACES.map { "docs/#{_1}/reference/**/*.md" }]
      end.each { internal(_1, &block) }
    end

    protected

    def internal(filename, path: nil, &block)
      # docs/reference/array/chunk.md         => array/chunk
      # docs/compat/reference/array/chunk.md  => compat/array/chunk
      # docs/fp/reference/chunk.md            => fp/chunk
      path ||= filename.sub(%r{\Adocs/}, "").sub("reference/", "").sub(/\.md\z/, "")

      # calculate name/type
      if path != "index"
        name = File.basename(path)
        type = path.split("/")[0..-2]
        type = type.map { NAMESPACE_NAMES[_1] || _1.capitalize }.join(" ")
        # really bad way to sort: keep the main reference on top
        type = type.gsub(/^(Compat|Error|FP|Iterator|Server|Types)\b/, "\u2063\\1") #  U+2063 INVISIBLE SEPARATOR
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

    private

    def download_source
      # The archive expands to a single directory named after the release.
      download_and_extract("https://github.com/toss/es-toolkit/archive/refs/tags/v#{self.class.release}.tar.gz",
                           "es-toolkit-#{self.class.release}")
    end
  end
end
