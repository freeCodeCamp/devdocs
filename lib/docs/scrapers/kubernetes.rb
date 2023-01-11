module Docs
  class Kubernetes < UrlScraper
    self.name = 'Kubernetes'
    self.type = 'kubernetes'
    self.root_path = '/'
    self.links = {
      home: 'https://kubernetes.io/',
      code: 'https://github.com/kubernetes/kubernetes'
    }

    # https://kubernetes.io/docs/reference/kubernetes-api/
    html_filters.push 'kubernetes/entries', 'kubernetes/clean_html'

    options[:container] = '.td-content'

    options[:attribution] = <<-HTML
      &copy; 2022 The Kubernetes Authors | Documentation Distributed under CC BY 4.0 <br>
      Copyright &copy; 2022 The Linux Foundation ®. All rights reserved.
    HTML

    # latest version has a special URL that does not include the version identifier 
    version do
      self.release = "1.26"
      self.base_url = "https://kubernetes.io/docs/reference/kubernetes-api/"
    end

    version '1.20' do
      self.release = "#{version}"
      self.base_url = "https://v#{version.sub('.', '-')}.docs.kubernetes.io/docs/reference/kubernetes-api/"
    end

    def get_latest_version(opts)
      get_latest_github_release('kubernetes', 'kubernetes', opts)
    end

  end
end
