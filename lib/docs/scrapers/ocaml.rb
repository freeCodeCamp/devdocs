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
      &copy; INRIA 1995-2020.
    HTML

  end
end
