app.templates.offlinePage = (docs) -> """
  <h1 class="_lined-heading">Offline Documentation</h1>

  <div class="_docs-tools">
    <div class="_docs-links">
      <a class="_docs-link" data-action-all="install">Install all</a><a class="_docs-link" data-action-all="update"><strong>Update all</strong></a><a class="_docs-link" data-action-all="uninstall">Uninstall all</a>
    </div>
    <label class="_docs-label">
      <input type="checkbox" name="autoUpdate" value="1" #{if app.settings.get('autoUpdate') then 'checked' else ''}>
      Check for and install updates automatically
    </label>
  </div>

  <table class="_docs">
    <tr>
      <th>Documentation</th>
      <th class="_docs-size">Size</th>
      <th>Status</th>
      <th>Action</th>
    </tr>
    #{docs}
  </table>
  <p class="_note"><strong>Note:</strong> your browser may delete DevDocs's offline data if your computer is running low on disk space and you haven't used the app in a while. Load this page before going offline to make sure the data is still there.
  <h1 class="_lined-heading">Questions & Answers</h1>
  <dl>
    <dt>How does this work?
    <dd>Each page is cached as a key-value pair in <a href="https://developer.mozilla.org/en-US/docs/Web/API/IndexedDB_API">IndexedDB</a> (downloaded from a single file).<br>
        The app also uses <a href="https://developer.mozilla.org/en-US/docs/Web/HTML/Using_the_application_cache">AppCache</a> and <a href="https://developer.mozilla.org/en-US/docs/Web/API/Web_Storage_API">localStorage</a> to cache the assets and index files.
    <dt>Can I close the tab/browser?
    <dd>#{canICloseTheTab()}
    <dt>What if I don't update a documentation?
    <dd>You'll see outdated content and some pages will be missing or broken, since the rest of the app (including data for the search and sidebar) uses a different caching mechanism which is updated automatically.<br>
        Documentation versioning is planned for the future but not yet supported, sorry.
    <dt>I found a bug, where do I report it?
    <dd>In the <a href="https://github.com/Thibaut/devdocs/issues">issue tracker</a>. Thanks!
    <dt>How do I uninstall/reset the app?
    <dd>Click <a href="javascript:if(confirm('Are you sure you want to reset DevDocs?'))app.reset()">here</a>.
    <dt>Why aren't all documentations listed above?
    <dd>You have to <a href="#" data-pick-docs>enable</a> them first.
  </dl>
"""

canICloseTheTab = ->
  if app.AppCache.isEnabled()
    """ Yes! Even offline, you can open a new tab, go to <a href="http://devdocs.io">devdocs.io</a>, and everything will work as if you were online (provided you installed all the documentations you want to use beforehand). """
  else if app.mozApp
    """ Yes! Even offline, you can open the app and everything will work as if you were online (provided you installed all the documentations you want to use beforehand). """
  else
    """ No. AppCache isn't available in your browser (or is disabled) so loading <a href="http://devdocs.io">devdocs.io</a> offline won't work.<br>
        The current tab will continue to work, though (provided you installed all the documentations you want to use beforehand). """

app.templates.offlineDoc = (doc, status) ->
  outdated = doc.isOutdated(status)

  html = """
    <tr data-slug="#{doc.slug}"#{if outdated then ' class="_highlight"' else ''}>
      <td class="_docs-name _icon-#{doc.slug}">#{doc.name}</td>
      <td class="_docs-size">#{Math.ceil(doc.db_size / 100000) / 10} MB</td>
  """

  html += if !(status and status.installed)
    """
      <td>-</td>
      <td><a data-action="install">Install</a></td>
    """
  else if outdated
    """
      <td><strong>Outdated</strong></td>
      <td><a data-action="update">Update</a> - <a data-action="uninstall">Uninstall</a></td>
    """
  else
    """
      <td>Up-to-date</td>
      <td><a data-action="uninstall">Uninstall</a></td>
    """

  html + '</tr>'
