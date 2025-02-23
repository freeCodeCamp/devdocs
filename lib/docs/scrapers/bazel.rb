module Docs
  class Bazel < UrlScraper
    self.name = 'Bazel'
    self.type = 'bazel'

    html_filters.push 'bazel/entries', 'bazel/clean_html'

    options[:skip] = %w(platform)

    options[:container] = "devsite-content"
    options[:attribution] = <<-HTML
    Licensed under the Creative Commons Attribution 4.0 License, and code samples are licensed under the Apache 2.0 License.
    HTML

    version '8.0' do
      self.release = '8.0.0'
      self.base_url = 'https://bazel.build/versions/8.0.0/reference/be/'
    end

    version '7.0' do
      self.release = '7.0.0'
      self.base_url = 'https://bazel.build/versions/7.0.0/reference/be/'
    end

    version '6.4' do
      self.release = '6.4.0'
      self.base_url = 'https://bazel.build/versions/6.4.0/reference/be/'
    end

    version '6.3' do
      self.release = '6.3.0'
      self.base_url = 'https://bazel.build/versions/6.3.0/reference/be/'
    end

    version '6.2' do
      self.release = '6.2.0'
      self.base_url = 'https://bazel.build/versions/6.2.0/reference/be/'
    end

    version '6.1' do
      self.release = '6.1.0'
      self.base_url = 'https://bazel.build/versions/6.1.0/reference/be/'
    end

    version '6.0' do
      self.release = '6.0.0'
      self.base_url = 'https://bazel.build/versions/6.0.0/reference/be/'
    end

    def get_latest_version(opts)
      get_latest_github_release('bazelbuild', 'bazel', opts)
    end

  end
end
