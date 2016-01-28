module Docs
  class LuaNginxModule < UrlScraper
    self.type = 'LuaNginxModule'
    self.root_path = 'README.markdown'

    html_filters.push 'lua_nginx_module/clean_html', 'lua_nginx_module/entries'

    options[:container] = '#readme > article'

    options[:attribution] = <<-HTML
      Copyright (C) 2009-2015, by Xiaozhe Wang (chaoslawful) <a href="mailto:chaoslawful@gmail.com">chaoslawful@gmail.com</a>.<br>
      Copyright (C) 2009-2015, by Yichun "agentzh" Zhang (章亦春) <a href="mailto:agentzh@gmail.com">agentzh@gmail.com</a>, CloudFlare Inc.<br>
      Licensed under the BSD License.
    HTML

    self.release = '0.10.0'
    self.base_url = 'https://github.com/openresty/lua-nginx-module/tree/v0.10.0/'
  end
end
