module Docs
  class NginxLuaModule < Github
    self.name = 'nginx / Lua Module'
    self.slug = 'nginx_lua_module'
    self.release = '0.10.28'
    self.base_url = "https://github.com/openresty/lua-nginx-module/blob/v#{self.release}/"
    self.root_path = 'README.markdown'
    self.links = {
      code: 'https://github.com/openresty/lua-nginx-module'
    }

    html_filters.push 'nginx_lua_module/clean_html', 'nginx_lua_module/entries', 'title'

    options[:root_title] = 'ngx_http_lua_module'
    options[:container] = '.markdown-body'
    options[:max_image_size] = 256_000
    options[:attribution] = <<-HTML
      &copy; 2009&ndash;2017 Xiaozhe Wang (chaoslawful)<br>
      &copy; 2009&ndash;2019 Yichun "agentzh" Zhang (章亦春), OpenResty Inc.<br>
      Licensed under the BSD License.
    HTML
    options[:skip_patterns] = [/\.png/]

    def get_latest_version(opts)
      tags = get_github_tags('openresty', 'lua-nginx-module', opts)
      tag = tags.find {|tag| !tag['name'].include?('rc')}
      tag['name'][1..-1]
    end
  end
end
