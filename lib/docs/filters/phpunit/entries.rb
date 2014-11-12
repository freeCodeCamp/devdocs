module Docs
  class Phpunit
    class EntriesFilter < Docs::EntriesFilter
      def additional_entries
        entries = []

        if at_css('h1')
          type = at_css('h1').content.gsub(/Appendix \w+\. /, '')

          css('h2').each do |node|
            name = node.content
            id = name.parameterize
            entries << [name, id, type]
          end
        end
        entries
      end
    end
  end
end
