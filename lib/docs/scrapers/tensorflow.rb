module Docs
  class Tensorflow < UrlScraper
    self.name = 'TensorFlow'
    self.slug = 'tensorflow'
    self.type = 'tensorflow'
    self.release = '0.6.0-py'
    self.base_url = 'https://www.tensorflow.org/versions/0.6.0/api_docs/python/'

    options[:container] = '#content'

    html_filters.push 'tensorflow/entries', 'tensorflow/clean_html', 'clean_html'

    options[:attribution] = <<-HTML
      &copy; The TensorFlow Authors.  All rights reserved.<br>
      Licensed under the Apache 2.0 License.
    HTML
  end
end
