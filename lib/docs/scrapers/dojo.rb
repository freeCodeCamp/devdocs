module Docs
  class Dojo < UrlScraper
    self.name = 'Dojo'
    self.slug = 'dojo'
    self.type = 'dojo'
    self.version = '1.10'
    self.base_url = 'http://dojotoolkit.org/api/1.10/'

    # This is a cut down list of the actually paths taken from the tree.json api on the dojo site
    # Dojo used javascript and xhr requests to allow users to browse it's documentation so it can't
    # be scrapped by just following links from the base page. This list was generating with a little
    # bash and then cut down in order to remove a lot of the more unused documentation e.g. kernel,
    # main, dnd and some others
    self.initial_paths = %w(
      dojo/AdapterRegistry
      dojo/aspect
      dojo/back
      dojo/_base/array
      dojo/_base/browser
      dojo/_base/Color
      dojo/_base/Color.named
      dojo/_base/config
      dojo/_base/config.modulePaths
      dojo/_base/connect
      dojo/_base/declare
      dojo/_base/Deferred
      dojo/_base/event
      dojo/_base/fx
      dojo/_base/html
      dojo/_base/json
      dojo/_base/kernel
      dojo/_base/lang
      dojo/_base/loader
      dojo/_base/NodeList
      dojo/_base/query
      dojo/_base/sniff
      dojo/_base/unload
      dojo/_base/window
      dojo/_base/window.doc
      dojo/_base/window.global
      dojo/_base/xhr
      dojo/_base/xhr.contentHandlers
      dojo/behavior
      dojo/cache
      dojo/cldr/monetary
      dojo/cldr/supplemental
      dojo/colors
      dojo/cookie
      dojo/currency
      dojo/data/api/Identity
      dojo/data/api/Item
      dojo/data/api/Notification
      dojo/data/api/Read
      dojo/data/api/Request
      dojo/data/api/Write
      dojo/data/ItemFileReadStore
      dojo/data/ItemFileWriteStore
      dojo/data/ObjectStore
      dojo/data/util/filter
      dojo/data/util/simpleFetch
      dojo/data/util/sorter
      dojo/date
      dojo/date/locale
      dojo/date/stamp
      dojo/debounce
      dojo/Deferred
      dojo/DeferredList
      dojo/dom
      dojo/dom-attr
      dojo/dom-class
      dojo/dom-construct
      dojo/dom-form
      dojo/dom-geometry
      dojo/dom-prop
      dojo/dom-prop.names
      dojo/domReady
      dojo/dom-style
      dojo/errors/CancelError
      dojo/errors/create
      dojo/errors/RequestError
      dojo/errors/RequestTimeoutError
      dojo/Evented
      dojo/fx
      dojo/fx/easing
      dojo/fx.easing
      dojo/fx/Toggler
      dojo/fx.Toggler
      dojo/gears
      dojo/gears.available
      dojo/has
      dojo/hash
      dojo/hccss
      dojo/html
      dojo/html._ContentSetter
      dojo/i18n
      dojo/i18n.cache
      dojo/io/iframe
      dojo/io-query
      dojo/io/script
      dojo/json
      dojo/keys
      dojo/loadInit
      dojo/main
      dojo/mouse
      dojo/node
      dojo/NodeList
      dojo/NodeList-data
      dojo/NodeList-dom
      dojo/NodeList-fx
      dojo/NodeList-html
      dojo/NodeList-manipulate
      dojo/NodeList._nodeDataCache
      dojo/NodeList-traverse
      dojo/number
      dojo/on
      dojo/on/asyncEventListener
      dojo/on/debounce
      dojo/on/throttle
      dojo/parser
      dojo/promise/all
      dojo/promise/first
      dojo/promise/instrumentation
      dojo/promise/Promise
      dojo/promise/tracer
      dojo/query
      dojo/ready
      dojo/regexp
      dojo/request
      dojo/request/default
      dojo/request/handlers
      dojo/request/iframe
      dojo/request/node
      dojo/request/notify
      dojo/request/registry
      dojo/request/script
      dojo/request/util
      dojo/request/watch
      dojo/request/xhr
      dojo/require
      dojo/robot
      dojo/robot._runsemaphore
      dojo/robotx
      dojo/robotx._runsemaphore
      dojo/router
      dojo/router/RouterBase
      dojo/rpc/JsonpService
      dojo/rpc/JsonService
      dojo/rpc/RpcService
      dojo/selector/acme
      dojo/selector/lite
      dojo/selector/_loader
      dojo/sniff
      dojo/Stateful
      dojo/store/api/Store
      dojo/store/api/Store.PutDirectives
      dojo/store/api/Store.QueryOptions
      dojo/store/api/Store.QueryResults
      dojo/store/api/Store.SortInformation
      dojo/store/api/Store.Transaction
      dojo/store/Cache
      dojo/store/DataStore
      dojo/store/JsonRest
      dojo/store/Memory
      dojo/store/Observable
      dojo/store/util/QueryResults
      dojo/store/util/SimpleQueryEngine
      dojo/string
      dojo/text
      dojo/throttle
      dojo/topic
      dojo/touch
      dojo/uacss
      dojo/when
      dojo/window)
    # Add the rest of the url to the path
    self.initial_paths = self.initial_paths.map { |l| l + ".html?xhr=true" }
    # Dojo expects all the requests to be xhrs or it redirects you back to the docs home page
    # where it uses js to call the backend based on the URL so you get the appropriate documentation
    self.headers = { 'User-Agent' => 'devdocs.io' , 'X-Requested-With' => 'XMLHttpRequest'  }
    self.links = {
      home: 'http://dojotoolkit.org',
      code: 'https://github.com/dojo/dojo'
    }

    html_filters.push 'dojo/clean_html', 'dojo/entries'

    # Don't use default selector on xhrs as no body or html document exists
    options[:container] = ->(filter) { filter.root_page? ? '#content' : false }
    options[:follow_links] = false
    options[:skip_links] = true
    options[:only] = self.initial_paths

    options[:attribution] = <<-HTML
      The Dojo Toolkit is Copyright &copy; 2005&ndash;2013 <br>
      Dual licensed under BSD 3-Clause and AFL.
    HTML
  end
end
