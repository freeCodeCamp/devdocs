module Docs
  class Tensorflow < UrlScraper
    self.name = 'TensorFlow'
    self.type = 'tensorflow'
    self.root_path = '/'
    self.links = {
      home: 'https://www.tensorflow.org/',
      code: 'https://github.com/tensorflow/tensorflow'
    }

    html_filters.push 'tensorflow/entries', 'tensorflow/clean_html'

    options[:max_image_size] = 300_000
    options[:container] = '.devsite-main-content'

    options[:attribution] = <<-HTML
      &copy; 2020 The TensorFlow Authors. All rights reserved.<br>
      Licensed under the Creative Commons Attribution License 4.0.<br>
      Code samples licensed under the Apache 2.0 License.
    HTML

    version '2.4' do
      self.release = "#{version}.0"
      self.base_url = "https://www.tensorflow.org/versions/r#{version}/api_docs/python/tf"
    end

    version '2.3' do
      self.release = "#{version}.0"
      self.base_url = "https://www.tensorflow.org/versions/r#{version}/api_docs/python/tf"
    end

    version '1.15' do
      self.release = "#{version}.0"
      self.base_url = "https://www.tensorflow.org/versions/r#{version}/api_docs/python/tf"
    end

    def get_latest_version(opts)
      get_latest_github_release('tensorflow', 'tensorflow', opts)
    end

    private

    def parse(response)
      unless response.url == root_url
        response.body.sub!(/<nav class="devsite-nav-responsive-sidebar.+?<\/nav>/m, '')
        response.body.gsub!(/<li class="devsite-nav-item">.+?<\/li>/m, '')
      end

      super
    end
  end
end
