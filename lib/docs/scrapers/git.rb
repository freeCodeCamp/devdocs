module Docs
  class Git < UrlScraper
    self.type = 'git'
    self.release = '2.51.0'
    self.base_url = 'https://git-scm.com/docs'
    self.initial_paths = %w(
      /git.html
      /git-archimport.html
      /git-cherry.html
      /git-citool.html
      /git-column.html
      /git-cvsexportcommit.html
      /git-for-each-repo.html
      /git-get-tar-commit-id.html
      /git-http-fetch.html
      /git-http-push.html
      /git-merge-file.html
      /git-merge-index.html
      /git-merge-one-file.html
      /git-merge-tree.html
      /git-mktree.html
      /git-p4.html
      /git-pack-redundant.html
      /git-quiltimport.html
      /git-replay.html
      /git-sh-i18n.html
      /git-sh-i18n--envsubst.html
      /git-sh-setup.html
      /git-show-index.html
      /git-unpack-file.html
      /git-verify-commit.html
      /gitformat-index.html
      /scalar.html
    )
    self.links = {
      home: 'https://git-scm.com/',
      code: 'https://github.com/git/git'
    }

    html_filters.push 'git/entries', 'git/clean_html'

    options[:container] = '#content'
    options[:only_patterns] = [/\A\/[^\/]+\z/]
    options[:skip] = %w(/howto-index.html)

    # https://github.com/git/git?tab=License-1-ov-file#readme
    # NOT https://github.com/git/git-scm.com/blob/gh-pages/MIT-LICENSE.txt
    options[:attribution] = <<-HTML
      &copy; 2005&ndash;2025 Linus Torvalds and others<br>
      Licensed under the GNU General Public License version 2.
    HTML

    def get_latest_version(opts)
      doc = fetch_doc('https://git-scm.com/', opts)
      doc.at_css('.version').content.strip
    end
  end
end
