module Docs
  class Cakephp < UrlScraper
    self.name = 'CakePHP'
    self.type = 'cakephp'
    self.root_path = 'index.html'
    self.links = {
      home: 'https://cakephp.org/',
      code: 'https://github.com/cakephp/cakephp'
    }

    html_filters.push 'cakephp/clean_html', 'cakephp/entries'

    options[:container] = '#right'

    options[:skip_patterns] = [/\Asource-/]

    options[:attribution] = <<-HTML
      &copy; 2005&ndash;2017 The Cake Software Foundation, Inc.<br>
      Licensed under the MIT License.<br>
      CakePHP is a registered trademark of Cake Software Foundation, Inc.<br>
      We are not endorsed by or affiliated with CakePHP.
    HTML

    version '3.5' do
      self.release = '3.5.2'
      self.base_url = 'https://api.cakephp.org/3.5/'
    end

    version '3.4' do
      self.release = '3.4.13'
      self.base_url = 'https://api.cakephp.org/3.4/'
    end

    version '3.3' do
      self.release = '3.3.15'
      self.base_url = 'https://api.cakephp.org/3.3/'
    end

    version '3.2' do
      self.release = '3.2.14'
      self.base_url = 'https://api.cakephp.org/3.2/'
    end

    version '3.1' do
      self.release = '3.1.13'
      self.base_url = 'https://api.cakephp.org/3.1/'
    end

    version '2.10' do
      self.release = '2.10.3'
      self.base_url = 'https://api.cakephp.org/2.10/'
    end

    version '2.9' do
      self.release = '2.9.4'
      self.base_url = 'https://api.cakephp.org/2.9/'
    end

    version '2.8' do
      self.release = '2.8.8'
      self.base_url = 'https://api.cakephp.org/2.8/'
    end

    version '2.7' do
      self.release = '2.7.11'
      self.base_url = 'https://api.cakephp.org/2.7/'
    end

    private

    def parse(response)
      response.body.gsub! '<h5 class="method-name">', '<h3 class="method-name">'
      super
    end
  end
end
