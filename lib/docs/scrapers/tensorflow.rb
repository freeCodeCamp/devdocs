module Docs
  class Tensorflow < UrlScraper
    self.name = 'TensorFlow'
    self.type = 'tensorflow'
    self.root_path = 'index.html'
    self.force_gzip = true
    self.links = {
      home: 'https://www.tensorflow.org/',
      code: 'https://github.com/tensorflow/tensorflow'
    }

    html_filters.push 'tensorflow/entries', 'tensorflow/clean_html'

    options[:container] = '#content'

    options[:fix_urls] = ->(url) do
      url.sub! %r{\Ahttps://www.tensorflow.org/versions(.+)/([^\.\#]+)(#.*)?\z}, 'https://www.tensorflow.org/versions\1/\2.html\3'
      url
    end

    options[:attribution] = <<-HTML
      &copy; 2015 The TensorFlow Authors. All rights reserved.<br>
      Licensed under the Apache 2.0 License.
    HTML

    version 'Python' do
      self.base_url = 'https://www.tensorflow.org/versions/r0.11/api_docs/python/'
      self.release = '0.11'
    end

    version 'C++' do
      self.base_url = 'https://www.tensorflow.org/versions/r0.11/api_docs/cc/'
      self.release = '0.11'
    end

    version 'Guide' do
      self.base_url = 'https://www.tensorflow.org/versions/r0.11/'
      self.release = '0.11'
      self.root_path = 'tutorials/index.html'
      self.initial_paths = %w(how_tos/index.html)

      options[:only_patterns] = [/\Atutorials/, /\Ahow_tos/]
    end
  end
end
