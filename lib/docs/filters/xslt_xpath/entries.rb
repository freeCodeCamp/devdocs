module Docs
  class XsltXpath
    class EntriesFilter < Docs::EntriesFilter
      def get_name
        name = super
        name.remove! 'XPath.'
        name.remove! 'XSLT.'
        name.remove! 'Axes.'
        name.prepend 'xsl:' if slug =~ /\AXSLT\/[a-z]/
        name << '()' if name.gsub!('Functions.', '')
        name
      end

      def get_type
        if slug =~ /\AXSLT\/[a-z]/
          'XSLT Elements'
        elsif slug.start_with?('XPath/Axes')
          'XPath Axes'
        elsif slug.start_with?('XPath/Functions')
          'XPath Functions'
        else
          'Miscellaneous'
        end
      end
    end
  end
end
