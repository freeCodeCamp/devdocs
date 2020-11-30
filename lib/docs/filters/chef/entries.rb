module Docs
  class Chef
    class EntriesFilter < Docs::EntriesFilter

      def get_name
        at_css('h1').content
      end

      def get_type

        case slug
        when /automate/
          'Chef Automate'
        when /compliance/
          'Chef Compliance'
        when /desktop/
          'Chef Desktop'
        when /habitat/
          'Chef Habitat'
        when /inspec/
          'Chef InSpec'
        when /workstation/
          'Chef Workstation'
        when /effortless/
          'Effortless Pattern'
        else
          'Chef Infra'
        end

      end

    end
  end
end
