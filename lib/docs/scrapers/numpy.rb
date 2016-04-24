module Docs
  class Numpy < FileScraper
    self.name = 'NumPy'
    self.type = 'sphinx'
    self.dir = '/Users/Thibaut/DevDocs/Docs/numpy/reference/'
    self.root_path = 'index.html'
    self.links = {
      home: 'http://www.numpy.org/',
      code: 'https://github.com/numpy/numpy'
    }

    html_filters.push 'numpy/entries', 'numpy/clean_html'

    # .main contains more than the page's content alone, but we need something
    # that includes the navigation bar as well in order to guess the type of
    # most pages.
    options[:container] = '.main'

    options[:skip_patterns] = [
      /.*(?<!\.html)\z/,
      /\Agenerated\/numpy\.chararray\.[\w\-]+.html\z/ # duplicate
    ]

    options[:attribution] = <<-HTML
      &copy; 2008&ndash;2016 NumPy Developers<br>
      Licensed under the NumPy License.
    HTML

    version '1.10' do
      self.release = '1.10.1'
      self.base_url = "https://docs.scipy.org/doc/numpy-#{self.release}/reference/"
    end
  end
end
