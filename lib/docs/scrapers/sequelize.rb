module Docs
  class Sequelize < UrlScraper
    self.name = 'Sequelize'
    self.slug = 'sequelize'
    self.type = 'simple'
    self.release = '5.19.6'
    self.base_url = 'https://sequelize.org/master/'
    self.links = {
      home: 'https://sequelize.org/',
      code: 'https://github.com/sequelize/sequelize/'
    }

    # List of content filters (to be applied sequentially)
    html_filters.push 'sequelize/entries', 'sequelize/clean_html'

    # Wrapper element that holds the main content
    options[:container] = '.content'

    # License information that appears appears at the bottom of the entry page
    options[:attribution] = <<-HTML
      Copyright &copy; 2014&ndash;present Sequelize contributors<br>
      Licensed under the MIT License.
    HTML

    # Method to fetch the most recent version of the project
    def get_latest_version(opts)
     get_npm_version('sequelize', opts)
    end
  end
end
