# frozen_string_literal: true

module Docs
  class Koa
    class CleanHtmlFilter < Filter
      def call
        fix_homepage if slug.start_with? 'api/index'

        css('[data-language=shell]').each do |node|
          node['data-language'] = 'bash'
        end

        doc
      end

      def fix_homepage
        # Shrink the headers
        for n in (1..5).to_a.reverse
          css("h#{n}").each do |header|
            header.name = "h#{n+1}"
          end
        end

        # Add an introduction
        doc.children.before <<-HTML.strip_heredoc
          <h1>Koa</h1>
          <!-- https://github.com/koajs/koa/blob/841844e/Readme.md -->
          <h2 id="introduction">Introduction</h2>
          <p>
            Expressive HTTP middleware framework for node.js to make web applications and APIs more enjoyable to write. Koa's middleware stack flows in a stack-like manner, allowing you to perform actions downstream then filter and manipulate the response upstream.
          </p>
          <p>
            Only methods that are common to nearly all HTTP servers are integrated directly into Koa's small ~570 SLOC codebase. This includes things like content negotiation, normalization of node inconsistencies, redirection, and a few others.
          </p>
          <p>
            Koa is not bundled with any middleware.
          </p>
        HTML
      end
    end
  end
end
