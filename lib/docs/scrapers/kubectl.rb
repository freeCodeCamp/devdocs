module Docs
  class Kubectl < UrlScraper
    self.name = 'Kubectl'
    self.type = 'kubectl'
    self.root_path = ''
    self.links = {
      home: 'https://kubernetes.io/docs/reference/kubectl/',
      code: 'https://github.com/kubernetes/kubernetes'
    }
    self.base_url = "https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands"

    html_filters.push 'kubectl/entries', 'kubectl/clean_html'

    options[:container] = '#page-content-wrapper'

    options[:attribution] = <<-HTML
      &copy; 2022 The Kubernetes Authors | Documentation Distributed under CC BY 4.0 <br>
      Copyright &copy; 2022 The Linux Foundation ®. All rights reserved.
    HTML

    # latest version has a special URL that does not include the version identifier 
    version do
      self.release = "1.26"
      self.base_url = "https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands"
    end

    version '1.20' do
      self.release = "#{version}"
      self.base_url = "https://v#{version.sub('.', '-')}.docs.kubernetes.io/docs/reference/generated/kubectl/kubectl-commands"
    end

    def get_latest_version(opts)
      get_latest_github_release('kubernetes', 'kubernetes', opts)
    end

  end
end
