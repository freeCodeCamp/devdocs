module Docs
    class Nextjs
        class EntriesFilter < Docs::EntriesFilter
            def get_name
              at_css('h1').content
            end

            def get_type
                get_name
            end
        end
    end
end