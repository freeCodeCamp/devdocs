module Docs
  class Love
    class EntriesFilter < Docs::EntriesFilter
      def get_type
        if TYPE_OVERRIDE.key?(slug) then
          return TYPE_OVERRIDE[slug]
        elsif m = slug.match(/\A(love\.\w+)\z/) then
          # modules and funcions
          return LOVE_MODULES.include?(m[1]) ? m[1] : 'love'
        elsif m = slug.match(/\A(love\.\w+)\.(\w+)/) then
          # functions in modules
          return m[1]
        elsif context[:list_classes] and (m = slug.match(/\A\(?([A-Z]\w+)\)?(\:\w+)?/)) then
          # classes, their members and enums
          return m[1] unless m[1].include?('_')
        end
        # usually this shouldn't happen
        "Other"
      end
    end
  end
end
