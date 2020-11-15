module Docs
  class Cakephp < UrlScraper
    self.name = 'CakePHP'
    self.type = 'cakephp'
    self.root_path = 'index.html'
    self.links = {
      home: 'https://cakephp.org/',
      code: 'https://github.com/cakephp/cakephp'
    }

    options[:skip_patterns] = [/\Asource-/, /\Anamespace-Cake.html/]

    options[:attribution] = <<-HTML
      &copy; 2005&ndash;present The Cake Software Foundation, Inc.<br>
      Licensed under the MIT License.<br>
      CakePHP is a registered trademark of Cake Software Foundation, Inc.<br>
      We are not endorsed by or affiliated with CakePHP.
    HTML

    version '4.1' do
      self.release = '4.1.6'
      self.base_url = "https://api.cakephp.org/#{self.version}/"

      html_filters.push 'cakephp/clean_html_39_plus', 'cakephp/entries_39_plus'

      options[:container] = '.page-container'
    end

    version '4.0' do
      self.release = '4.0.8'
      self.base_url = "https://api.cakephp.org/#{self.version}/"

      html_filters.push 'cakephp/clean_html_39_plus', 'cakephp/entries_39_plus'

      options[:container] = '.page-container'
    end

    version '3.9' do
      self.release = '3.9.4'
      self.base_url = "https://api.cakephp.org/#{self.version}/"

      html_filters.push 'cakephp/clean_html_39_plus', 'cakephp/entries_39_plus'

      options[:container] = '.page-container'
    end

    version '3.8' do
      self.release = '3.8.3'
      self.base_url = "https://api.cakephp.org/#{self.version}/"

      html_filters.push 'cakephp/clean_html', 'cakephp/entries'

      options[:container] = '#right'
    end

    version '3.7' do
      self.release = '3.7.9'
      self.base_url = "https://api.cakephp.org/#{self.version}/"

      html_filters.push 'cakephp/clean_html', 'cakephp/entries'

      options[:container] = '#right'
    end

    version '3.6' do
      self.release = '3.6.15'
      self.base_url = "https://api.cakephp.org/#{self.version}/"

      html_filters.push 'cakephp/clean_html', 'cakephp/entries'

      options[:container] = '#right'
    end

    version '3.5' do
      self.release = '3.5.15'
      self.base_url = "https://api.cakephp.org/#{self.version}/"

      html_filters.push 'cakephp/clean_html', 'cakephp/entries'

      options[:container] = '#right'
    end

    version '3.4' do
      self.release = '3.4.13'
      self.base_url = "https://api.cakephp.org/#{self.version}/"

      html_filters.push 'cakephp/clean_html', 'cakephp/entries'

      options[:container] = '#right'
    end

    version '3.3' do
      self.release = '3.3.15'
      self.base_url = "https://api.cakephp.org/#{self.version}/"

      html_filters.push 'cakephp/clean_html', 'cakephp/entries'

      options[:container] = '#right'
    end

    version '3.2' do
      self.release = '3.2.14'
      self.base_url = "https://api.cakephp.org/#{self.version}/"

      html_filters.push 'cakephp/clean_html', 'cakephp/entries'

      options[:container] = '#right'
    end

    version '3.1' do
      self.release = '3.1.13'
      self.base_url = "https://api.cakephp.org/#{self.version}/"

      html_filters.push 'cakephp/clean_html', 'cakephp/entries'

      options[:container] = '#right'
    end

    version '2.10' do
      self.release = '2.10.3'
      self.base_url = "https://api.cakephp.org/#{self.version}/"

      html_filters.push 'cakephp/clean_html', 'cakephp/entries'

      options[:container] = '#right'
    end

    version '2.9' do
      self.release = '2.9.4'
      self.base_url = "https://api.cakephp.org/#{self.version}/"

      html_filters.push 'cakephp/clean_html', 'cakephp/entries'

      options[:container] = '#right'
    end

    version '2.8' do
      self.release = '2.8.8'
      self.base_url = "https://api.cakephp.org/#{self.version}/"

      html_filters.push 'cakephp/clean_html', 'cakephp/entries'

      options[:container] = '#right'
    end

    version '2.7' do
      self.release = '2.7.11'
      self.base_url = "https://api.cakephp.org/#{self.version}/"

      html_filters.push 'cakephp/clean_html', 'cakephp/entries'

      options[:container] = '#right'
    end

    def get_latest_version(opts)
      doc = fetch_doc('https://cakephp.org', opts)
      doc.at_css('.title-home h1').content.scan(/\d\.\d*\.*\d*\.*\d*\.*/)[0]
    end

    private

    def parse(response)
      response.body.gsub! '<h5 class="method-name">', '<h3 class="method-name">'
      super
    end
  end
end
