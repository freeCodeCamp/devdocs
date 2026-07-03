module Docs
  class Coldfusion < UrlScraper
    self.name = 'ColdFusion'
    self.slug = 'coldfusion'
    self.type = 'simple'
    self.base_url = 'https://cfdocs.org/'
    self.root_path = 'index.cfm'
    self.links = {
      home: 'https://cfdocs.org/',
      code: 'https://github.com/foundeo/cfdocs'
    }
    self.release = '2026-04-30'

    html_filters.push 'coldfusion/entries', 'coldfusion/clean_html'

    options[:root_title] = 'ColdFusion'

    # cfdocs links categories with an encoded dash (e.g. /array%2Dfunctions);
    # decode and clean those so entry paths look like /array-functions.
    options[:decode_and_clean_paths] = true

    # cfdocs.org renders a page for every tag/function/guide at the site root,
    # e.g. /hash or /cfhtmltopdf. Category "listing" pages (such as /tags,
    # /functions and /array-functions) are crawled to discover entries, but the
    # Entries filter excludes them from the index.
    #
    # Skip site chrome, utilities, reports and other non-reference pages.
    options[:skip] = %w(
      404.cfm contributors.cfm trycf.cfm ucase.cfm llms.cfm
      how-to-contribute opensearch.xml robots.txt)

    options[:skip_patterns] = [
      /\Aassets\b/,
      /\Areports\b/,
      /\Autilities\b/,
      /\Aslack\b/,
      /openimage/,
      /\.json\z/,
      /\.png\z/,
      /\.ico\z/,
      /\.xml\z/,
      /\.css\z/,
      /\.js\z/
    ]

    options[:attribution] = <<-HTML
      &copy; 2012&ndash;present Foundeo, Inc. and the CFDocs contributors.<br>
      Licensed under the MIT License.<br>
      ColdFusion is a trademark of Adobe Systems Incorporated.
    HTML

    def get_latest_version(opts)
      # CFDocs is continuously updated and has no formal version number; use the
      # date of the latest commit as a proxy version.
      get_latest_github_commit_date('foundeo', 'cfdocs', opts)
    end
  end
end
