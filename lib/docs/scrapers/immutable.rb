module Docs
  class Immutable < UrlScraper
    self.name = 'Immutable.js'
    self.slug = 'immutable'
    self.type = 'simple'
    self.release = '3.8.1'
    self.base_url = 'https://facebook.github.io/immutable-js/docs/'
    self.links = {
      home: 'https://facebook.github.io/immutable-js/',
      code: 'https://github.com/facebook/immutable-js'
    }

    html_filters.push 'immutable/clean_html', 'immutable/entries', 'title'

    options[:skip_links] = true
    options[:container] = '.docContents'
    options[:root_title] = 'Immutable.js'

    options[:attribution] = <<-HTML
      &copy; 2014&ndash;2015 Facebook, Inc.<br>
      Licensed under the 3-clause BSD License.
    HTML

    stub '' do
      capybara = load_capybara_selenium
      capybara.app_host = 'https://facebook.github.io'
      capybara.visit(URL.parse(self.base_url).path)
      capybara.execute_script <<-JS
        var content, event, links, link;

        event = document.createEvent('Event');
        event.initEvent('hashchange', false, false);

        content = document.querySelector('.docContents section').cloneNode(true);
        links = Array.prototype.slice.call(document.querySelectorAll('.sideBar .scrollContent a'));

        while (link = links.shift()) {
          if (!document.body.contains(link)) {
            document.body.appendChild(link);
          }

          link.click();
          dispatchEvent(event);
          content.innerHTML += document.querySelector('.docContents').innerHTML;

          document.querySelectorAll('.sideBar .scrollContent .groupTitle').forEach(function(el) {
            if (el.textContent == 'Types') {
              Array.prototype.unshift.apply(links, Array.prototype.slice.call(el.parentNode.querySelectorAll('a')));
            }
          });
        }

        document.querySelector('.docContents').innerHTML = content.innerHTML;
      JS
      capybara.html
    end
  end
end
