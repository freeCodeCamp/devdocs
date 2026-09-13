module Docs
  class Deno < UrlScraper
    self.name = 'Deno'
    self.type = 'simple'
    self.base_url = 'https://docs.deno.com/'
    self.root_path = 'api'
    self.initial_paths = %w(
      api/deno
      runtime
      runtime/fundamentals
      runtime/reference
    )
    self.links = {
      home: 'https://deno.com/',
      code: 'https://github.com/denoland/deno'
    }

    html_filters.push 'deno/clean_html', 'deno/entries'

    options[:root_title] = 'Deno'
    options[:title] = false
    options[:follow_links] = true
    options[:only_patterns] = [
      /\Aapi\//,
      /\Aruntime\//,
    ]
    options[:skip_patterns] = [
      /\Ablog\//,
      /\Adeploy\//,
      /\Asubhosting\//,
      # Aggregate listings that repeat every symbol already documented on the
      # individual module pages.
      /\Aapi\/\w+\/all_symbols/,
      # Per-symbol URLs now 301 to a fragment of the module page
      # (api/web/~/Blob -> api/web/file/#Blob). Because the stored path comes
      # from the requested URL, crawling them would file a second copy of the
      # whole module page under every symbol it documents.
      /\Aapi\/\w+\/~\//,
    ]
    # docs.deno.com links to both `api/node/buffer` and `api/node/buffer/`;
    # without this each page is crawled twice, once as `…/buffer` and once as
    # `…/buffer/index`.
    options[:trailing_slash] = false

    options[:attribution] = <<-HTML
      &copy; 2018&ndash;2025 the Deno authors<br>
      Licensed under the MIT License.
    HTML

    # ── Versions ──────────────────────────────────────────────────────

    version '2' do
      self.release = '2.9.6'
    end

    version '1' do
      self.release = '1.46.3'
      self.base_url = 'https://docs.deno.com/api/'
    end

    # ── Latest version lookup ─────────────────────────────────────────

    def get_latest_version(opts)
      get_latest_github_release('denoland', 'deno', opts)
    end
  end
end
