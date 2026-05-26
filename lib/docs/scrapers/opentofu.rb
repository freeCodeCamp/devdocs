module Docs
  class Opentofu < UrlScraper
    self.name = 'OpenTofu'
    self.type = 'opentofu'
    self.links = {
      home: 'https://opentofu.org/',
    }

    html_filters.push 'opentofu/entries', 'opentofu/clean_html'

    # Empty spans are used by Prism for code highlighting.
    # Don't clean them
    options[:clean_text] = false
    options[:trailing_slash] = true
    # https://github.com/opentofu/opentofu/blob/main/LICENSE
    options[:attribution] = <<-HTML
      Copyright (c) The OpenTofu Authors<br>
      Copyright (c) 2014 HashiCorp, Inc.<br>
      Mozilla Public License, version 2.0
    HTML

    def get_latest_version(opts)
      contents = get_latest_github_release('opentofu', 'opentofu', opts)
      contents.sub("v", "")
    end

    version '1.12' do
      self.release = '1.12.0'
      self.base_url = "https://opentofu.org/docs/v#{self.version}/"
    end

    version '1.11' do
      self.release = '1.11.5'
      self.base_url = "https://opentofu.org/docs/v#{self.version}/"
    end

    version '1.10' do
      self.release = '1.10.9'
      self.base_url = "https://opentofu.org/docs/v#{self.version}/"
    end

    version '1.9' do
      self.release = '1.9.4'
      self.base_url = "https://opentofu.org/docs/v#{self.version}/"
    end
  end
end
