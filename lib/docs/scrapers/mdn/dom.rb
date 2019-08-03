module Docs
  class Dom < Mdn
    prepend FixInternalUrlsBehavior
    prepend FixRedirectionsBehavior

    self.name = 'DOM'
    self.base_url = 'https://developer.mozilla.org/en-US/docs/Web/API'

    html_filters.push 'dom/clean_html', 'dom/entries', 'title'

    options[:mdn_tag] = 'XSLT_Reference'

    options[:root_title] = 'DOM'

    options[:skip] = %w(
      /Reference
      /Index
      /Document_Object_Model
      /document/createProcessingInstruction
      /document/documentURIObject
      /document/loadOverlay
      /document/tooltipNode
      /Document/cookie/Simple_document.cookie_framework
      /DOMErrorHandler
      /DOMLocator
      /DOMObject
      /DOMStringList
      /Event/Comparison_of_Event_Targets
      /Format
      /IDBDatabaseException
      /IndexedDB_API/Using_JavaScript_Generators_in_Firefox
      /Notation
      /ProcessingInstruction
      /TypeInfo
      /window/getAttention
      /window/messageManager
      /window/updateCommands
      /window/pkcs11
      /OES_texture_float)

    options[:skip_patterns] = [
      /NS/,
      /XPC/,
      /moz/i,
      /gecko/i,
      /webkit/i,
      /gamepad/i,
      /UserData/,
      /Bluetooth/,
      /FMRadio/i,
      /XDomainRequest/i,
      /\A\/Camera/,
      /\A\/Data_Store_API/,
      /\A\/DataStore/,
      /\A\/DeviceStorage/,
      /\A\/DocumentTouch/,
      /\A\/document\/xml/,
      /\A\/XMLDocument/,
      /\A\/DOMCursor/,
      /\A\/DOMRequest/,
      /\A\/InstallTrigger/,
      /\A\/Entity/,
      /\A\/Settings/,
      /telephony/i,
      /\A\/NFC_API/,
      /\A\/Window\/\w+bar/i,
      /\A\/Apps/,
      /\A\/Contact/,
      /\A\/L10n/,
      /\A\/Permission/]

    options[:fix_urls] = ->(url) do
      return if url.include?('_') || url.include?('?')
      url.sub! 'https://developer.mozilla.org/en-US/docs/DOM/', "#{Dom.base_url}/"
      url.sub! 'https://developer.mozilla.org/en/DOM/',         "#{Dom.base_url}/"
      url.sub! 'https://developer.mozilla.org/Web/API/',        "#{Dom.base_url}/"
      url.sub! "#{Dom.base_url}/Console",                       "#{Dom.base_url}/console"
      url.sub! "#{Dom.base_url}/Document\/",                    "#{Dom.base_url}/document\/"
      url.sub! "#{Dom.base_url}/Element",                       "#{Dom.base_url}/element"
      url.sub! "#{Dom.base_url}/History",                       "#{Dom.base_url}/history"
      url.sub! "#{Dom.base_url}/Location",                      "#{Dom.base_url}/location"
      url.sub! "#{Dom.base_url}/Navigator",                     "#{Dom.base_url}/navigator"
      url.sub! "#{Dom.base_url}/Screen",                        "#{Dom.base_url}/screen"
      url.sub! "#{Dom.base_url}/Window\/",                      "#{Dom.base_url}/window\/"
      url.sub! "#{Dom.base_url}/notification",                  "#{Dom.base_url}/Notification"
      url.sub! "#{Dom.base_url}/range",                         "#{Dom.base_url}/Range"
      url.sub! "#{Dom.base_url}/event",                         "#{Dom.base_url}/Event"
      url.sub! '/en/DOM/Manipulating_the_browser_history',      "/en-US/docs/Web/API/History_API"
      url
    end
  end
end
