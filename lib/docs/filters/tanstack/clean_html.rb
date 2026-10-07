module Docs
  class Tanstack
    class CleanHtmlFilter < Filter
      # Prism in this repo has jsx, typescript, javascript, and bash. It does not have tsx.
      # json and anything else are passed through unchanged.
      LANGUAGES = {
        'tsx' => 'jsx',
        'ts' => 'typescript',
        'js' => 'javascript',
        'shell' => 'bash',
        'sh' => 'bash',
        'zsh' => 'bash'
      }.freeze

      def call
        title = at_css('h1')
        prose = at_css('.prose')
        raise "missing h1 at #{current_url}" unless title
        raise "missing .prose at #{current_url}" unless prose

        # Drop the global nav, docs sidebar, footer, and sponsor rail. The h1
        # sits just outside `.prose`, so both have to be kept.
        title.remove
        prose.remove
        doc.children.remove
        doc.add_child(title)
        doc.add_child(prose)

        css('.anchor-heading-link').remove

        css('pre.th-code').to_a.each do |node|
          flatten_code(node)
        end

        css('span.border.rounded[class~="bg-gray-500/10"]').each do |node|
          node.name = 'code'
          node.remove_attribute('class')
        end

        # Copy buttons and any "on this page" control that lived inside the prose.
        # External links, including StackBlitz, stay.
        css('button').remove

        doc
      end

      private

      def flatten_code(node)
        language = node['data-language']
        node['data-language'] = LANGUAGES.fetch(language, language) if language
        text = node.content
        node.children.remove
        node.remove_attribute('class')
        code = Nokogiri::XML::Node.new('code', node.document)
        code.content = text
        node.add_child(code)

        # The wrapper holds the copy button and a label: the raw language, or the fence title.
        block = node.ancestors('.codeblock').first
        return unless block

        label = block.at_css('> div:first-child > div')&.content&.strip
        block.replace(node)
        return if label.blank? || label == language

        heading = Nokogiri::XML::Node.new('div', node.document)
        heading['class'] = '_pre-heading'
        heading.content = label
        node.before(heading)
      end
    end
  end
end
