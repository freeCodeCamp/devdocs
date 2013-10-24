module Docs
  module Response
    def success?
      code == 200
    end

    def empty?
      body.empty?
    end

    def mime_type
      @mime_type ||= headers['Content-Type'] || 'text/plain'
    end

    def html?
      mime_type.include? 'html'
    end

    def url
      @url ||= URL.parse request.base_url
    end

    def path
      @path ||= url.path
    end

    def effective_url
      @effective_url ||= URL.parse super
    end

    def effective_path
      @effective_path ||= effective_url.path
    end
  end
end
