# coding: utf-8
module Docs
  class Php
    class CleanHtmlFilter < Filter

      def call
        root_page? ? root : other
        doc
      end

      def root
        doc.inner_html = ' '
      end

      def other
        # css('.manualnavbar:first-child', '.manualnavbar .up', '.manualnavbar .home', 'hr').remove

        css('#breadcrumbs').remove

        css('.nav').remove

        # Remove code highlighting
        br = /<br\s?\/?>/i
        css('.phpcode', 'div.methodsynopsis').each do |node|
          node.name = 'pre'
          node.inner_html = node.inner_html.gsub(br, "\n")
          node.content = node.content.strip
          node['data-language'] = 'php'
        end

        css('> h2:first-child.title').each do |node|
          node.name = 'h1'
        end

        css('div.partintro', 'div.section', 'h1 a').each do |node|
          node.before(node.children).remove
        end

        css('.title + .verinfo + .title').each do |node|
          node.after(node.previous_element)
        end

      end

    end
  end
end
