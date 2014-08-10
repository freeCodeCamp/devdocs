ctrlKey = if $.isMac() then 'cmd' else 'ctrl'
navKey = if $.isWindows() then 'alt' else ctrlKey

app.templates.helpPage = """
  <div class="_toc">
    <h3 class="_toc-title">Table of Contents</h3>
    <ul class="_toc-list">
      <li><a href="#search">Search</a>
      <li><a href="#shortcuts">Keyboard Shortcuts</a>
    </ul>
  </div>

  <h2 class="_lined-heading" id="search">Search</h2>
  <p>
    The search is case-insensitive, ignores spaces, and supports fuzzy matching (for queries longer than two characters).
    For example, searching <code class="_label">bgcp</code> brings up <code class="_label">background-clip</code>.
  <dl>
    <dt id="doc_search">Searching a single documentation
    <dd>
      You can scope the search to a single documentation by typing its name (or an abbreviation),
      and pressing <code class="_label">Tab</code> (<code class="_label">Space</code> on mobile devices).
      For example, to search the JavaScript documentation, enter <code class="_label">javascript</code>
      or <code class="_label">js</code>, then <code class="_label">Tab</code>.<br>
      To clear the current scope, empty the search field and hit <code class="_label">Backspace</code>.
    <dt id="url_search">Prefilling the search field
    <dd>
      The search field can be prefilled from the URL by visiting <a href="/#q=keyword" target="_top">devdocs.io/#q=keyword</a>.
      Characters after <code class="_label">#q=</code> will be used as search string.<br>
      To search a single documentation, add its name and a space before the keyword:
      <a href="/#q=js%20date" target="_top">devdocs.io/#q=js date</a>.
    <dt id="browser_search">Searching using the address bar
    <dd>
      DevDocs supports OpenSearch, meaning that it can easily be installed as a search engine on most web browsers.
      <ul>
        <li>On Chrome, the setup is done automatically. Simply press <code class="_label">Tab</code> when devdocs.io is autocompleted
            in the omnibox (to set a custom keyword, click <em>Manage search engines\u2026</em> in Chrome's settings).
        <li>On Firefox, open the search engine list (icon in the search bar) and select <em>Add "DevDocs Search"</em>.
            DevDocs is now available in the search bar. You can also search from the location bar by following
            <a href="https://support.mozilla.org/en-US/kb/how-search-from-address-bar">these instructions</a>.
  </dl>

  <h2 class="_lined-heading" id="shortcuts">Keyboard Shortcuts</h2>
  <h3 class="_shortcuts-title">Selection</h3>
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
  </dl>
  <h3 class="_shortcuts-title">Navigation</h3>
  <dl class="_shortcuts-dl">
    <dt class="_shortcuts-dt">
      <code class="_shortcut-code">#{navKey} + &larr;</code>
      <code class="_shortcut-code">#{navKey} + &rarr;</code>
    <dd class="_shortcuts-dd">Go back/forward
    <dt class="_shortcuts-dt">
      <code class="_shortcut-code">alt + &darr;</code>
      <code class="_shortcut-code">alt + &uarr;</code>
    <dd class="_shortcuts-dd">Scroll step by step
    <dt class="_shortcuts-dt">
      <code class="_shortcut-code">space</code>
      <code class="_shortcut-code">shift + space</code>
    <dd class="_shortcuts-dd">Scroll screen by screen
    <dt class="_shortcuts-dt">
      <code class="_shortcut-code">#{ctrlKey} + &uarr;</code>
      <code class="_shortcut-code">#{ctrlKey} + &darr;</code>
    <dd class="_shortcuts-dd">Scroll to the top/bottom
  </dl>
  <h3 class="_shortcuts-title">Misc</h3>
  <dl class="_shortcuts-dl">
    <dt class="_shortcuts-dt">
      <code class="_shortcut-code">alt + f</code>
    <dd class="_shortcuts-dd">Focus first link in the content area<br>(press tab to focus the other links)
    <dt class="_shortcuts-dt">
      <code class="_shortcut-code">alt + r</code>
    <dd class="_shortcuts-dd">Reveal current page in sidebar
    <dt class="_shortcuts-dt">
      <code class="_shortcut-code">alt + g</code>
    <dd class="_shortcuts-dd">Search on Google
    <dt class="_shortcuts-dt">
      <code class="_shortcut-code">escape</code>
    <dd class="_shortcuts-dd">Reset<br>(press twice in single doc mode)
    <dt class="_shortcuts-dt">
      <code class="_shortcut-code">?</code>
    <dd class="_shortcuts-dd">Show this page
  </dl>
  <p class="_note">
    <strong>Tip:</strong> If the cursor is no longer in the search field, press backspace or
    continue to type and it will refocus the search field and start showing new results. """
