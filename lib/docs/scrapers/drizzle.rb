module Docs
  class Drizzle < UrlScraper
    self.name = 'Drizzle ORM'
    self.slug = 'drizzle'
    self.type = 'simple'
    self.release = '1.0.0-rc.4'
    self.root_path = 'overview'
    self.links = {
      home: 'https://orm.drizzle.team/',
      code: 'https://github.com/drizzle-team/drizzle-orm'
    }

    # The entries filter reads the sidebar, which the clean_html one removes
    html_filters.push 'drizzle/entries', 'drizzle/clean_html'

    # Left out:
    # - the "Get started" page, which links to step-by-step tutorials
    #   (get-started/*) covering what the drivers' pages (Connect) document
    # - the sponsors (sustainability) and the changelog (latest-releases)
    # - the guides and tutorials, articles which every dialect lists whichever
    #   dialect they are about
    options[:skip] = %w(get-started sustainability latest-releases guides tutorials)
    options[:skip_patterns] = [/\Aget-started\//, /\Aguides\//, /\Atutorials\//]

    # https://github.com/drizzle-team/drizzle-orm/blob/main/LICENSE
    options[:attribution] = <<-HTML
      &copy; Drizzle Team<br>
      Licensed under the Apache License, Version 2.0.
    HTML

    # The documentation exists in one copy per SQL dialect, picked with the
    # website's dialect switcher: the pages, the sidebar and the code examples
    # differ from one dialect to the other. PostgreSQL's is at the root of
    # /docs/ and the others are in a subdirectory of it.
    version 'PostgreSQL' do
      self.base_url = 'https://orm.drizzle.team/docs/'
      options[:skip_patterns] += [/\A(?:mysql|sqlite|singlestore|mssql|cockroach)\//]
    end

    version 'MySQL' do
      self.base_url = 'https://orm.drizzle.team/docs/mysql/'
    end

    version 'SQLite' do
      self.base_url = 'https://orm.drizzle.team/docs/sqlite/'
    end

    version 'SingleStore' do
      self.base_url = 'https://orm.drizzle.team/docs/singlestore/'
    end

    version 'MSSQL' do
      self.base_url = 'https://orm.drizzle.team/docs/mssql/'
    end

    version 'CockroachDB' do
      self.base_url = 'https://orm.drizzle.team/docs/cockroach/'
    end

    # The website documents the 1.0 release candidates (drizzle-orm@rc), while
    # npm's latest version is still a 0.x one.
    def get_latest_version(opts)
      tags = fetch_json('https://registry.npmjs.com/drizzle-orm', opts)['dist-tags']
      tags.values_at('latest', 'rc').compact.max_by { |version| Gem::Version.new(version) }
    end
  end
end
