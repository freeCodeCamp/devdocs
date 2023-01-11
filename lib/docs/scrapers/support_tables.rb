require 'yajl/json_gem'

module Docs
  class SupportTables < Scraper
    include Instrumentable

    self.name = 'Support Tables'
    self.slug = 'browser_support_tables'
    self.type = 'support_tables'
    self.release = '1.0.30001442'
    self.base_url = 'https://github.com/Fyrd/caniuse/raw/main/'

    # https://github.com/Fyrd/caniuse/blob/main/LICENSE
    options[:attribution] = <<-HTML
      &copy; 2020 Alexis Deveria<br>
      Licensed under the Creative Commons Attribution 4.0 International License.
    HTML

    def build_pages
      url = 'https://github.com/Fyrd/caniuse/raw/main/data.json'
      instrument 'running.scraper', urls: [url]

      response = Request.run(url)
      instrument 'process_response.scraper', response: response

      data = JSON.parse(response.body)
      instrument 'queued.scraper', urls: data['data'].keys

      data['agents']['and_chr']['browser'] = 'Android Chrome'
      data['agents']['and_ff']['browser'] = 'Android Firefox'
      data['agents']['and_uc']['browser'] = 'Android UC Browser'
      data['desktop_agents'] = data['agents'].select { |_, agent| agent['type'] == 'desktop' }
      data['mobile_agents']  = data['agents'].select { |–, agent| agent['type'] == 'mobile' }
      data['total_versions'] = data['agents']['firefox']['versions'].length

      index_page = {
        path: 'index',
        store_path: 'index.html',
        output: ERB.new(INDEX_PAGE_ERB, trim_mode:">").result(binding),
        entries: [Entry.new(nil, 'index', nil)]
      }

      yield index_page

      data['data'].each do |feature_id, feature|
        url = "https://github.com/Fyrd/caniuse/raw/main/features-json/#{feature_id}.json"

        response = Request.run(url)
        instrument 'process_response.scraper', response: response

        feature = JSON.parse(response.body)

        name = feature['title']
        type = feature['categories'].find { |category| name.include?(category) } || feature['categories'].first

        page = {
          path: feature_id,
          store_path: "#{feature_id}.html",
          output: ERB.new(PAGE_ERB, trim_mode:">").result(binding).split("\n").map(&:strip).join("\n"),
          entries: [Entry.new(name, feature_id, type)]
        }

        yield page
      end
    end

    def md_to_html(str)
      str = CGI::escape_html(str.strip)
      str.gsub! %r{`(.*?)`}, '<code>\1</code>'
      str.gsub! %r{\n\s*\n}, '</p><p>'
      str.gsub! "\n", '<br>'
      str.gsub! %r{\[(.+?)\]\((.+?)\)}, '<a href="\2">\1</a>'
      str
    end

    def support_to_css_class(support)
      support.select { |s| s.length == 1 }.join(' ')
    end

    def support_to_note_indicators(support)
      notes = support.select { |s| s.start_with?('#') }.map { |s| s[1..-1] }
      notes << '*' if support.include?('x')
      "<sup>(#{notes.join(',')})</sup>" if notes.present?
    end

    INDEX_PAGE_ERB = <<-HTML.strip_heredoc
      <h1>Browser support tables</h1>
    HTML

    PAGE_ERB = <<-HTML.strip_heredoc
      <h1><%= feature['title'] %></h1>

      <p><%= md_to_html feature['description'] %></p>

      <table>
        <% if feature['spec'].present? %>
          <tr>
            <th>Spec</th>
            <td><a href="<%= feature['spec'] %>"><%= feature['spec'] %></a></td>
          </tr>
        <% end %>

        <% if feature['status'].present? %>
          <tr>
            <th>Status</th>
            <td><%= data['statuses'][feature['status']] %></td>
          </tr>
        <% end %>
      </table>

      <% ['desktop', 'mobile'].each do |type| %>
        <table class="stats">
          <tr>
            <% data["\#{type}_agents"].each do |agent_id, agent| %>
              <th><%= agent['browser'] %></th>
            <% end %>
          </tr>
          <% (0...(data['total_versions'])).reverse_each do |i| %>
            <% next if data["\#{type}_agents"].none? { |_, agent| agent['versions'][i] } %>
            <% if i == (data['total_versions'] - 8) %>
              <tr class="show-all">
                <th class="show-all" colspan="<%= data["\#{type}_agents"].length %>">
                  <a href="#" class="show-all">Show all</a>
                </th>
              </tr>
            <% end %>
            <tr<%= ' class="current"' if i == (data['total_versions'] - 4) %>>
              <% data["\#{type}_agents"].each do |agent_id, agent| %>
                <% version = agent['versions'][i] %>
                <% if version %>
                  <% support = feature['stats'][agent_id][version].split(' ') %>
                  <% feature['prefix'] = true if support.include?('x') %>
                  <td class="<%= support_to_css_class(support)  %>"><%= version %> <%= support_to_note_indicators(support) %></td>
                <% else %>
                  <td>&nbsp;</td>
                <% end %>
              <% end %>
            </tr>
          <% end %>
        </table>
      <% end %>

      <h2>Notes</h2>

      <% if feature['notes'].present? %>
        <p><%= md_to_html feature['notes'] %></p>
      <% end %>

      <% if feature['notes_by_num'].present? %>
        <ol>
          <% feature['notes_by_num'].each do |num, note| %>
            <li><p><%= md_to_html note %></p></li>
          <% end %>
        </ol>
      <% end %>

      <% if feature['prefix'] %>
        <dl>
          <dd><sup>*</sup> Partial support with prefix.</dd>
        </dl>
      <% end %>

      <% if feature['bugs'].present? %>
        <h2>Bugs</h2>
        <ul>
          <% feature['bugs'].each do |bug| %>
            <li><p><%= md_to_html bug['description'] %></p></li>
          <% end %>
        </ul>
      <% end %>

      <% if feature['links'].present? %>
        <h2>Resources</h2>
        <ul>
          <% feature['links'].each do |link| %>
            <li><a href="<%= link['url'] %>"><%= link['title'] %></a></li>
          <% end %>
        </ul>
      <% end %>

      <div class="_attribution">
        <p class="_attribution-p">
          Data by caniuse.com<br>
          Licensed under the Creative Commons Attribution License v4.0.<br>
          <a href="https://caniuse.com/<%= feature_id %>" class="_attribution-link">https://caniuse.com/<%= feature_id %></a>
        </p>
      </div>
    HTML

    def get_latest_version(opts)
      get_npm_version('caniuse-db', opts)
    end
  end
end
