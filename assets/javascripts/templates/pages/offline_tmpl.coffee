app.templates.offlinePage = (docs) -> """
  <h1 class="_lined-heading">Offline Documentation</h1>

  <div class="_docs-tools">
    <label>
      <input type="checkbox" name="autoUpdate" value="1" #{if app.settings.get('manualUpdate') then '' else 'checked'}>Install updates automatically
    </label>
    <div class="_docs-links">
      <button type="button" class="_btn-link" data-action-all="install">Install all</button><button type="button" class="_btn-link" data-action-all="update"><strong>Update all</strong></button><button type="button" class="_btn-link" data-action-all="uninstall">Uninstall all</button>
    </div>
  </div>

  <div class="_table">
    <table class="_docs">
      <tr>
        <th>#{__ 'documentation'}</th>
        <th class="_docs-size">Size</th>
        <th>Status</th>
        <th>Action</th>
      </tr>
      #{docs}
    </table>
  </div>
  <p class="_note"><strong>Note:</strong> your browser may delete DevDocs's offline data if your computer is running low on disk space and you haven't used the app in a while. Load this page before going offline to make sure the data is still there.
  <h2 class="_block-heading">Questions & Answers</h2>
  <dl>
    <dt>How does this work?
    <dd>Each page is cached as a key-value pair in <a href="https://developer.mozilla.org/en-US/docs/Web/API/IndexedDB_API">IndexedDB</a> (downloaded from a single file).<br>
        The app also uses <a href="https://developer.mozilla.org/en-US/docs/Web/HTML/Using_the_application_cache">AppCache</a> and <a href="https://developer.mozilla.org/en-US/docs/Web/API/Web_Storage_API">localStorage</a> to cache the assets and index files.
    <dt>Can I close the tab/browser?
    <dd>#{canICloseTheTab()}
    <dt>What if I don't update a documentation?
    <dd>You'll see outdated content and some pages will be missing or broken, because the rest of the app (including data for the search and sidebar) uses a different caching mechanism that's updated automatically.
    <dt>I found a bug, where do I report it?
    <dd>In the <a href="https://github.com/freeCodeCamp/devdocs/issues">issue tracker</a>. Thanks!
    <dt>How do I uninstall/reset the app?
    <dd>Click <a href="#" data-behavior="reset">here</a>.
    <dt>Why aren't all documentations listed above?
    <dd>You have to <a href="/settings">enable</a> them first.
  </dl>
"""

canICloseTheTab = ->
  if app.AppCache.isEnabled()
    """ Yes! Even offline, you can open a new tab, go to <a href="//devdocs.io">devdocs.io</a>, and everything will work as if you were online (provided you installed all the documentations you want to use beforehand). """
  else
    """ No. AppCache isn't available in your browser (or is disabled), so loading <a href="//devdocs.io">devdocs.io</a> offline won't work.<br>
        The current tab will continue to function even when you go offline (provided you installed all the documentations beforehand). """

app.templates.offlineDoc = (doc, status) ->
  outdated = doc.isOutdated(status)

  html = """
    <tr data-slug="#{doc.slug}"#{if outdated then ' class="_highlight"' else ''}>
      <td class="_docs-name _icon-#{doc.icon}">#{doc.fullName}</td>
      <td class="_docs-size">#{Math.ceil(doc.db_size / 100000) / 10}&nbsp;<small>MB</small></td>
  """

  html += if !(status and status.installed)
    """
      <td>-</td>
      <td><button type="button" class="_btn-link" data-action="install">Install</button></td>
    """
  else if outdated
    """
      <td><strong>Outdated</strong></td>
      <td><button type="button" class="_btn-link _bold" data-action="update">Update</button> - <button type="button" class="_btn-link" data-action="uninstall">Uninstall</button></td>
    """
  else
    """
      <td>Up&#8209;to&#8209;date</td>
      <td><button type="button" class="_btn-link" data-action="uninstall">Uninstall</button></td>
    """

  html + '</tr>'
