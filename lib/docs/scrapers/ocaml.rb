module Docs
  class Ocaml < FileScraper
    self.name = 'OCaml'
    self.type = 'ocaml'
    self.root_path = 'index.html'
    self.release = '4.12'
    self.base_url = "https://www.ocaml.org/releases/#{self.release}/htmlman/"
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
      &copy; 1995-2021 INRIA.
    HTML

    def get_latest_version(opts)
      doc = fetch_doc('https://www.ocaml.org/releases/', opts)
      doc.css('#main-contents li > a').first.content
    end

  end
end
