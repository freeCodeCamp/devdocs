module Docs
  class RabbitMq < UrlScraper
    self.name = 'RabbitMQ'
    self.type = 'rabbit_mq'
    self.links = {
      home: 'https://www.rabbitmq.com/',
      code: 'https://github.com/rabbitmq/rabbitmq-server'
    }

    html_filters.push 'rabbit_mq/entries', 'rabbit_mq/clean_html'

    options[:root_path] = '/docs'
    options[:skip_patterns] = [/\/next|\/\d\.\d*/, /rabbitmq\//]
    options[:attribution] = <<-HTML
      Copyright &copy; 2005-2026 Broadcom. All Rights Reserved. The term “Broadcom” refers to Broadcom Inc. and/or its subsidiaries.<br />
      Licensed under the Apache License, Version 2.0.
    HTML

    version do
      self.base_url = 'https://www.rabbitmq.com/docs'
      self.release = '4.3.2'
    end

    def get_latest_version(opts)
      tags = get_github_tags("rabbitmq", "rabbitmq-server", opts)
      tags[0]['name'][1..-1]
    end
  end
end
