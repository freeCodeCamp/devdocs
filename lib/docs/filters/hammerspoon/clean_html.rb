module Docs
  class Hammerspoon
    class CleanHtmlFilter < Filter
      def call

        at_css("#search").parent.remove if at_css("#search")

        # Remove script tags for functionality not needed in DevDocs
        css("script").remove

        # Remove styles that are not necessary
        css("style").remove

        # Modify the main title - remove leading "docs » "
        at_css("h1").content = at_css("h1").content.sub("docs » ", "")

        # add syntax highlighting
        css("pre").each do |pre|
          if pre.get_attribute("lang") == "lua"
            pre.set_attribute("data-language", "lua")
            pre.remove_attribute("lang")
          else
            if pre.get_attribute("lang")
              # logger.warn("unrecognised pre.get_attribute('lang') = #{pre.get_attribute("lang")}")
            end
          end
        end

        doc
      end

    end
  end
end
