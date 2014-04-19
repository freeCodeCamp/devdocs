module Docs
  class Filter < ::HTML::Pipeline::Filter
    def css(*args)
      doc.css(*args)
    end

    def at_css(*args)
      doc.at_css(*args)
    end

    def xpath(*args)
      doc.xpath(*args)
    end

    def at_xpath(*args)
      doc.at_xpath(*args)
    end

    def base_url
      context[:base_url]
    end

    def current_url
      context[:url]
    end

    def root_url
      context[:root_url]
    end

    def root_path
      context[:root_path]
    end

    def subpath
      @subpath ||= subpath_to(current_url)
    end

    def subpath_to(url)
      base_url.subpath_to url, ignore_case: true
    end

    def slug
      @slug ||= subpath.sub(/\A\//, '').remove(/\.html\z/)
    end

    def root_page?
      subpath.blank? || subpath == '/' || subpath == root_path
    end

    def initial_page?
      root_page? || context[:initial_paths].include?(subpath)
    end

    SCHEME_RGX = /\A[^:\/?#]+:/

    def fragment_url_string?(str)
      str[0] == '#'
    end

    def relative_url_string?(str)
      !fragment_url_string?(str) && str !~ SCHEME_RGX
    end

    def absolute_url_string?(str)
      str =~ SCHEME_RGX
    end

    def parse_html(html)
      warn "#{self.class.name} is re-parsing the document" unless ENV['RACK_ENV'] == 'test'
      super
    end
  end
end
