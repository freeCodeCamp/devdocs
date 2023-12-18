module Docs
  class Bazel
    class EntriesFilter < Docs::EntriesFilter

      def get_name
        at_css('h1').content.strip
      end

      def get_type
        "Build encyclopedia"
      end

      def additional_entries
        entries = []

        special_page_types = {
          'functions' => 'Function',
          'make-variables' => 'Make Variable',
          'common-definitions' => 'Common Definition',
        }
        page_type = special_page_types[subpath]
        unless page_type.nil?
          # only first ul
          at_css('.devsite-article-body > ul').css('li > a').each do |node|
            entries << [node.content.strip, node['href'].sub('#', ''), page_type]
          end
        end
        css('h2#rules + ul > li > a').each do |node|
          entries << [node.content.strip, node['href'].sub('#', ''), "Rule"]
        end

        entries
      end

    end
  end
end
