module Docs
  class Npm < UrlScraper
    self.name = 'npm'
    self.type = 'npm'
    self.release = '7.3.0'
    self.base_url = 'https://docs.npmjs.com/'
    self.force_gzip = true
    self.links = {
      home: 'https://www.npmjs.com/',
      code: 'https://github.com/npm/npm'
    }

    html_filters.push 'npm/entries', 'npm/clean_html'

    options[:max_image_size] = 130_000

    options[:skip] = [
      'all',
      'misc/index',
      'cli',
      'orgs/',
      'removing-members-from-your-org',
      'adding-members-to-your-org',
      'downloading-and-installing-packages'
    ]

    options[:skip_patterns] = [
      /\Aenterprise/,
      /\Acompany/,
      /\Apolicies/
    ]

    options[:attribution] = <<-HTML
      &copy; npm, Inc. and Contributors<br>
      Licensed under the npm License.<br>
      npm is a trademark of npm, Inc.
    HTML

    #  fix duplicates
    options[:fix_urls] = -> (url) do
      url.sub!('private-modules/intro', 'creating-and-publishing-private-packages')
      url.sub!('cli/audit', 'cli/v6/commands/npm-audit')
      url.sub!('cli/uninstall', 'cli/v6/commands/npm-uninstall')
      url.sub!('cli/npm', 'cli/v6/commands/npm')
      url.sub!('cli-documentation', 'cli/v6')
      url.sub!('misc/registry', 'cli/v6/using-npm/registry')
      url.sub!('cli/adduser', 'cli/v6/commands/npm-adduser')
      url.sub!('cli/profile', 'cli/v6/commands/npm-profile')
      url.sub!('cli/token', 'cli/v6/commands/npm-token')
      url.sub!('cli/publish', 'cli/v6/commands/npm-publish')
      url.sub!('cli/unpublish', 'cli/v6/commands/npm-unpublish')
      url.sub!('cli/deprecate', 'cli/v6/commands/npm-deprecate')
      url.sub!('cli/access', 'cli/v6/commands/npm-access')
      url.sub!('misc/config', 'cli/v6/using-npm/config')
      url.sub!('misc/developers', 'cli/v6/using-npm/developers')
      url.sub!('managing-team-access-to-packages', 'managing-team-access-to-organization-packages')
      url.sub!('accepting-or-rejecting-an-org-invitation', 'accepting-or-rejecting-an-organization-invitation')
      url.sub!('org-roles-and-permissions', 'organization-roles-and-permissions')
      url.sub!('upgrading-to-a-paid-org-plan', 'upgrading-to-a-paid-organization-plan')
      url.sub!('files/package.json', 'cli/v6/configuring-npm/package-json')
      url.sub!('managing-team-access-to-org-packages', 'managing-team-access-to-organization-packages')
      url.sub!('about-package-json-and-package-lock-json-files', 'creating-a-package-json-file')
      url.sub!('cli/team', 'cli/v6/commands/npm-team')
      url.sub!('cli/version', 'cli/v6/commands/npm-version')
      url.sub!('creating-a-packge-json-file', 'cli/v6/configuring-npm/package-json')
      url.sub!('cli/outdated', 'cli/v6/commands/npm-outdated')
      url.sub!('cli/owner', 'cli/v6/commands/npm-owner')
      url.sub!('cli/install', 'cli/v6/commands/npm-install')
      url.sub!('cli/update', 'cli/v6/commands/npm-update')
      url.sub!('cli/config', 'cli/v6/commands/npm-config')
      url.sub!('cli/dist-tag', 'cli/v6/commands/npm-dist-tag')
      url
    end

    def get_latest_version(opts)
      get_latest_github_release('npm', 'cli', opts)
    end

  end
end
