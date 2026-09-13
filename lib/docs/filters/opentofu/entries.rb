module Docs
  class Opentofu
    class EntriesFilter < Docs::EntriesFilter
      def get_name
        at_css('main article h1').content
      end

      def get_type
        segments = slug.split('/')
        if segments[0..1] == ['language', 'functions']
          # We have too many functions (120+ out of ~300 pages)
          "Function"
        elsif segments.first == 'cli'
          "CLI"
        else
          segments.first.titlecase
        end
      end
    end
  end
end
