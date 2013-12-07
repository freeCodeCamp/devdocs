module Docs
  class Dom < Mdn
    self.name = 'DOM'
    self.base_url = 'https://developer.mozilla.org/en-US/docs/Web/API'

    html_filters.push 'dom/clean_html', 'dom/entries', 'title'

    options[:root_title] = 'DOM'

    # Don't want
    options[:skip] = %w(
      /App
      /Apps
      /CallEvent
      /CanvasPixelArray
      /ChromeWorker
      /ContactManager
      /document.createProcessingInstruction
      /document.documentURIObject
      /document.loadOverlay
      /document.tooltipNode
      /DOMErrorHandler
      /DOMLocator
      /DOMObject
      /DOMStringList
      /Event/Comparison_of_Event_Targets
      /FMRadio
      /IDBDatabaseException
      /NamedNodeMap
      /Node.baseURIObject
      /Node.nodePrincipal
      /Notation
      /PowerManager
      /PushManager
      /ProcessingInstruction
      /select.type
      /TCPServerSocket
      /TCPSocket
      /WifiManager
      /window.controllers
      /window.crypto
      /window.getAttention
      /window.messageManager
      /window.navigator.addIdleObserver
      /window.navigator.getDeviceStorage
      /window.navigator.getDeviceStorages
      /window.navigator.removeIdleObserver
      /window.navigator.requestWakeLock
      /window.updateCommands
      /window.pkcs11
      /XMLDocument
      /XMLHttpRequest/Using_XMLHttpRequest)

    options[:skip_patterns] = [
      /NS/,
      /XPC/,
      /moz/i,
      /gecko/i,
      /webkit/i,
      /\A\/Camera/,
      /\A\/DeviceStorage/,
      /\A\/document\.xml/,
      /\A\/DOMCursor/,
      /\A\/DOMRequest/,
      /\A\/element\.on/,
      /\A\/Entity/,
      /\A\/HTMLIFrameElement\./,
      /\A\/navigator\.id/i,
      /\A\/Settings/,
      /\A\/Telephony/,
      /\A\/Bluetooth/,
      /UserData/,
      /\A\/Window\.\w+bar/i]

    # Broken / Empty
    options[:skip].concat %w(
      /Attr.isId
      /document.nodePrincipal
      /Event/UIEvent
      /Extensions
      /StyleSheetList
      /SVGPoint
      /Window.dispatchEvent
      /Window.restore
      /Window.routeEvent
      /Window.QueryInterface)

    # Duplicates
    options[:skip].concat %w(/Reference)

    options[:fix_urls] = ->(url) do
      return if url.include?('_') || url.include?('?')
      url.sub! 'https://developer.mozilla.org/en-US/docs/DOM/', "#{Dom.base_url}/"
      url.sub! 'https://developer.mozilla.org/en/DOM/',         "#{Dom.base_url}/"
      url.sub! "#{Dom.base_url}/Document\.",                    "#{Dom.base_url}/document."
      url.sub! "#{Dom.base_url}/Element",                       "#{Dom.base_url}/element"
      url.sub! "#{Dom.base_url}/History",                       "#{Dom.base_url}/history"
      url.sub! "#{Dom.base_url}/Navigator",                     "#{Dom.base_url}/navigator"
      url.sub! "#{Dom.base_url}/notification",                  "#{Dom.base_url}/Notification"
      url.sub! "#{Dom.base_url}/range",                         "#{Dom.base_url}/Range"
      url.sub! "#{Dom.base_url}/Window",                        "#{Dom.base_url}/window"
      url
    end
  end
end
