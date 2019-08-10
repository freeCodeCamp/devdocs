module Docs
  class Homebrew
    class EntriesFilter < Docs::EntriesFilter
      def get_name
        header = at_css('h1')
        name = header.nil? ? current_url.normalized_path[1..-1].gsub(/-/, ' ') : header.content.strip
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
        Building-Against-Non-Homebrew-Dependencies
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
