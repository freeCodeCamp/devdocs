module Docs
  class Click < UrlScraper
    self.name = 'click'
    self.type = 'sphinx'
    self.root_path = 'index.html'
    self.links = {
      home: 'https://click.palletsprojects.com/',
      code: 'https://github.com/pallets/click'
    }

    html_filters.push 'click/pre_clean_html', 'click/entries', 'sphinx/clean_html'

    options[:container] = '.body > section'
    options[:skip] = ['changes/', 'genindex/', 'py-modindex/']
    options[:title] = false

    options[:attribution] = <<-HTML
      &copy; Copyright 2014 Pallets.<br>
      Licensed under the BSD 3-Clause License.<br>
      We are not supported nor endorsed by Pallets.
    HTML

    version '8.1' do
      self.release = '8.1.x'
      self.base_url = "https://click.palletsprojects.com/en/#{self.release}/"
    end

    version '8.0' do
      self.release = '8.0.x'
      self.base_url = "https://click.palletsprojects.com/en/#{self.release}/"
    end

    version '7' do
      self.release = '7.x'
      self.base_url = "https://click.palletsprojects.com/en/#{self.release}/"
    end

    version '6' do
      self.release = '6.x'
      self.base_url = "https://click.palletsprojects.com/en/#{self.release}/"
    end

    version '5' do
      self.release = '5.x'
      self.base_url = "https://click.palletsprojects.com/en/#{self.release}/"
    end

    version '4' do
      self.release = '4.x'
      self.base_url = "https://click.palletsprojects.com/en/#{self.release}/"
    end

    version '3' do
      self.release = '3.x'
      self.base_url = "https://click.palletsprojects.com/en/#{self.release}/"
    end

    version '2' do
      self.release = '2.x'
      self.base_url = "https://click.palletsprojects.com/en/#{self.release}/"
    end

    version '1' do
      self.release = '1.x'
      self.base_url = "https://click.palletsprojects.com/en/#{self.release}/"
    end

    def get_latest_version(opts)
      get_latest_github_release('pallets', 'click', opts)
    end
  end
end
