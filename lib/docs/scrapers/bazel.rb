module Docs
  class Bazel < FileScraper
    self.name = 'Bazel'
    self.type = 'bazel'
    self.root_path = 'overview'

    html_filters.push 'bazel/entries', 'bazel/clean_html'

    # Pages the documentation links to but that the Build Encyclopedia has
    # never held; the links are broken on bazel.build as well.
    options[:skip] = %w(platform precompiling workspace)

    options[:attribution] = <<-HTML
    Licensed under the Creative Commons Attribution 4.0 License, and code samples are licensed under the Apache 2.0 License.
    HTML

    # bazel.build only serves the releases bazel-contrib/bazel-docs holds (see
    # #download_source), and drops older ones as new ones come out: the latest
    # release of Bazel 6 was dropped when it reached its end of life, and the
    # documentation of every 6.x is gone from bazel.build along with it.
    version '9' do
      self.release = '9.1.0'
      self.base_url = "https://bazel.build/versions/#{release}/reference/be/"
    end

    version '8' do
      self.release = '8.7.0'
      self.base_url = "https://bazel.build/versions/#{release}/reference/be/"
    end

    version '7' do
      self.release = '7.7.1'
      self.base_url = "https://bazel.build/versions/#{release}/reference/be/"
    end

    # The releases GitHub reports are of no use here: bazel.build trails them by
    # a few weeks, and a version it doesn't document can't be scraped at all.
    def get_latest_version(opts)
      contents = fetch_json('https://api.github.com/repos/bazel-contrib/bazel-docs/contents/versions', opts)
      releases = contents.filter_map { |entry| entry['name'] if entry['type'] == 'dir' }
      releases.max_by { |name| name.split('.').map(&:to_i) }
    end

    private

    # The documents are Markdown with a YAML front matter, of which only the
    # title is of any use here.
    FRONT_MATTER_REGEXP = /\A---[ \t]*\r?\n.*?\r?\n---[ \t]*\r?\n/m
    TITLE_REGEXP = /^title:[ \t]*(?<title>.+?)[ \t]*$/

    def parse(response)
      body = response.body.dup.force_encoding(Encoding::UTF_8)
      front_matter = body.slice!(FRONT_MATTER_REGEXP).to_s
      title = front_matter[TITLE_REGEXP, :title].to_s.delete_prefix("'").delete_suffix("'")

      # Documentation pulled in from rules_python still holds Sphinx directives
      # ("{obj}`ctx.actions`"), whose braces the conversion of the documentation
      # to Markdown escaped as HTML entities. bazel.build shows them unescaped.
      body.gsub!('&lcub;', '{')
      body.gsub!('&rcub;', '}')

      # The title only appears in the front matter, whereas the entries filter
      # and the documentation itself expect the page to open with a heading.
      html = <<~HTML
        <html>
          <head><title>#{CGI.escape_html title}</title></head>
          <body><h1>#{CGI.escape_html title}</h1>#{markdown_renderer.render(body)}</body>
        </html>
      HTML

      [Parser.new(html).html, title]
    end

    # Redcarpet gives headings the anchors Mintlify gives them on bazel.build,
    # which is what the documentation links to.
    def markdown_renderer
      @markdown_renderer ||= Redcarpet::Markdown.new(
        Redcarpet::Render::HTML.new(with_toc_data: true),
        autolink: true,
        fenced_code_blocks: true,
        no_intra_emphasis: true,
        strikethrough: true,
        tables: true
      )
    end

    # bazel.build serves the pages under extensionless URLs, whereas they are
    # stored as one Markdown file each.
    def url_to_path(url)
      "#{super}.mdx"
    end

    def download_source
      require 'tmpdir'

      Dir.mktmpdir do |directory|
        repository = File.join(directory, 'bazel-docs')
        documents = "versions/#{self.class.release}/reference/be"

        instrument 'info.doc', msg: %(Cloning the Bazel #{self.class.release} documentation...)
        # The Build Encyclopedia is generated from Bazel's Java sources when
        # Bazel is built, so it is part of neither the bazelbuild/bazel
        # repository nor any release artifact. Its only published form is the
        # Markdown bazel.build is rendered from, of which this repository holds
        # every version; only the Build Encyclopedia of this one is checked out.
        system('git', 'clone', '--depth', '1', '--filter=blob:none', '--sparse',
               'https://github.com/bazel-contrib/bazel-docs', repository)
        system('git', '-C', repository, 'sparse-checkout', 'set', documents)

        instrument 'info.doc', msg: %(Moving the documentation files to "#{source_directory}"...)
        FileUtils.mkpath(File.dirname(source_directory))
        FileUtils.mv(File.join(repository, documents), source_directory)
      end
    end
  end
end
