module Docs
  class CraftCms < UrlScraper
    self.type = 'craftcms'

    options[:attribution] = <<-HTML
      &copy; 2012&ndash;2016 by Pixel &amp; Tonic, Inc<br>
      Licensed under Craft License Agreement version 2.0.1.
    HTML

    options[:skip_patterns] = [/features/, /support/, /pricing/, /introduction/, /community/, /search/, /news/, /changelog/, /index/]
    options[:container] = 'div[id=content]'

# For Version 2
    version '2' do
      self.release = '2'
      self.base_url = 'https://craftcms.com/'
      self.root_path = 'docs'

      html_filters.push 'craft_cms/clean_html_v2', 'craft_cms/entries_v2'
    end
    
# For Version 3
    version '3' do
      self.release = '3'
      self.base_url = 'https://craftcms.com/3/'
      self.root_path = 'docs'
      
      options[:skip] = %w(docs/installing-and-updating)

      html_filters.push 'craft_cms/clean_html_v3', 'craft_cms/entries_v3'
    end

  end
end
