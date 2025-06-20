module Docs
  class Ramda
    class EntriesFilter < Docs::EntriesFilter
      def additional_entries
        css('ul.toc li').map do |node|
          # As of 2025-06-20, `data-category` attribute is missing on https://ramdajs.com/ for Ramda versions < 0.29.0.
          # This results in missing type for entries – and docs cannot be generated.
          ["R.#{node['data-name']}", node['data-name'], node['data-category']]
        end
      end
    end
  end
end
