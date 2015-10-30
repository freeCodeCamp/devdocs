module Docs
  class Vagrant
    class EntriesFilter < Docs::EntriesFilter
      def get_name
        if slug.start_with?('push/')
          if at_css('h2')
            name = at_css('h2').content.strip
          else
            name = at_css('h1').content.strip
          end
          name
        else
          name = at_css('h1').content.strip
          name
        end
      end

      def get_type
        if slug.start_with?('why-vagrant')
          'Why Vagrant?'
        elsif slug.start_with?('installation')
          'Installation'
        elsif slug.start_with?('getting-started')
          'Getting Started'
        elsif slug.start_with?('cli')
          'Command-Line Interface'
        elsif slug.start_with?('share')
          'Vagrant Share'
        elsif slug.start_with?('vagrantfile')
          'Vagrantfile'
        elsif slug.start_with?('boxes')
          'Boxes'
        elsif slug.start_with?('provisioning')
          'Provisioning'
        elsif slug.start_with?('networking')
          'Networking'
        elsif slug.start_with?('synced-folders')
          'Synced Folders'
        elsif slug.start_with?('multi-machine')
          'Multi-Machine'
        elsif slug.start_with?('providers')
          'Providers'
        elsif slug.start_with?('plugins')
          'Plugins'
        elsif slug.start_with?('push')
          'Push'
        elsif slug.start_with?('other')
          'Other'
        elsif slug.start_with?('vmware')
          'VMware'
        elsif slug.start_with?('docker')
          'Docker'
        elsif slug.start_with?('virtualbox')
          'VirtualBox'
        elsif slug.start_with?('hyperv')
          'Hyper-V'
        else
          'Overview'
        end
      end
    end
  end
end
