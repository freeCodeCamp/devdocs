module Docs
  class Ansible < UrlScraper
    self.name = 'Ansible'
    self.type = 'sphinx'
    self.links = {
      home: 'https://www.ansible.com/',
      code: 'https://github.com/ansible/ansible'
    }

    html_filters.push 'ansible/entries', 'sphinx/clean_html'

    options[:skip] = %w(
      glossary.html
      faq.html
      community.html
      tower.html
      quickstart.html
      list_of_all_modules.html)

    options[:attribution] = <<-HTML
      &copy; 2012&ndash;2018 Michael DeHaan<br>
      &copy; 2018 Red Hat, Inc.<br>
      Licensed under the GNU General Public License version 3.
    HTML

    version '2.4' do
      self.release = '2.4.3'
      self.base_url = 'https://docs.ansible.com/ansible/2.4/'
    end
  end
end
