# frozen_string_literal: true

module Docs
  class Tensorflow < UrlScraper
    self.name = 'TensorFlow'
    self.type = 'tensorflow'
    self.release = '1.8'
    self.root_path = 'index.html'
    self.links = {
      home: 'https://www.tensorflow.org/',
      code: 'https://github.com/tensorflow/tensorflow'
    }

    html_filters.push 'tensorflow/entries', 'tensorflow/clean_html'

    options[:max_image_size] = 300_000
    options[:container] = '.devsite-main-content'

    options[:fix_urls] = ->(url) do
      url.sub! 'how_tos/../tutorials', 'tutorials'
      url
    end

    options[:attribution] = <<-HTML
      &copy; 2018 The TensorFlow Authors. All rights reserved.<br>
      Licensed under the Creative Commons Attribution License 3.0.<br>
      Code samples licensed under the Apache 2.0 License.
    HTML

    version 'Python' do
      include MultipleBaseUrls
      self.base_urls = ['https://www.tensorflow.org/api_docs/python/', 'https://www.tensorflow.org/api_guides/python/']
    end

    version 'C++' do
      include MultipleBaseUrls
      self.base_urls = ['https://www.tensorflow.org/api_docs/cc/', 'https://www.tensorflow.org/api_guides/cc/']
    end

    version 'Guide' do
      self.base_url = 'https://www.tensorflow.org/'
      self.root_path = 'get_started/get_started'
      self.initial_paths = %w(
        programmers_guide/reading_data
        tutorials/mandelbrot
        performance/performance_guide
        deploy/hadoop
        extend/architecture)

      options[:only_patterns] = [
        /\Aget_started/,
        /\Aprogrammers_guide/,
        /\Atutorials/,
        /\Aperformance/,
        /\Adeploy/,
        /\Aextend/]
    end

    def get_latest_version(opts)
      get_latest_github_release('tensorflow', 'tensorflow', opts)
    end

    private

    def parse(response)
      unless response.url == root_url || self.class.version == 'Guide'
        response.body.sub!(/<nav class="devsite-nav-responsive-sidebar.+?<\/nav>/m, '')
        response.body.gsub!(/<li class="devsite-nav-item">.+?<\/li>/m, '')
      end

      super
    end
  end
end
