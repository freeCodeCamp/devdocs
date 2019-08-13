app.templates.helpPage = ->
  ctrlKey = if $.isMac() then 'cmd' else 'ctrl'
  navKey = if $.isMac() then 'cmd' else 'alt'

  aliases_one = {}
  aliases_two = {}
  keys = Object.keys(app.models.Entry.ALIASES)
  middle = Math.ceil(keys.length / 2) - 1
  for key, i in keys
    (if i > middle then aliases_two else aliases_one)[key] = app.models.Entry.ALIASES[key]

  """
  <nav class="_toc" role="directory">
    <h3 class="_toc-title">Table of Contents</h3>
    <ul class="_toc-list">
      <li><a href="#managing-documentations">Managing Documentations</a>
      <li><a href="#search">Search</a>
      <li><a href="#shortcuts">Keyboard Shortcuts</a>
      <li><a href="#aliases">Search Aliases</a>
    </ul>
  </nav>

  <h1 class="_lined-heading">User Guide</h1>

  <h2 class="_block-heading" id="managing-documentations">Managing Documentations</h2>
  <p>
    Documentations can be enabled and disabled in the <a href="/settings">Preferences</a>.
    Alternatively, you can enable a documentation by searching for it in the main search
    and clicking the "Enable" link in the results.
    For faster and better search, only enable the documentations you plan on actively using.
  <p>
    Once a documentation is enabled, it becomes part of the search and its content can be downloaded for offline access — and faster page loads when online — in the <a href="/offline">Offline</a> area.

  <h2 class="_block-heading" id="search">Search</h2>
  <p>
    The search is case-insensitive and ignores whitespace. It supports fuzzy matching
    (e.g. <code class="_label">bgcp</code> matches <code class="_label">background-clip</code>)
    as well as aliases (full list <a href="#aliases">below</a>).
  <dl>
    <dt id="doc_search">Searching a single documentation
    <dd>
      The search can be scoped to a single documentation by typing its name (or an abbreviation)
      and pressing <code class="_label">tab</code> (<code class="_label">space</code>&nbsp;on mobile).
      For example, to search the JavaScript documentation, enter <code class="_label">javascript</code>
      or <code class="_label">js</code>, then <code class="_label">tab</code>.<br>
      To clear the current scope, empty the search field and hit <code class="_label">backspace</code> or
      <code class="_label">esc</code>.
    <dt id="url_search">Prefilling the search field
    <dd>
      The search can be prefilled from the URL by visiting <a href="/#q=keyword" target="_top">devdocs.io/#q=keyword</a>.
      Characters after <code class="_label">#q=</code> will be used as search query.<br>
      To search a single documentation, add its name (or an abbreviation) and a space before the keyword:
      <a href="/#q=js%20date" target="_top">devdocs.io/#q=js date</a>.
    <dt id="browser_search">Searching using the address bar
    <dd>
      DevDocs supports OpenSearch. It can easily be installed as a search engine on most web browsers:
      <ul>
        <li>On Chrome, the setup is done automatically. Simply press <code class="_label">tab</code> when devdocs.io is autocompleted
            in the omnibox (to set a custom keyword, click <em>Manage search engines\u2026</em> in Chrome's settings).
        <li>On Firefox, right-click the DevDocs search field and select <em>Add a Keyword for this Search…</em>. Then, type the added keyword followed by a query in the address bar to search DevDocs.
  </dl>
  <p>
    <i>Note: the above search features only work for documentations that are enabled.</i>

  <h2 class="_block-heading" id="shortcuts">Keyboard Shortcuts</h2>
  <h3 class="_shortcuts-title">Sidebar</h3>
  <dl class="_shortcuts-dl">
    <dt class="_shortcuts-dt">
      <code class="_shortcut-code">&darr;</code>
      <code class="_shortcut-code">&uarr;</code>
    <dd class="_shortcuts-dd">Move selection
    <dt class="_shortcuts-dt">
      <code class="_shortcut-code">&rarr;</code>
      <code class="_shortcut-code">&larr;</code>
    <dd class="_shortcuts-dd">Show/hide sub-list
    <dt class="_shortcuts-dt">
      <code class="_shortcut-code">enter</code>
    <dd class="_shortcuts-dd">Open selection
    <dt class="_shortcuts-dt">
      <code class="_shortcut-code">#{ctrlKey} + enter</code>
    <dd class="_shortcuts-dd">Open selection in a new tab
    <dt class="_shortcuts-dt">
      <code class="_shortcut-code">alt + r</code>
    <dd class="_shortcuts-dd">Reveal current page in sidebar
  </dl>
  <h3 class="_shortcuts-title">Browsing</h3>
  <dl class="_shortcuts-dl">
    <dt class="_shortcuts-dt">
      <code class="_shortcut-code">#{navKey} + &larr;</code>
      <code class="_shortcut-code">#{navKey} + &rarr;</code>
    <dd class="_shortcuts-dd">Go back/forward
    <dt class="_shortcuts-dt">
      <code class="_shortcut-code">alt + &darr;</code>
      <code class="_shortcut-code">alt + &uarr;</code>
      <br>
      <code class="_shortcut-code">shift + &darr;</code>
      <code class="_shortcut-code">shift + &uarr;</code>
    <dd class="_shortcuts-dd">Scroll step by step<br><br>
    <dt class="_shortcuts-dt">
      <code class="_shortcut-code">space</code>
      <code class="_shortcut-code">shift + space</code>
    <dd class="_shortcuts-dd">Scroll screen by screen
    <dt class="_shortcuts-dt">
      <code class="_shortcut-code">#{ctrlKey} + &uarr;</code>
      <code class="_shortcut-code">#{ctrlKey} + &darr;</code>
    <dd class="_shortcuts-dd">Scroll to the top/bottom
    <dt class="_shortcuts-dt">
      <code class="_shortcut-code">alt + f</code>
    <dd class="_shortcuts-dd">Focus first link in the content area<br>(press tab to focus the other links)
  </dl>
  <h3 class="_shortcuts-title">App</h3>
  <dl class="_shortcuts-dl">
    <dt class="_shortcuts-dt">
      <code class="_shortcut-code">ctrl + ,</code>
    <dd class="_shortcuts-dd">Open preferences
    <dt class="_shortcuts-dt">
      <code class="_shortcut-code">esc</code>
    <dd class="_shortcuts-dd">Clear search field / reset UI
    <dt class="_shortcuts-dt">
      <code class="_shortcut-code">?</code>
    <dd class="_shortcuts-dd">Show this page
  </dl>
  <h3 class="_shortcuts-title">Miscellaneous</h3>
  <dl class="_shortcuts-dl">
    <dt class="_shortcuts-dt">
      <code class="_shortcut-code">alt + o</code>
    <dd class="_shortcuts-dd">Open original page
    <dt class="_shortcuts-dt">
      <code class="_shortcut-code">alt + g</code>
    <dd class="_shortcuts-dd">Search on Google
    <dt class="_shortcuts-dt">
      <code class="_shortcut-code">alt + s</code>
    <dd class="_shortcuts-dd">Search on Stack Overflow
    <dt class="_shortcuts-dt">
      <code class="_shortcut-code">alt + d</code>
    <dd class="_shortcuts-dd">Search on DuckDuckGo
  </dl>
  <p class="_note _note-green">
    <strong>Tip:</strong> If the cursor is no longer in the search field, press <code class="_label">/</code> or
    continue to type and it will refocus the search field and start showing new results.

  <h2 class="_block-heading" id="aliases">Search Aliases</h2>
  <div class="_aliases">
    <table>
      <tr>
        <th>Word
        <th>Alias
      #{("<tr><td class=\"_code\">#{key}<td class=\"_code\">#{value}" for key, value of aliases_one).join('')}
    </table>
    <table>
      <tr>
        <th>Word
        <th>Alias
      #{("<tr><td class=\"_code\">#{key}<td class=\"_code\">#{value}" for key, value of aliases_two).join('')}
    </table>
  </div>
  <p>Feel free to suggest new aliases on <a href="https://github.com/freeCodeCamp/devdocs/issues/new">GitHub</a>.
"""
