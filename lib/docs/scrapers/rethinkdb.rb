module Docs
  class Rethinkdb < UrlScraper
    self.name = 'RethinkDB'
    self.type = 'rethinkdb'
    self.base_url = 'https://rethinkdb.com/'
    self.release = '2.3.5'
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
      docs/tutorials/superheroes/)

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
      storing-binary)

    options[:attribution] = <<-HTML
      &copy; RethinkDB contributors<br>
      Licensed under the Creative Commons Attribution-ShareAlike 3.0 Unported License.
    HTML

    %w(JavaScript Ruby Python Java).each do |name|
      path = name.downcase
      instance_eval <<-CODE
        version '#{name}' do
          self.initial_paths = %w(api/#{path}/)

          options[:only_patterns] += [/\\Aapi\\/#{path}\\//]

          options[:fix_urls] = ->(url) do
            url.sub! %r{rethinkdb.com/docs/(#{MULTILANG_DOCS.join('|')})\\z}, 'rethinkdb.com/docs/\\1/#{path}/'
            url.sub! %r{rethinkdb.com/docs/(#{MULTILANG_DOCS.join('|')})/(?!#{path}/).*}, 'rethinkdb.com/docs/\\1/#{path}/'
            url.sub! %r{rethinkdb.com/api/(?!javascript|ruby|python|java)}, 'rethinkdb.com/api/#{path}/'
            url
          end
        end
      CODE
    end

    private

    def process_response?(response)
      return false unless super
      response.body !~ /http-equiv="refresh"/i
    end
  end
end
