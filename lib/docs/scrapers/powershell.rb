module Docs
  class Powershell < FileScraper
  # class Powershell < UrlScraper
    self.name = 'PowerShell'
    self.type = 'simple'
    self.release = '7.5'
    self.base_url = 'https://learn.microsoft.com/en-us/powershell'
    # self.root_path = 'scripting/overview.html'
    self.root_path = 'docs-conceptual/overview.html'
    self.initial_paths = [
      # 'scripting/toc.html',
      'module/index.html',
      # 'module/Microsoft.WSMan.Management/About/about_WS-Management_Cmdlets.html',
      # 'module/PSWorkflow/About/about_ActivityCommonParameters.html',
      # 'module/Microsoft.PowerShell.Core/About/About.html',
      # 'module/PSReadLine/About/about_PSReadLine.html',
      # 'module/Microsoft.PowerShell.Security/About/about_Certificate_Provider.html',
      # 'module/PSScheduledJob/About/about_Scheduled_Jobs.html'
    ]
    self.links = {
      home: 'https://learn.microsoft.com/powershell',
      code: 'https://github.com/MicrosoftDocs/PowerShell-Docs'
    }
    html_filters.push 'powershell/clean_html', 'powershell/entries'

    # options[:rate_limit] = 100 # micososft docs online are ratelimited
    options[:skip_patterns] = [/\/\//] # otherwise infinately adding the same pages
    options[:attribution] = <<-HTML
      The MIT License (MIT) Copyright (c) Microsoft Corporation
    HTML
  end
end
