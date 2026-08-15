module Docs
  class Terraform < UrlScraper
    self.name = 'Terraform'
    self.type = 'terraform'
    self.release = '1.15.8'
    self.base_url = 'https://developer.hashicorp.com/terraform/'
    self.root_path = 'docs'
    self.initial_paths = %w(internals)
    self.links = {
      home: 'https://www.terraform.io/',
      code: 'https://github.com/hashicorp/terraform'
    }

    html_filters.push 'terraform/entries', 'terraform/clean_html'

    options[:trailing_slash] = false

    options[:skip_patterns] = [
      # HCP Terraform / Terraform Enterprise are separate products
      /\Aenterprise/,
      /\Acloud-docs/,
      # The version switcher links to every past release of the same page
      %r{(\A|/)v\d+\.\d+\.x(/|\z)},
    ]

    options[:attribution] = <<-HTML
      &copy; 2026 HashiCorp<br>
      Licensed under the MPL 2.0 License.
    HTML

    def get_latest_version(opts)
      get_latest_github_release('hashicorp', 'terraform', opts)
    end
  end
end
