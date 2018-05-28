module Docs
  class Postgresql
    class NormalizeClassNamesFilter < Filter
      def call
        doc.css('*').each do |node|
          node['class'] = node['class'].downcase if node['class'].present?
        end

        doc
      end
    end
  end
end
