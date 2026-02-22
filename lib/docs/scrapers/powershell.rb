module Docs
  class Powershell < FileScraper
    self.name = 'PowerShell'
    self.type = 'simple'
    self.release = '7.5'
    self.base_url = 'https://learn.microsoft.com/en-us/powershell'
    self.root_path = 'docs-conceptual/overview.html'
    self.initial_paths = [
      'module/index.html',
    ]
    self.links = {
      home: 'https://learn.microsoft.com/powershell',
      code: 'https://github.com/MicrosoftDocs/PowerShell-Docs'
    }
    html_filters.push 'powershell/clean_html', 'powershell/entries'

    options[:skip_patterns] = [/\/\//] # otherwise infinately adding the same pages
    options[:attribution] = <<-HTML
      The MIT License (MIT) Copyright (c) Microsoft Corporation
    HTML
  end
end
