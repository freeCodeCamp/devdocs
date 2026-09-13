module Docs
  class Homebrew
    class EntriesFilter < Docs::EntriesFilter
      def get_name
        header = at_css('h1')

        if current_url.path.start_with?('/rubydoc')
          # Titles in rubydoc content follow a different format, with a bit of cleanup needed.
          name = header
            .content
            .gsub('Class: ', '')
            .gsub('Module: ', '')
            .gsub('Exception: ', '')
            .gsub(' Private', '')
        else
          name = header.nil? ? current_url.normalized_path[1..-1].gsub(/-/, ' ') : header.content.strip
          name.remove! %r{\(.*}
        end

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
        Typechecking
        Reproducible-Builds
      )

      def get_type
        if current_url.path.start_with?('/rubydoc')
          header = at_css('h1').content
          if header.start_with?('Module')
            'API Modules'
          elsif header.start_with?('Class')
            'API Classes'
          else
            'API Exceptions'
          end
        elsif CONTRIBUTOR_SLUGS.include?(slug)
          'Contributors'
        else
          'Users'
        end
      end
    end
  end
end
