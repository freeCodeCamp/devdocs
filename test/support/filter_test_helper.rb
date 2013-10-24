module FilterTestHelper
  extend ActiveSupport::Concern

  included do
    class_attribute :filter_class
  end

  def filter
    @filter ||= filter_class.new @body || '', context, result
  end

  def filter_output
    @filter_output ||= begin
      filter.instance_variable_set :@html, @body if @body
      filter.call
    end
  end

  def filter_output_string
    @filter_output_string ||= filter_output.to_s
  end

  def filter_result
    @filter_result ||= filter_output && result
  end

  class Context < Hash
    def []=(key, value)
      super key, key.to_s.end_with?('url') ? Docs::URL.parse(value) : value
    end
  end

  def context
    @context ||= Context.new
  end

  def result
    @result ||= {}
  end

  def link_to(href)
    %(<a href="#{href}">Link</a>)
  end
end
