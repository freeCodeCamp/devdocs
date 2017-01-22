# frozen_string_literal: true

module Docs
  class ContainerFilter < Filter
    class ContainerNotFound < StandardError; end

    def call
      container = context[:container]
      container = container.call self if container.is_a? Proc

      if container
        doc.at_css(container) || raise(ContainerNotFound, "element '#{container}' could not be found in the document, url=#{current_url}")
      elsif doc.name == 'document'
        doc.at_css('body')
      else
        doc
      end
    end
  end
end
