module Docs
  class Cakephp < FileScraper
    self.name = 'CakePHP'
    self.type = 'cakephp'
    self.dir = '/Users/Thibaut/DevDocs/Docs/CakePHP'
    self.root_path = 'index.html'
    self.links = {
      home: 'http://cakephp.org/',
      code: 'https://github.com/cakephp/cakephp'
    }

    html_filters.push 'cakephp/clean_html', 'cakephp/entries'

    options[:container] = '#right.columns.nine'

    options[:skip_patterns] = [/\Asource-/]

    options[:attribution] = <<-HTML
      &copy; 2005&ndash;2016 The Cake Software Foundation, Inc.<br>
      Licensed under the MIT License.<br>
      CakePHP is a registered trademark of Cake Software Foundation, Inc.<br>
      We are not endorsed by or affiliated with CakePHP.
    HTML

    version '3.2' do # http://api.cakephp.org/3.2/cakephp-api-documentation.zip
      self.release = '3.2.8'
      self.base_url = 'http://api.cakephp.org/3.2/'
    end

    version '3.1' do # http://api.cakephp.org/3.1/cakephp-api-documentation.zip
      self.release = '3.1.13'
      self.base_url = 'http://api.cakephp.org/3.1/'
    end

    version '2.8' do # http://api.cakephp.org/2.8/cakephp-api-documentation.zip
      self.release = '2.8.3'
      self.base_url = 'http://api.cakephp.org/2.8/'
    end

    version '2.7' do # http://api.cakephp.org/2.7/cakephp-api-documentation.zip
      self.release = '2.7.11'
      self.base_url = 'http://api.cakephp.org/2.7/'
    end
  end
end
