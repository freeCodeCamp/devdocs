module Docs
  class Marionette
    class EntriesFilter < Docs::EntriesFilter
      def get_name
        name = at_css('h1').content.strip
        name.remove!(/Marionette./)
        name = name[0].upcase + name.from(1)
        name
      end
    end
  end
end
