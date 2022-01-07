module Docs
  class Rails < UrlScraper
    include MultipleBaseUrls

    self.name = 'Ruby on Rails'
    self.type = 'rails'
    self.slug = 'rails'

    self.links = {
      home: 'http://rubyonrails.org/',
      code: 'https://github.com/rails/rails'
    }

    html_filters.push 'rails/entries', 'rails/clean_html'

    options[:root_title] = 'Ruby on Rails'

    options[:skip] = [
      'links.html',
      'index.html',
      'credits.html',
      'ruby_on_rails_guides_guidelines.html',
      'contributing_to_ruby_on_rails.html',
      'development_dependencies_install.html',
      'api_documentation_guidelines.html',
      'ActionController/Instrumentation.html',
      'ActionController/Rendering.html',
      'ActionDispatch/DebugExceptions.html',
      'ActionDispatch/Journey/Parser.html',
      'ActionDispatch/Reloader.html',
      'ActionDispatch/Routing/HtmlTableFormatter.html',
      'ActionDispatch/ShowExceptions.html',
      'ActionView/FixtureResolver.html',
      'ActionView/LogSubscriber.html',
      'ActionView/TestCase/Behavior/RenderedViewsCollection.html',
      'ActiveRecord/Tasks/DatabaseTasks.html',
      'ActiveSupport/Dependencies/WatchStack.html',
      'ActiveSupport/Notifications/Fanout.html',
      'ActionDispatch/www.example.com',
      'ActionDispatch/Http/www.rubyonrails.org',
      'ActionDispatch/Http/www.rubyonrails.co.uk',
      '\'TZ\'',
      'active_record_migrations.html',
      'association_basics.html'
    ]

    options[:skip_patterns] = [
      /history/i,
      /rakefile/i,
      /changelog/i,
      /readme/i,
      /news/i,
      /license/i,
      /release_notes/,
      /\AActionController\/Testing/,
      /\AActionView\/LookupContext/,
      /\AActionView\/Resolver/,
      /\AActiveSupport\/Multibyte\/Unicode\//,
      /\AActiveSupport\/XML/i,
      /\ASourceAnnotationExtractor/,
      /\AI18n\/Railtie/,
      /\AMinitest/,
      /\ARails\/API/,
      /\ARails\/AppBuilder/,
      /\ARails\/PluginBuilder/,
      /\ARails\/Generators\/Testing/
    ]

    options[:attribution] = ->(filter) do
      if filter.slug.start_with?('guides')
        <<-HTML
          &copy; 2004&ndash;2021 David Heinemeier Hansson<br>
          Licensed under the Creative Commons Attribution-ShareAlike 4.0 International License.
        HTML
      else
        <<-HTML
          &copy; 2004&ndash;2021 David Heinemeier Hansson<br>
          Licensed under the MIT License.
        HTML
      end
    end

    version '6.1' do
      self.release = '6.1.3.2'

      self.base_urls = [
        'https://api.rubyonrails.org/',
        'https://guides.rubyonrails.org/'
      ]

      options[:skip_patterns] << /v.*\..*\//
    end

    version '6.0' do
      self.release = '6.1.3.2'

      self.base_urls = [
        'https://api.rubyonrails.org/',
        'https://guides.rubyonrails.org/'
      ]
    end

    version '5.2' do
      self.release = '5.2.5'

      self.base_urls = [
        'https://api.rubyonrails.org/',
        'https://guides.rubyonrails.org/v5.2/'
      ]
    end

    version '5.1' do
      self.release = '5.1.7'

      self.base_urls = [
        'https://api.rubyonrails.org/',
        'https://guides.rubyonrails.org/v5.1/'
      ]
    end

    version '5.0' do
      self.release = '5.0.7.2'

      self.base_urls = [
        'https://api.rubyonrails.org/',
        'https://guides.rubyonrails.org/v5.0/'
      ]
    end

    version '4.2' do
      self.release = '4.2.11.3'

      self.base_urls = [
        'https://api.rubyonrails.org/',
        'https://guides.rubyonrails.org/v4.2/'
      ]
    end

    version '4.1' do
      self.release = '4.1.16'

      self.base_urls = [
        'https://api.rubyonrails.org/',
        'https://guides.rubyonrails.org/v4.1/'
      ]
    end

    def get_latest_version(opts)
      doc = fetch_doc('https://rubyonrails.org/', opts)
      doc.at_css('.version p a').content.scan(/\d\.\d*\.*\d*\.*\d*/)[0]
    end

  end
end
