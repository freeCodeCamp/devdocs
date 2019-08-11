module Docs
  class Terraform
    class EntriesFilter < Docs::EntriesFilter

      # Some providers have non-trivial mappings between the directory they live in and their name
      # Anything *not* in this list will be capitalized instead.
      PROVIDER_NAME_MAP = {
        'aws'              => 'AWS',
        'azure'            => 'Azure (Legacy)',
        'azurerm'          => 'Azure',
        'centurylinkcloud' => 'CenturyLinkCloud',
        'cloudscale'       => 'CloudScale.ch',
        'cloudstack'       => 'CloudStack',
        'dme'              => 'DNSMadeEasy',
        'dns'              => 'DNS',
        'dnsimple'         => 'DNSimple',
        'do'               => 'DigitalOcean',
        'github'           => 'GitHub',
        'google'           => 'Google Cloud',
        'http'             => 'HTTP',
        'mysql'            => 'MySQL',
        'newrelic'         => 'New Relic',
        'oneandone'        => '1&1',
        'opentelekomcloud' => 'OpenTelekomCloud',
        'opsgenie'         => 'OpsGenie',
        'opc'              => 'Oracle Public Cloud',
        'oraclepaas'       => 'Oracle Cloud Platform',
        'ovh'              => 'OVH',
        'pagerduty'        => 'PagerDuty',
        'panos'            => 'Palo Alto Networks',
        'postgresql'       => 'PostgreSQL',
        'powerdns'         => 'PowerDNS',
        'profitbricks'     => 'ProfitBricks',
        'rabbitmq'         => 'RabbitMQ',
        'softlayer'        => 'SoftLayer',
        'statuscake'       => 'StatusCake',
        'tls'              => 'TLS',
        'ultradns'         => 'UltraDNS',
        'vcd'              => 'VMware vCloud Director',
        'nsxt'             => 'VMware NSX-T',
        'vsphere'          => 'VMware vSphere',
      }

      # Some providers have a lot (> 100) entries, which makes browsing them unwieldy.
      # Any present in the list below will have an extra set of types added, breaking the pages out into the different
      # products they offer.
      LARGE_PROVIDERS = {
        "aws"     => true,
        "azurerm" => true,
        "google"  => true,
      }


      def get_name
        name ||= at_css('#inner h1').content
        name.remove! "» "
        name.remove! "Data Source: "
        name
      end

      def get_type
        category, subcategory, subfolder, page = *slug.split('/')
        provider = page ? subcategory : category
        nice_provider = PROVIDER_NAME_MAP[provider] || provider.capitalize

        if LARGE_PROVIDERS[provider]
          category_node = at_css('ul > li > ul > li.active')
          parent_node = category_node.parent.previous_element if category_node
          nice_provider = nice_provider + ": #{parent_node.content}" if category_node
        end

        nice_provider
      end
    end
  end
end
