module Docs
  class Rails < Rdoc
    self.name = 'Ruby on Rails'
    self.slug = 'rails'
    self.version = '4.2.1'
    self.dir = '/Users/Thibaut/DevDocs/Docs/RDoc/Rails'
    self.links = {
      home: 'http://rubyonrails.org/',
      code: 'https://github.com/rails/rails'
    }

    html_filters.replace 'rdoc/entries', 'rails/entries'

    options[:root_title] = 'Ruby on Rails'

    options[:skip] += %w(
      AbstractController/Callbacks.html
      AbstractController/UrlFor.html
      ActionController/Instrumentation.html
      ActionController/Rendering.html
      ActionDispatch/DebugExceptions.html
      ActionDispatch/Http/URL.html
      ActionDispatch/Journey/Parser.html
      ActionDispatch/Reloader.html
      ActionDispatch/RequestId.html
      ActionDispatch/Routing/HtmlTableFormatter.html
      ActionDispatch/Routing/Mapper.html
      ActionDispatch/Routing/RouteSet.html
      ActionDispatch/ShowExceptions.html
      ActionView/FileSystemResolver.html
      ActionView/FixtureResolver.html
      ActionView/LogSubscriber.html
      ActionView/Template/Handlers/Erubis.html
      ActionView/TestCase/Behavior/RenderedViewsCollection.html
      ActiveRecord/DynamicMatchers/Finder.html
      ActiveRecord/Sanitization.html
      ActiveRecord/Tasks/DatabaseTasks.html
      ActiveSupport/Configurable/Configuration.html
      ActiveSupport/Dependencies/WatchStack.html
      ActiveSupport/DescendantsTracker.html
      ActiveSupport/FileUpdateChecker.html
      ActiveSupport/Notifications/Fanout.html
      ActiveSupport/Testing/Isolation/Subprocess.html
      Rails/API/Task.html)

    options[:skip_patterns] += [
      /\AActionController\/Caching(?!\/Fragments|\.)/,
      /\AActionController\/RequestForgeryProtection\/ProtectionMethods/,
      /\AActionController\/Testing/,
      /\AActionDispatch\/RemoteIp/,
      /\AActionView\/LookupContext/,
      /\AActionView\/Resolver/,
      /\AActiveSupport\/Multibyte\/Unicode\//,
      /\AActiveSupport\/XML/i,
      /\ASourceAnnotationExtractor/,
      /\AI18n\/Railtie/,
      /\ARails\/AppBuilder/,
      /\ARails\/PluginBuilder/]

    options[:attribution] = <<-HTML
      &copy; 2004&ndash;2015 David Heinemeier Hansson<br>
      Licensed under the MIT License.
    HTML
  end
end
