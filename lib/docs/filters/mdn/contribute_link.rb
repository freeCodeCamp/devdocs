module Docs
  class Mdn
    class ContributeLinkFilter < Filter
      def call
        return html if current_url.host != 'developer.mozilla.org'

        html << <<-HTML.strip_heredoc
          <div class="_attribution">
            <p class="_attribution-p">
              <a href="#{current_url}$edit" class="_attribution-link">Edit this page on MDN</a>
            </p>
          </div>
        HTML

        html
      end
    end
  end
end
