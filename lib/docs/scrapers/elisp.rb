module Docs
  class Elisp < FileScraper
    self.type = 'elisp'
    self.release = '28.2'
    self.base_url= 'https://www.gnu.org/software/emacs/manual/html_node/elisp/'
    self.root_path = 'index.html'
    self.links = {
      home:'https://www.gnu.org/software/emacs/manual/elisp',
      code: 'https://git.savannah.gnu.org/cgit/emacs.git'
    }

    html_filters.push 'elisp/entries', 'elisp/clean_html'

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
      /Tips.html/,
      /Definition-of-/
    ]

    # fix duplicates
    options[:fix_urls]= -> (url) do
      url.sub!('Window-Group.html', 'Basic-Windows.html')
      url.sub!('Local-defvar-example.html', 'Using-Lexical-Binding.html')
      url.sub!('Defining-Lisp-variables-in-C.html', 'Writing-Emacs-Primitives.html')
      url.sub!('describe_002dsymbols-example.html', 'Accessing-Documentation.html')
      url.sub!('The-interactive_002donly-property.html', 'Defining-Commands.html')
      url.sub!('Text-help_002decho.html', 'Special-Properties.html')
      url.sub!('Help-display.html', 'Special-Properties.html')
      url.sub!('autoload-cookie.html', 'Autoload.html')
      url.sub!('external_002ddebugging_002doutput.html', 'Output-Streams.html')
      url.sub!('modifier-bits.html', 'Other-Char-Bits.html')
      url.sub!('message_002dbox.html', 'Displaying-Messages.html')
      url.sub!('abbreviate_002dfile_002dname.html', 'Directory-Names.html')
      url.sub!('Inhibit-point-motion-hooks.html', 'Special-Properties.html')
      url.sub!('Coding-systems-for-a-subprocess.html', 'Process-Information.html')
      url.sub!('Process-Filter-Example.html', 'Filter-Functions.html')
      url.sub!('Docstring-hyperlinks.html', 'Documentation-Tips.html')
      url.sub!('seq_002dlet.html', 'Sequence-Functions.html')
      url.sub!('should_005fquit.html', 'Module-Misc.html')
      url.sub!('Display-Face-Attribute-Testing.html', 'Display-Feature-Testing.html')
      url.sub!('module-initialization-function.html', 'Module-Initialization.html')
      url.sub!('pcase_002dsymbol_002dcaveats.html', 'pcase-Macro.html')
      url.sub!('intern.html', 'Module-Misc.html')
      url.sub!('pcase_002dexample_002d1.html', 'pcase-Macro.html')
      url
    end

    options[:attribution]= <<-HTML
      Copyright &copy; 1990-1996, 1998-2022 Free Software Foundation, Inc. <br>
      Licensed under the GNU GPL license.
    HTML

    def get_latest_version(opts)
      body = fetch('https://www.gnu.org/software/emacs/manual/html_node/elisp/index.html', opts)
      body.scan(/version \d*\.?\d*/)[0].sub('version', '')
    end

  end
end
