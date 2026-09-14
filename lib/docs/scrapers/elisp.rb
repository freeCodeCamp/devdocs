module Docs
  class Elisp < FileScraper
    self.type = 'elisp'
    self.release = '31.1.50'
    self.base_url= 'https://www.gnu.org/software/emacs/manual/html_node/elisp/'
    self.root_path = 'index.html'
    self.links = {
      home:'https://www.gnu.org/software/emacs/manual/elisp',
      code: 'https://git.savannah.gnu.org/cgit/emacs.git'
    }

    html_filters.push 'elisp/clean_html', 'elisp/entries'

    # some file that were not skipped by skip patterns
    options[:skip] = [
      'Coding-Conventions.html',
      'Key-Binding-Conventions.html',
      'Library-Headers.html'
    ]

    # some non essential sections
    options[:skip_patterns] = [
      /Introduction.html/,
      /Antinews.html/,
      /GNU-Free-Documentation-License.html/,
      /GPL.html/,
      /Tips.html/
    ]

    options[:attribution]= <<-HTML
      Copyright &copy; 1990-1996, 1998-2026 Free Software Foundation, Inc. <br>
      Licensed under the GNU GPL license.
    HTML

    def get_latest_version(opts)
      body = fetch('https://www.gnu.org/software/emacs/manual/html_node/elisp/index.html', opts)
      body.scan(/version \d+(?:\.\d+)*/)[0].sub('version ', '')
    end

    private

    def download_source
      # The archive expands to a single "elisp" directory.
      download_and_extract('https://www.gnu.org/software/emacs/manual/elisp.html_node.tar.gz', 'elisp')
    end
  end
end
