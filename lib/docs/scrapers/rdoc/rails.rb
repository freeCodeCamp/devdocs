module Docs
  class Rails < Rdoc
    include FixInternalUrlsBehavior

    self.name = 'Ruby on Rails'
    self.slug = 'rails'
    self.dir = '/Users/Thibaut/DevDocs/Docs/RDoc/Rails'
    self.initial_paths = %w(guides/index.html)
    self.links = {
      home: 'http://rubyonrails.org/',
      code: 'https://github.com/rails/rails'
    }

    html_filters.replace 'rdoc/entries', 'rails/entries'
    html_filters.push 'rails/clean_html_guides'

    options[:skip_rdoc_filters?] = ->(filter) { filter.slug.start_with?('guides/') }

    options[:root_title] = 'Ruby on Rails'

    options[:skip] += %w(
      guides/credits.html
      guides/ruby_on_rails_guides_guidelines.html
      guides/contributing_to_ruby_on_rails.html
      guides/development_dependencies_install.html
      guides/api_documentation_guidelines.html
      ActionController/Instrumentation.html
      ActionController/Rendering.html
      ActionDispatch/DebugExceptions.html
      ActionDispatch/Journey/Parser.html
      ActionDispatch/Reloader.html
      ActionDispatch/Routing/HtmlTableFormatter.html
      ActionDispatch/ShowExceptions.html
      ActionView/FixtureResolver.html
      ActionView/LogSubscriber.html
      ActionView/TestCase/Behavior/RenderedViewsCollection.html
      ActiveRecord/Tasks/DatabaseTasks.html
      ActiveSupport/Dependencies/WatchStack.html
      ActiveSupport/Notifications/Fanout.html)

    options[:skip_patterns] += [
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
      /\ARails\/Generators\/Testing/]

    options[:attribution] = ->(filter) do
      if filter.slug.start_with?('guides')
        <<-HTML
          &copy; 2004&ndash;2017 David Heinemeier Hansson<br>
          Licensed under the Creative Commons Attribution-ShareAlike 4.0 International License.
        HTML
      else
        <<-HTML
          &copy; 2004&ndash;2017 David Heinemeier Hansson<br>
          Licensed under the MIT License.
        HTML
      end
    end

    version '5.1' do
      self.release = '5.1.4'
    end

    version '5.0' do
      self.release = '5.0.6'
    end

    version '4.2' do
      self.release = '4.2.10'
    end

    version '4.1' do
      self.release = '4.1.16'
    end
  end
end
