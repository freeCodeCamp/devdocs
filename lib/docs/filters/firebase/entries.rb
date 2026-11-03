module Docs
  class Firebase
    class EntriesFilter < Docs::EntriesFilter
      # The products' names as the site writes them, for pages whose
      # breadcrumbs don't say.
      PRODUCTS = {
        'ai-logic' => 'AI Logic',
        'app-check' => 'App Check',
        'auth' => 'Authentication',
        'cloud-messaging' => 'Cloud Messaging',
        'database' => 'Realtime Database',
        'firestore' => 'Cloud Firestore',
        'functions' => 'Cloud Functions',
        'perf-mon' => 'Performance Monitoring',
        'sql-connect' => 'SQL Connect',
        'storage' => 'Cloud Storage'
      }

      def get_name
        title = at_css('h1.devsite-page-title')&.dup
        return super unless title
        # The heading also holds the bookmark button and its tooltip.
        title.css('devsite-actions, devsite-feature-tooltip, devsite-bookmark, .nocontent').remove
        title.content.squish.presence || super
      end

      # The product: the breadcrumb after "Firebase › Documentation", e.g. "Authentication".
      def get_type
        product = subpath.split('/').first.to_s
        crumbs = css('.devsite-breadcrumb-list .devsite-breadcrumb-link').map { |node| node.content.squish }
        crumbs = crumbs.drop((crumbs.index('Documentation') || -1) + 1)
        crumbs.first.presence || PRODUCTS[product] || product.tr('-', ' ').capitalize.presence || 'Firebase'
      end

      def include_default_entry?
        !root_page?
      end
    end
  end
end
