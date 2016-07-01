module Docs
  class Rails < Rdoc
    self.name = 'Ruby on Rails'
    self.slug = 'rails'
    self.dir = '/Users/Thibaut/DevDocs/Docs/RDoc/Rails'
    self.links = {
      home: 'http://rubyonrails.org/',
      code: 'https://github.com/rails/rails'
    }

    html_filters.replace 'rdoc/entries', 'rails/entries'

    options[:root_title] = 'Ruby on Rails'

    options[:skip] += %w(
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

    options[:attribution] = <<-HTML
      &copy; 2004&ndash;2016 David Heinemeier Hansson<br>
      Licensed under the MIT License.
    HTML

    version '5.0' do
      self.release = '5.0.0'
    end

    version '4.2' do
      self.release = '4.2.6'
    end

    version '4.1' do
      self.release = '4.1.15'
    end
  end
end
