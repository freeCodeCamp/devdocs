module Docs
  class Rethinkdb < UrlScraper
    self.name = 'RethinkDB'
    self.type = 'rethinkdb'
    self.base_url = 'https://rethinkdb.com/'
    self.release = '2.4.1'
    self.root_path = 'docs/'
    self.links = {
      home: 'https://rethinkdb.com/',
      code: 'https://github.com/rethinkdb/rethinkdb'
    }

    html_filters.push 'rethinkdb/entries', 'rethinkdb/clean_html'

    options[:trailing_slash] = true

    options[:container] = '.documentation'

    options[:only_patterns] = [/\Adocs/]

    options[:skip_patterns] = [/docs\/install(\-drivers)?\/./]

    options[:skip] = %w(
      docs/build/
      docs/tutorials/elections/
      docs/tutorials/superheroes/
      )

    MULTILANG_DOCS = %w(
      changefeeds
      cookbook
      dates-and-times
      geo-support
      guide
      nested-fields
      publish-subscribe
      rabbitmq
      secondary-indexes
      sql-to-reql
      storing-binary
      )

    options[:attribution] = <<-HTML
      &copy; RethinkDB contributors<br>
      Licensed under the Creative Commons Attribution-ShareAlike 3.0 Unported License.
    HTML

    version 'javascript' do
      self.initial_paths = %w(api/javascript/)

      options[:only_patterns] += [/\Aapi\/javascript\//]

      options[:fix_urls] = ->(url) do
        url.sub! %r{rethinkdb.com/docs/(#{MULTILANG_DOCS.join('|')})\\z}, 'rethinkdb.com/docs/\\1/javascript/'
        url.sub! %r{rethinkdb.com/docs/(#{MULTILANG_DOCS.join('|')})/(?!javascript/).*}, 'rethinkdb.com/docs/\\1/javascript/'
        url.sub! %r{rethinkdb.com/api/(?!javascript|ruby|python|java)}, 'rethinkdb.com/api/javascript/'
        url
      end
    end

    version 'ruby' do
      self.initial_paths = %w(api/ruby/)

      options[:only_patterns] += [/\Aapi\/ruby\//]

      options[:fix_urls] = ->(url) do
        url.sub! %r{rethinkdb.com/docs/(#{MULTILANG_DOCS.join('|')})\\z}, 'rethinkdb.com/docs/\\1/ruby/'
        url.sub! %r{rethinkdb.com/docs/(#{MULTILANG_DOCS.join('|')})/(?!ruby/).*}, 'rethinkdb.com/docs/\\1/ruby/'
        url.sub! %r{rethinkdb.com/api/(?!javascript|ruby|python|java)}, 'rethinkdb.com/api/ruby/'
        url
      end
    end

      version 'python' do
        self.initial_paths = %w(api/python/)

        options[:only_patterns] += [/\Aapi\/python\//]

        options[:fix_urls] = ->(url) do
          url.sub! %r{rethinkdb.com/docs/(#{MULTILANG_DOCS.join('|')})\\z}, 'rethinkdb.com/docs/\\1/python/'
          url.sub! %r{rethinkdb.com/docs/(#{MULTILANG_DOCS.join('|')})/(?!python/).*}, 'rethinkdb.com/docs/\\1/python/'
          url.sub! %r{rethinkdb.com/api/(?!javascript|ruby|python|java)}, 'rethinkdb.com/api/python/'
          url
        end
      end

      version 'java' do
        self.initial_paths = %w(api/java/)

        options[:only_patterns] += [/\Aapi\/java\//]

        options[:fix_urls] = ->(url) do
          url.sub! %r{rethinkdb.com/docs/(#{MULTILANG_DOCS.join('|')})\\z}, 'rethinkdb.com/docs/\\1/java/'
          url.sub! %r{rethinkdb.com/docs/(#{MULTILANG_DOCS.join('|')})/(?!java/).*}, 'rethinkdb.com/docs/\\1/java/'
          url.sub! %r{rethinkdb.com/api/(?!javascript|ruby|python|java)}, 'rethinkdb.com/api/java/'
          url
        end
      end

    def get_latest_version(opts)
      get_latest_github_release('rethinkdb', 'rethinkdb', opts)
    end

    private

    def process_response?(response)
      return false unless super
      response.body !~ /http-equiv="refresh"/i
    end

  end
end
