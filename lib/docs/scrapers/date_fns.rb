module Docs
  class DateFns < FileScraper
    self.name = 'date-fns'
    self.slug = 'date_fns'
    self.type = 'simple'
    self.links = {
      home: 'https://date-fns.org/',
      code: 'https://github.com/date-fns/date-fns'
    }
    self.release = '2.29.2'
    self.base_url = "https://date-fns.org/v#{self.release}/docs/"

    # https://github.com/date-fns/date-fns/blob/main/LICENSE.md
    options[:attribution] = <<-HTML
      &copy; 2021 Sasha Koss and Lesha Koss<br>
      Licensed under the MIT License.
    HTML

    def build_pages
      markdown = Redcarpet::Markdown.new(Redcarpet::Render::HTML, autolink: true, fenced_code_blocks: true, tables: true)

      md_files = %w(esm.md fp.md gettingStarted.md i18n.md i18nContributionGuide.md release.md timeZones.md unicodeTokens.md upgradeGuide.md webpack.md)
      md_files.each do |md_file|
        md_string = request_one("docs/#{md_file}").body
        md_file = 'index.md' if md_file == 'gettingStarted.md'
        name = md_string.match(/^#([^\n]+)/)[1]
        path = md_file.sub '.md', ''
        page = {
          path: path,
          store_path: "#{path}.html",
          output: markdown.render(md_string),
          entries: [Entry.new(name, path, 'General')]
        }
        yield page
      end

      docs = JSON.parse(request_one('tmp/docs.json').body)
      docs.each do |type, features|
        features.each do |feature|
          name = feature['title']
          feature_id = feature['urlId']
          next if feature_id.start_with?('fp/')
          next if feature['type'] != 'jsdoc'
          # fix description table on https://date-fns.org/v2.29.2/docs/parse
          feature['content']['description'].sub! "\n| Unit", "\n\n| Unit"
          feature['content']['description'].sub! "\nNotes:\n", "\n\nNotes:\n"
          page = {
            path: name,
            store_path: "#{feature_id}.html",
            output: ERB.new(PAGE_ERB).result(binding),
            entries: [Entry.new(name, feature_id, type)]
          }
          yield page
        end
      end
    end

    PAGE_ERB = <<-HTML.strip_heredoc
      <h1><%= feature['title'] %></h1>
      <p><%= feature['description'] %></p>

      <h2>Description</h2>
      <p><%= markdown.render feature['content']['description'] %></p>

      <% if feature['usage'] %>
      <h2>Usage</h2>
      <% feature['usage'].each do |_, usage| %>
        <pre data-language="javascript"><%= '// ' + usage['title'] + '\n' %><%= usage['code'] %></pre>
      <% end %>
      <% end %>

      <% if feature['syntax'] %>
      <h2>Syntax</h2>
      <pre data-language="javascript"><%= feature['syntax'] %></pre>
      <% end %>

      <% if feature['content']['properties'] %>
      <h2>Properties</h2>
      <table>
        <tr>
          <th>Name</th>
          <th>Type</th>
          <th>Description</th>
        </tr>
        <% feature['content']['properties'].each do |param| %>
          <tr>
            <td><code><%= param['name'] %></code></td>
            <td><code><%= param['type']['names'].join ' ' %></code></td>
            <td><%= markdown.render param['description'] || '' %></td>
          </tr>
        <% end %>
      </table>
      <% end %>

      <% if feature['content']['params'] %>
      <h2>Arguments</h2>
      <table>
        <tr>
          <th>Name</th>
          <th>Description</th>
        </tr>
        <% feature['content']['params'].each do |param| %>
          <tr>
            <td><code><%= param['name'] %></code></td>
            <td><%= markdown.render param['description'] || '' %></td>
          </tr>
        <% end %>
      </table>
      <% end %>

      <% if feature['content']['returns'] %>
      <h2>Returns</h2>
      <table>
        <tr>
          <th>Description</th>
        </tr>
        <% feature['content']['returns'].each do |param| %>
          <tr>
            <td><%= markdown.render param['description'] || '' %></td>
          </tr>
        <% end %>
      </table>
      <% end %>

      <% if feature['content']['exceptions'] %>
      <h2>Exceptions</h2>
      <table>
        <tr>
          <th>Type</th>
          <th>Description</th>
        </tr>
        <% feature['content']['exceptions'].each do |param| %>
          <tr>
            <td><code><%= param['type']['names'].join ' ' %></code></td>
            <td><%= markdown.render param['description'] || '' %></td>
          </tr>
        <% end %>
      </table>
      <% end %>

      <% if feature['content']['examples'] %>
      <h2>Examples</h2>
      <% feature['content']['examples'].each do |example| %>
        <pre data-language="javascript"><%= example %></pre>
      <% end %>
      <% end %>

      <div class="_attribution">
        <p class="_attribution-p">
          <%= options[:attribution] %>
          <br>
          <a href="<%= self.base_url %><%= feature_id %>" class="_attribution-link">
            <%= self.base_url %><%= feature_id %>
          </a>
        </p>
      </div>
    HTML

    def get_latest_version(opts)
      get_latest_github_release('date-fns', 'date-fns', opts)
    end
  end
end
