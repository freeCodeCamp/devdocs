module Docs
  class ContainerFilter < Filter
    class ContainerNotFound < StandardError; end

    def call
      container = context[:container]
      container = container.call self if container.is_a? Proc

      if container
        doc.at_css(container) || raise(ContainerNotFound, "element '#{container}' could not be found in the document, url=#{current_url}")
      else
        doc
      end
    end
  end
end
