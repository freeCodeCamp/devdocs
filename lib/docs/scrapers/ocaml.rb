module Docs
  class Ocaml < FileScraper
    self.name = 'OCaml'
    self.type = 'ocaml'
    self.root_path = 'index.html'
    self.links = {
      home: 'https://ocaml.org/',
      code: 'https://github.com/ocaml/ocaml'
    }

    html_filters.push 'ocaml/entries', 'ocaml/clean_html'

    options[:skip] = %w(
      libref/index.html
    )

    options[:skip_patterns] = [
      /\Acompilerlibref\//,
      /\Alibref\/type_/,
      /\Alibref\/Stdlib\.\w+\.html/,
    ]

    options[:attribution] = <<-HTML
      &copy; 1995-2022 INRIA.
    HTML

    version '' do
      self.release = '5.0'
      self.base_url = "https://v2.ocaml.org/releases/#{self.release}/htmlman/"
    end

    version '4.14' do
      self.release = '4.14'
      self.base_url = "https://v2.ocaml.org/releases/#{self.release}/htmlman/"
    end

    def get_latest_version(opts)
      get_latest_github_release('ocaml', 'ocaml', opts)
    end

    private

    def parse(response) # Hook here because Nokogori removes whitespace from code fragments
      response.body.gsub! %r{<div\ class="pre([^"]*)"[^>]*>([\W\w]+?)</div>}, '<pre class="\1">\2</pre>'
      super
    end

  end
end
