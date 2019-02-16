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
      &copy; 2018 Red Hat, Inc.<br>
      Licensed under the GNU General Public License version 3.
    HTML

    version '2.7' do
      self.release = '2.7.1'
      self.base_url = 'https://docs.ansible.com/ansible/2.7/'

      options[:skip] = %w(
        installation_guide/index.html
        reference_appendices/glossary.html
        reference_appendices/faq.html
        reference_appendices/tower.html
        user_guide/quickstart.html
        modules/modules_by_category.html
        modules/list_of_all_modules.html)

      options[:skip_patterns] = [
        /\Acommunity.*/i,
        /\Adev_guide.*/i,
        /\Aroadmap.*/i,
      ]
    end

    version '2.6' do
      self.release = '2.6.7'
      self.base_url = 'https://docs.ansible.com/ansible/2.6/'

      options[:skip] = %w(
        installation_guide/index.html
        reference_appendices/glossary.html
        reference_appendices/faq.html
        reference_appendices/tower.html
        user_guide/quickstart.html
        modules/modules_by_category.html
        modules/list_of_all_modules.html)

      options[:skip_patterns] = [
        /\Acommunity.*/i,
        /\Adev_guide.*/i,
        /\Aroadmap.*/i,
      ]
    end

    version '2.5' do
      self.release = '2.5.3'
      self.base_url = 'https://docs.ansible.com/ansible/2.5/'

      options[:skip] = %w(
        installation_guide/index.html
        reference_appendices/glossary.html
        reference_appendices/faq.html
        reference_appendices/tower.html
        user_guide/quickstart.html
        modules/modules_by_category.html
        modules/list_of_all_modules.html)

      options[:skip_patterns] = [
        /\Acommunity.*/i,
        /\Adev_guide.*/i,
        /\Aroadmap.*/i,
      ]
    end

    version '2.4' do
      self.release = '2.4.3'
      self.base_url = 'https://docs.ansible.com/ansible/2.4/'

      options[:skip] = %w(
        glossary.html
        faq.html
        community.html
        tower.html
        quickstart.html
        list_of_all_modules.html)
    end
  end
end
