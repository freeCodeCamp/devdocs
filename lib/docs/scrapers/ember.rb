module Docs
  class Ember < UrlScraper
    self.name = 'Ember.js'
    self.slug = 'ember'
    self.type = 'ember'
    self.version = '1.6.1'
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

    # Empty
    options[:skip].concat %w(
      classes/Ember.State.html
      classes/Ember.StateManager.html
      data/classes/DS.AdapterPopulatedRecordArray.html
      data/classes/DS.FilteredRecordArray.html)

    # Private
    options[:skip].concat %w(
      classes/Ember.ComponentTemplateDeprecation.html
      classes/Ember.Descriptor.html
      classes/Ember.EachProxy.html
      classes/Ember.EventDispatcher.html
      classes/Ember.Handlebars.Compiler.html
      classes/Ember.Handlebars.JavaScriptCompiler.html
      classes/Ember.Map.html
      classes/Ember.MapWithDefault.html
      classes/Ember.OrderedSet.html
      classes/Ember.TextSupport.html
      data/classes/DS.AdapterPopulatedRecordArray.html
      data/classes/DS.AttributeChange.html
      data/classes/DS.ContainerProxy.html
      data/classes/DS.DebugAdapter.html
      data/classes/DS.RecordArrayManager.html
      data/classes/DS.RelationshipChange.html
      data/classes/DS.RelationshipChangeAdd.html
      data/classes/DS.RelationshipChangeRemove.html)

    options[:skip_patterns] = [/\._/]

    options[:attribution] = <<-HTML
      &copy; 2014 Yehuda Katz, Tom Dale and Ember.js contributors<br>
      Licensed under the MIT License.
    HTML
  end
end
