module Docs
  class Drupal
    class EntriesFilter < Docs::EntriesFilter

      def get_name
        name = css('#page-subtitle').first.content
        name.remove! 'function '
        name
      end

      def path
        Drupal::fixUri(result[:path])
      end

      def get_type
        type = css('dl[api-related-topics] dt')
        type.first ? type.first.content : nil
      end

      def include_default_entry?
        !initial_page?
      end
    end
  end
end
