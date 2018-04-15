module Docs
  class Terraform < UrlScraper
    self.name = 'Terraform'
    self.type = 'terraform'
    self.release = '0.11.7'
    self.base_url = 'https://www.terraform.io/docs/'
    # self.dir = '/mnt/c/Users/Doug/Code/terraform-docs/www.terraform.io/docs'
    self.root_path = 'index.html'
    self.links = {
      home: 'https://www.terraform.io/',
      code: 'https://github.com/hashicorp/terraform'
    }

    html_filters.push 'terraform/entries', 'terraform/clean_html'

    options[:skip_patterns] = [/enterprise/, /enterprise-legacy/]

    options[:attribution] = <<-HTML
      Copyright &copy; 2018 HashiCorp</br>
      Licensed under the MPL 2.0 License.
    HTML
  end
end
