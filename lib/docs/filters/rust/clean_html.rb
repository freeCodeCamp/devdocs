# frozen_string_literal: true

module Docs
  class Rust
    class CleanHtmlFilter < Filter
      def call
        if slug.start_with?('book') ||  slug.start_with?('reference')
          @doc = at_css('#content main')
        elsif slug == 'error-index'
          css('.error-undescribed').remove

          css('.error-described').each do |node|
            node.before(node.children).remove
          end
        else
          @doc = at_css('#main')

          css('.toggle-wrapper').remove

          css('h1.fqn').each do |node|
            node.content = node.at_css('.in-band').content
          end

          css('.stability .stab').each do |node|
            node.name = 'span'
            node.content = node.content
          end
        end

        # Fix notable trait sections
        css('.method, .rust.trait').each do |node|
          traitSection = node.at_css('.notable-traits')

          if traitSection
            traitSectionContent = traitSection.css('.notable-traits-tooltiptext')
            traitSection.css('.notable-traits-tooltip').remove
            traitSection.add_child(traitSectionContent)
            node.after(traitSection)
          end
        end

        css('.rusttest', '.test-arrow', 'hr').remove

        css('.docblock.attributes').each do |node|
          node.remove if node.content.include?('#[must_use]')
        end

        css('a.header').each do |node|
          unless node.first_element_child.nil?
            node.first_element_child['id'] = node['name'] || node['id']
            node.before(node.children).remove
          end
        end

        css('.docblock > h1:not(.section-header)').each { |node| node.name = 'h4' }
        css('h2.section-header').each { |node| node.name = 'h3' }
        css('h1.section-header').each { |node| node.name = 'h2' }

        if at_css('h1 ~ h1')
          css('h1 ~ h1', 'h2', 'h3').each do |node|
            node.name = node.name.sub(/\d/) { |i| i.to_i + 1 }
          end
        end

        css('> .impl-items', '> .docblock', 'pre > pre', '.tooltiptext', '.tooltip').each do |node|
          # see .tooltip.ignore::after in https://doc.rust-lang.org/rustdoc1.50.0.css
          node.content += ' This example is not tested' if node['class'].include?('ignore')
          node.content += ' This example deliberately fails to compile' if node['class'].include?('compile_fail')
          node.content += ' This example panics' if node['class'].include?('should_panic')
          node.content += ' This code runs with edition ' + node['data-edition'] if node['class'].include?('edition')
          node.before(node.children).remove
        end

        css('h1 > a', 'h2 > a', 'h3 > a', 'h4 > a', 'h5 > a').each do |node|
          node.before(node.children).remove if node.parent.at_css('.srclink').nil?
        end

        css('pre > code').each do |node|
          node.parent['data-language'] = 'rust' if node['class'] && node['class'].include?('rust')
          node.before(node.children).remove
        end

        css('pre').each do |node|
          node.content = node.content
          node['data-language'] = 'rust' if node['class'] && node['class'].include?('rust')
        end

        doc.first_element_child.name = 'h1' if doc.first_element_child.name = 'h2'
        at_css('h1').content = 'Rust Documentation' if root_page?

        css('code.content').each do |node|
          node.name = 'pre'
          node.css('.fmt-newline').each do |line|
            line.inner_html = line.inner_html + "\n"
          end
          node.inner_html = node.inner_html.gsub('<br>', "\n")
          node.content = node.content
        end

        css('.since + .srclink').each do |node|
          node.previous_element.before(node)
        end

        css('.sidebar').remove

        css('.collapse-toggle').remove

        doc
      end
    end
  end
end
