require 'bundler/setup'
Bundler.require :docs

require 'active_support'
require 'active_support/core_ext'
I18n.enforce_available_locales = true

module Docs
  require 'docs/core/autoload_helper'
  extend AutoloadHelper

  mattr_reader :root_path
  @@root_path = File.expand_path '..', __FILE__

  autoload :URL, 'docs/core/url'
  autoload_all 'docs/core'
  autoload_all 'docs/filters/core', 'filter'
  autoload_all 'docs/scrapers'
  autoload_all 'docs/storage'
  autoload_all 'docs/subscribers'

  mattr_accessor :store_class
  self.store_class = FileStore

  mattr_accessor :store_path
  self.store_path = File.expand_path '../public/docs', @@root_path

  class DocNotFound < NameError; end

  def self.all
    Dir["#{root_path}/docs/scrapers/**/*.rb"].
      map { |file| File.basename(file, '.rb') }.
      sort!.
      map(&method(:find)).
      reject(&:abstract)
  end

  def self.find(name)
    const = name.camelize
    const_get(const)
  rescue NameError => error
    if error.name.to_s == const
      raise DocNotFound.new("failed to locate doc class '#{name}'", name)
    else
      raise error
    end
  end

  def self.generate_page(name, page_id)
    find(name).store_page(store, page_id)
  end

  def self.generate(name)
    find(name).store_pages(store)
  end

  def self.generate_manifest
    Manifest.new(store, all).store
  end

  def self.store
    store_class.new(store_path)
  end

  extend Instrumentable

  def self.install_report(*names)
    names.each do |name|
      const_get("#{name}_subscriber".camelize).subscribe_to(self)
    end
  end
end
