module Docs
  class Nix < UrlScraper
    self.type = 'simple'
    self.release = '2.11.0'
    self.base_url = 'https://nixos.org/manual/'
    self.root_path = 'nix/stable/expressions/builtins.html'
    self.initial_paths = %w(
      nix/stable/expressions/builtins.html
      nixpkgs/stable/index.html)
    self.links = {
      home: 'https://nixos.org/',
      code: 'https://github.com/NixOS/nix'
    }

    html_filters.push 'nix/clean_html', 'nix/entries'

    options[:skip_links] = true

    options[:attribution] = <<-HTML
      &copy; 2022 NixOS Contributors<br>
      Licensed under the LGPL License.
    HTML

    def get_latest_version(opts)
      doc = fetch_doc('https://nixos.org/manual/nix/stable/', opts)
      json = JSON.parse(doc.at_css('body')['data-nix-channels'])
      channel = json.find { |c| c['channel'] == 'stable' }
      channel['version']
    end
  end
end
