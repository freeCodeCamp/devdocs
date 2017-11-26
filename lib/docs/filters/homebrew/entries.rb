module Docs
  class Homebrew
    class EntriesFilter < Docs::EntriesFilter
      def get_name
        name = at_css('h1').content.strip
        name.remove! %r{\(.*}
        name
      end

      CONTRIBUTOR_SLUGS = %w(
        How-To-Open-a-Homebrew-Pull-Request
        Formula-Cookbook
        Acceptable-Formulae
        Versions
        Node-for-Formula-Authors
        Python-for-Formula-Authors
        Migrating-A-Formula-To-A-Tap
        Rename-A-Formula
        How-to-Create-and-Maintain-a-Tap
        Brew-Test-Bot
        Prose-Style-Guidelines)

      def get_type
        if CONTRIBUTOR_SLUGS.include?(slug)
          'Contributors'
        else
          'Users'
        end
      end
    end
  end
end
