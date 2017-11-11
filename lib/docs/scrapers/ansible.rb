module Docs
  class Ansible < UrlScraper
    self.name = 'Ansible'
    self.type = 'sphinx'
    self.release = '2.4.0'
    self.base_url = 'https://docs.ansible.com/ansible/latest/'
    self.links = {
      home: 'https://www.ansible.com/',
      code: 'https://github.com/ansible/ansible'
    }

    html_filters.push 'ansible/entries', 'ansible/clean_html', 'sphinx/clean_html'

    options[:container] = '#page-content'

    options[:skip] = %w(
      glossary.html
      faq.html
      community.html
      tower.html
      quickstart.html
      list_of_all_modules.html)

    options[:attribution] = <<-HTML
      &copy; 2012&ndash;2017 Michael DeHaan<br>
      &copy; 2017 Red Hat, Inc.<br>
      Licensed under the GNU General Public License version 3.
    HTML
  end
end
