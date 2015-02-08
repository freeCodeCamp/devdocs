module Docs
  class Ember < UrlScraper
    self.name = 'Ember.js'
    self.slug = 'ember'
    self.type = 'ember'
    self.version = '1.10.0'
    self.base_url = 'http://emberjs.com/api/'

    html_filters.push 'ember/clean_html', 'ember/entries', 'title'

    options[:title] = false
    options[:root_title] = 'Ember.js'

    options[:container] = ->(filter) do
      filter.root_page? ? '#toc-list' : '#content'
    end

    # Duplicates
    options[:skip] = %w(
      classes/String.html
      data/classes/DS.html)

    # Private
    options[:skip].concat %w(
      classes/Backburner.html
      classes/Ember.ComponentTemplateDeprecation.html
      classes/Ember.ControllerContentModelAliasDeprecation.html
      classes/Ember.Descriptor.html
      classes/Ember.EachProxy.html
      classes/Ember.EventDispatcher.html
      classes/Ember.Map.html
      classes/Ember.MapWithDefault.html
      classes/Ember.OrderedSet.html
      classes/Ember.TextSupport.html
      classes/HandlebarsCompatibleHelper.html
      classes/Libraries.html
      data/classes/DS.ContainerProxy.html
      data/classes/DS.DebugAdapter.html
      data/classes/DS.RecordArrayManager.html)

    options[:skip_patterns] = [/\._/]

    options[:attribution] = <<-HTML
      &copy; 2015 Yehuda Katz, Tom Dale and Ember.js contributors<br>
      Licensed under the MIT License.
    HTML
  end
end
