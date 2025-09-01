module Docs
  class Playwright < UrlScraper
    self.name = 'Playwright'
    self.type = 'simple'
    self.release = '1.55.0'
    self.base_url = 'https://playwright.dev/docs/'
    self.root_path = 'intro'
    self.links = {
      home: 'https://playwright.dev/',
      code: 'https://github.com/microsoft/playwright'
    }

    # Docusaurus like react_native
    html_filters.push 'playwright/entries', 'playwright/clean_html'
    options[:download_images] = false

	# https://github.com/microsoft/playwright/blob/main/LICENSE
    options[:attribution] = <<-HTML
      &copy; 2025 Microsoft<br>
	  Licensed under the Apache License, Version 2.0.
    HTML

    def get_latest_version(opts)
      get_npm_version('@playwright/test', opts)
      end
  end
end
