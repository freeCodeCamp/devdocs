module Docs
  class Powershell < FileScraper
    self.name = 'PowerShell'
    self.type = 'simple'
    self.links = {
      home: 'https://learn.microsoft.com/powershell',
      code: 'https://github.com/MicrosoftDocs/PowerShell-Docs'
    }
    html_filters.push 'powershell/clean_html', 'powershell/entries'

    options[:attribution] = <<-HTML
      The MIT License (MIT) Copyright (c) Microsoft Corporation
    HTML

    version '7.7' do
      self.release = '7.7'
      self.root_path = 'Microsoft.PowerShell.Core/Get-Help.html'
    end

    version '7.6' do
      self.release = '7.6'
      self.root_path = 'Microsoft.PowerShell.Core/Get-Help.html'
    end

    version '7.5' do
      self.release = '7.5'
      self.root_path = 'Microsoft.PowerShell.Core/Get-Help.html'
    end

    version '7.4' do
      self.release = '7.4'
      self.root_path = 'Microsoft.PowerShell.Core/Get-Help.html'
    end

    version '5.1' do
      self.release = '5.1'
      self.root_path = 'Microsoft.PowerShell.Core/Get-Help.html'
    end

    version 'Scripting' do
      self.release = '7.7'
      self.root_path = 'discover-powershell.html'

      def source_directory
        @source_directory ||= File.join(Docs::FileScraper::SOURCE_DIRECTORY, 'powershell', 'docs-conceptual')
      end
    end

    def source_directory
      @source_directory ||= File.join(Docs::FileScraper::SOURCE_DIRECTORY, 'powershell', self.class.version)
    end

    # No index page, enumerate all HTML files
    def request_all(urls)
      assert_source_directory_exists
      Dir.glob(File.join(source_directory, '**', '*.html')).sort.each do |path|
        url = File.join(base_url.to_s, path.sub("#{source_directory}/", ''))
        yield request_one(url)
      end
    end
  end
end
