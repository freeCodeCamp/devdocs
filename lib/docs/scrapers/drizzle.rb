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

    html_filters.push 'drizzle/entries', 'drizzle/clean_html'

    options[:skip] = %w(get-started sustainability latest-releases guides tutorials)
    options[:skip_patterns] = [/\Aget-started\//, /\Aguides\//, /\Atutorials\//]

    options[:attribution] = <<-HTML
      &copy; Drizzle Team<br>
      Licensed under the Apache License, Version 2.0.
    HTML

    # The docs have one copy per SQL dialect, PostgreSQL's at the root
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

    # The site documents the 1.0 release candidates while npm's latest is still 0.x
    def get_latest_version(opts)
      tags = fetch_json('https://registry.npmjs.com/drizzle-orm', opts)['dist-tags']
      tags.values_at('latest', 'rc').compact.max_by { |version| Gem::Version.new(version) }
    end
  end
end
