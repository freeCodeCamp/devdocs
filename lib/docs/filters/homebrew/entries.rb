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
        Cask-Cookbook
        Acceptable-Formulae
        Acceptable-Casks
        License-Guidelines
        Versions
        Deprecating-Disabling-and-Removing-Formulae
        Node-for-Formula-Authors
        Python-for-Formula-Authors
        Brew-Livecheck
        Autobump
        Migrating-A-Formula-To-A-Tap
        Rename-A-Formula
        Building-Against-Non-Homebrew-Dependencies
        How-to-Create-and-Maintain-a-Tap
        Brew-Test-Bot
        Prose-Style-Guidelines
        Typechecking
        Reproducible-Builds
      )

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
