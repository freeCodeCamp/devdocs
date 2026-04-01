module Docs
  class Opentofu < UrlScraper
    self.name = 'Opentofu'
    self.type = 'opentofu'
    self.links = {
      home: 'https://opentofu.org/',
    }

    html_filters.push 'opentofu/entries', 'opentofu/clean_html'

    # Empty spans are used by Prism for code highlighting.
    # Don't clean them
    options[:clean_text] = false
    options[:trailing_slash] = true
    options[:attribution] = <<-HTML
      Copyright &copy; OpenTofu a Series of LF Projects, LLC and its contributors. Documentation materials incorporate content licensed under the MPL-2.0 license from other authors.
    HTML

    def get_latest_version(opts)
      contents = get_latest_github_release('opentofu', 'opentofu', opts)
      contents.sub("v", "")
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
