module Docs
  class Ansible < UrlScraper
    self.name = 'Ansible'
    self.type = 'ansible'
    self.release = '2.1.0'
    self.base_url = 'http://docs.ansible.com/ansible/'
    self.root_path = 'intro.html'
    self.links = {
      home: 'http://docs.ansible.com',
      code: 'https://github.com/ansible/ansible'
    }

    html_filters.push 'ansible/clean_html', 'ansible/entries'

    options[:title] = 'Ansible'
    options[:container] = '#page-content'
    options[:skip] = [
      'glossary.html',
      'faq.html',
      'community.html',
      'tower.html',
      'quickstart.html'
    ]

    options[:attribution] = <<-HTML
      &copy; Michael DeHaan<br>
      Licensed under the GNU General Public License v.3.
    HTML
  end
end
