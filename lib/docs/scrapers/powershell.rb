module Docs
  class Powershell < FileScraper
    self.name = 'PowerShell'
    self.type = 'simple'
    self.root_path = 'Microsoft.PowerShell.Core/Get-Help.html'
    self.links = {
      home: 'https://learn.microsoft.com/powershell',
      code: 'https://github.com/MicrosoftDocs/PowerShell-Docs'
    }
    html_filters.push 'powershell/clean_html', 'powershell/entries'
    text_filters.replace 'attribution', 'powershell/attribution'

    options[:attribution] = <<-HTML
      The MIT License (MIT) Copyright (c) Microsoft Corporation
    HTML

    version '7.7' do
      self.release = '7.7'
    end

    version '7.6' do
      self.release = '7.6'
    end

    version '7.5' do
      self.release = '7.5'
    end

    version '7.4' do
      self.release = '7.4'
    end

    version '5.1' do
      self.release = '5.1'
    end

    version 'Scripting' do
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
      Dir.glob(File.join(source_directory, '**', '*.md')).sort.each do |path|
        url = File.join(base_url.to_s, path.sub("#{source_directory}/", ''))
        yield request_one(url)
      end
    end

    private

    def parse(response)
      body = response.body.sub(/\A---\s*\n.*?\n---\s*\n/m, '')
      html = markdown_renderer.render(body)
      [Parser.new("<html></head><body>#{html}</body></html>").html, ""]
    end

    def markdown_renderer
      require 'redcarpet'
      @markdown_renderer ||= Redcarpet::Markdown.new(
        Redcarpet::Render::HTML.new(with_toc_data: true),
        autolink: true,
        fenced_code_blocks: true,
        no_intra_emphasis: true,
        tables: true
      )
    end
  end
end
