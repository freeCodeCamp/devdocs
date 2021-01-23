module Docs
  class Ansible < UrlScraper
    self.name = 'Ansible'
    self.type = 'sphinx'
    self.links = {
      home: 'https://www.ansible.com/',
      code: 'https://github.com/ansible/ansible'
    }

    html_filters.push 'ansible/entries', 'sphinx/clean_html', 'ansible/clean_html'

    options[:attribution] = <<-HTML
      &copy; 2012&ndash;2018 Michael DeHaan<br>
      &copy; 2018&ndash;2019 Red Hat, Inc.<br>
      Licensed under the GNU General Public License version 3.
    HTML

    options[:skip] = %w(
      installation_guide/index.html
      reference_appendices/glossary.html
      reference_appendices/faq.html
      reference_appendices/tower.html
      user_guide/quickstart.html
      modules/modules_by_category.html
      modules/list_of_all_modules.html
      collections/all_plugins.html
      collections/index_vars.html)

    options[:skip_patterns] = [
      /\Acommunity.*/i,
      /\Adev_guide.*/i,
      /\Aroadmap.*/i,
    ]

    version '2.10' do
      self.release = '2.10.5'
      self.base_url = "https://docs.ansible.com/ansible/#{version}/"
    end

    version '2.9' do
      self.release = '2.9.15'
      self.base_url = "https://docs.ansible.com/ansible/#{version}/"
    end

    version '2.8' do
      self.release = '2.8.16'
      self.base_url = "https://docs.ansible.com/ansible/#{version}/"
    end

    version '2.7' do
      self.release = '2.7.17'
      self.base_url = "https://docs.ansible.com/ansible/#{version}/"
    end

    version '2.6' do
      self.release = '2.6.20'
      self.base_url = "https://docs.ansible.com/ansible/#{version}/"
    end

    version '2.5' do
      self.release = '2.5.15'
      self.base_url = "https://docs.ansible.com/ansible/#{version}/"
    end

    version '2.4' do
      self.release = '2.4.6'
      self.base_url = "https://docs.ansible.com/ansible/#{version}/"

      options[:skip] = %w(
        glossary.html
        faq.html
        community.html
        tower.html
        quickstart.html
        list_of_all_modules.html)
      options[:skip_patterns] = []
    end

    def get_latest_version(opts)
      tags = get_github_tags('ansible', 'ansible', opts)
      tags[0]['name'][1..-1]
    end
  end
end
