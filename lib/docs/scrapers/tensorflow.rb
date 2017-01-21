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

    options[:container] = '.devsite-main-content'

    options[:fix_urls] = ->(url) do
      url.sub! 'how_tos/../tutorials', 'tutorials'
      url
    end

    options[:attribution] = <<-HTML
      &copy; 2015 The TensorFlow Authors. All rights reserved.<br>
      Licensed under the Creative Commons Attribution License 3.0.<br>
      Code samples licensed under the Apache 2.0 License.
    HTML

    version 'Python' do
      self.base_url = 'https://www.tensorflow.org/api_docs/python/'
      self.release = '0.12'
    end

    version 'C++' do
      self.base_url = 'https://www.tensorflow.org/api_docs/cc/'
      self.release = '0.12'
    end

    version 'Guide' do
      self.base_url = 'https://www.tensorflow.org/'
      self.release = '0.12'
      self.root_path = 'tutorials/'
      self.initial_paths = %w(how_tos/)

      options[:only_patterns] = [/\Atutorials/, /\Ahow_tos/]
    end
  end
end
