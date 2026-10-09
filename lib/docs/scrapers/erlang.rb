module Docs
  class Erlang < FileScraper
    self.type = 'erlang'
    self.root_path = 'doc/index.html'
    self.links = {
      home: 'https://www.erlang.org/',
      code: 'https://github.com/erlang/otp'
    }

    html_filters.insert_after 'container', 'erlang/pre_clean_html'
    html_filters.push 'erlang/entries', 'erlang/clean_html'

    options[:only_patterns] = [
      /\Alib/,
      /\Adoc\/\w+\//,
      /\Aerts.+\/html/
    ]

    options[:skip_patterns] = [
      /pdf/,
      /release_notes/,
      /result/,
      /java/,
      /\.erl\z/,
      /\/html\/.*_app\.html\z/,
      /_examples\.html\z/,
      /\Alib\/edoc/,
      /\Alib\/erl_docgen/,
      /\Alib\/hipe/,
      /\Alib\/ose/,
      /\Alib\/test_server/,
      /\Alib\/jinterface/,
      /\Alib\/wx/,
      /\Alib\/ic/,
      /\Alib\/Cos/i
    ]

    options[:attribution] = <<-HTML
      &copy; 2010&ndash;2026 Ericsson AB<br>
      Licensed under the Apache License, Version 2.0.
    HTML

    # Since OTP 27, the documentation is generated with ExDoc
    module ExDoc
      def self.included(base)
        base.class_eval do
          self.root_path = 'doc/readme.html'

          html_filters.replace 'erlang/entries', 'erlang/entries_ex_doc'
          html_filters.replace 'erlang/clean_html', 'erlang/clean_html_ex_doc'

          options[:container] = '#content'

          options[:only_patterns] = [
            /\Alib\/[^\/]+\/doc\/html\/[^\/]+\.html\z/,
            /\Aerts-[^\/]+\/doc\/html\/[^\/]+\.html\z/,
            /\Adoc\/system\/[^\/]+\.html\z/
          ]

          options[:skip_patterns] = [
            /\/(index|404|search|api-reference|notes)\.html\z/,
            /\Alib\/jinterface/,
            /\Alib\/wx/
          ]
        end
      end

      def initial_paths
        assert_source_directory_exists
        Dir.chdir(source_directory) do
          Dir['{lib/*/doc/html,erts-*/doc/html,doc/system}/*.html'].sort
        end.reject do |path|
          self.class.options[:skip_patterns].any? { |pattern| path =~ pattern }
        end
      end

      # Maps the guides in doc/system to their group in the ExDoc sidebar
      def additional_options
        assert_source_directory_exists
        file = Dir[File.join(source_directory, 'doc/system/dist/sidebar_items-*.js')].first
        json = File.read(file)
        json = JSON.parse(json[json.index('{')..json.rindex('}')])
        super.merge system_groups: json['extras'].to_h { |extra| [extra['id'], extra['group']] }
      end
    end

    version '29' do
      self.release = '29.1.1'
      include ExDoc
    end

    version '28' do
      self.release = '28.5.0.7'
      include ExDoc
    end

    version '27' do
      self.release = '27.3.4.18'
      include ExDoc
    end

    version '26' do
      self.release = '26.2.5.21'
    end

    version '25' do
      self.release = '25.3.2.2'
    end

    version '24' do
      self.release = '24.0'
    end

    version '23' do
      self.release = '23.2'
    end

    version '22' do
      self.release = '22.3'
    end

    version '21' do
      self.release = '21.0'
    end

    version '20' do
      self.release = '20.3'
    end

    version '19' do
      self.release = '19.3'
    end

    version '18' do
      self.release = '18.3'
    end

    def get_latest_version(opts)
      get_latest_github_release('erlang', 'otp', opts)[4..-1]
    end

    private

    def download_source
      download_and_extract("https://github.com/erlang/otp/releases/download/OTP-#{self.class.release}/otp_doc_html_#{self.class.release}.tar.gz")
    end
  end
end
