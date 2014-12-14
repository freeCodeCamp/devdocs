module Docs
  class Dom < Mdn
    self.name = 'DOM'
    self.base_url = 'https://developer.mozilla.org/en-US/docs/Web/API'

    html_filters.push 'dom/clean_html', 'dom/entries', 'title'

    options[:root_title] = 'DOM'

    # Don't want
    options[:skip] = %w(
      /App
      /CallEvent
      /CanvasPixelArray
      /ChromeWorker
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
      /IndexedDB_API/Using_JavaScript_Generators_in_Firefox
      /NamedNodeMap
      /Node.baseURIObject
      /Node.nodePrincipal
      /Notation
      /PowerManager
      /PushManager
      /ProcessingInstruction
      /TCPServerSocket
      /TCPSocket
      /TypeInfo
      /Using_the_Browser_API
      /Web_Video_Text_Tracks_Format
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
      /window.pkcs11)

    options[:skip_patterns] = [
      /NS/,
      /XPC/,
      /moz/i,
      /gecko/i,
      /webkit/i,
      /gamepad/i,
      /UserData/,
      /\A\/Camera/,
      /\A\/Data_Store_API/,
      /\A\/DataStore/,
      /\A\/DeviceStorage/,
      /\A\/DocumentTouch/,
      /\A\/document\.xml/,
      /\A\/XMLDocument/,
      /\A\/DOMCursor/,
      /\A\/DOMRequest/,
      /\A\/element\.on/,
      /\A\/Entity/,
      /\A\/navigator\.id/i,
      /\A\/Settings/,
      /\A\/Telephony/,
      /Bluetooth/,
      /\A\/Window\.\w+bar/i,
      /\A\/Apps/,
      /\A\/Contact/,
      /\A\/L10n/,
      /\A\/Permission/]

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
    options[:skip].concat %w(
      /Reference
      /Index
      /form.elements
      /select.type
      /table.rows
      /XMLHttpRequest/FormData
      /Performance.now
      /Document_Object_Model)

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
      url.sub! "#{Dom.base_url}/window.navigator",              "#{Dom.base_url}/navigator"
      url.sub! "#{Dom.base_url}/Selection/",                    "#{Dom.base_url}/Selection."
      url.sub! "#{Dom.base_url}/windowTimers",                  "#{Dom.base_url}/window"
      url.sub! "#{Dom.base_url}/windowEventHandlers",           "#{Dom.base_url}/window"
      url.sub! %r{\/windowLocalStorage(\.localStorage)?}i,      "/window.localStorage"
      url.sub! %r{\/windowSessionStorage(\.sessionStorage)?}i,  "/window.sessionStorage"
      url.sub! "#{Dom.base_url}/Screen.",                       "#{Dom.base_url}/window.screen"
      url
    end
  end
end
