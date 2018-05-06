app.templates.helpPage = ->
  ctrlKey = if $.isMac() then 'cmd' else 'ctrl'
  navKey = if $.isMac() then 'cmd' else 'alt'

  aliases_one = {}
  aliases_two = {}
  keys = Object.keys(app.models.Entry.ALIASES)
  middle = Math.ceil(keys.length / 2) - 1
  for key, i in keys
    (if i > middle then aliases_two else aliases_one)[key] = app.models.Entry.ALIASES[key]

  _ app.templates.helpPage, {
    aliases_one: ("<tr><td class=\"_code\">#{key}<td class=\"_code\">#{value}" for key, value of aliases_one).join(''),
    aliases_two: ("<tr><td class=\"_code\">#{key}<td class=\"_code\">#{value}" for key, value of aliases_two).join(''),
    ctrlKey,
    navKey
  }

app.templates.helpPage.en = """
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
      <code class="_shortcut-code">{ctrlKey} + enter</code>
    <dd class="_shortcuts-dd">Open selection in a new tab
    <dt class="_shortcuts-dt">
      <code class="_shortcut-code">alt + r</code>
    <dd class="_shortcuts-dd">Reveal current page in sidebar
  </dl>
  <h3 class="_shortcuts-title">Browsing</h3>
  <dl class="_shortcuts-dl">
    <dt class="_shortcuts-dt">
      <code class="_shortcut-code">{navKey} + &larr;</code>
      <code class="_shortcut-code">{navKey} + &rarr;</code>
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
      <code class="_shortcut-code">{ctrlKey} + &uarr;</code>
      <code class="_shortcut-code">{ctrlKey} + &darr;</code>
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
      {aliases_one}
    </table>
    <table>
      <tr>
        <th>Word
        <th>Alias
      {aliases_two}
    </table>
  </div>
  <p>Feel free to suggest new aliases on <a href="https://github.com/freeCodeCamp/devdocs/issues/new">GitHub</a>.
"""

app.templates.helpPage.ja = """
  <nav class="_toc" role="directory">
    <h3 class="_toc-title">内容</h3>
    <ul class="_toc-list">
      <li><a href="#managing-documentations">ドキュメント管理</a>
      <li><a href="#search">検索</a>
      <li><a href="#shortcuts">キーボードショートカット</a>
      <li><a href="#aliases">検索エイリアス</a>
    </ul>
  </nav>
  <h1 class="_lined-heading">ユーザーガイド</h1>
  <h2 class="_block-heading" id="managing-documentations">ドキュメント管理</h2>
  <p>
    ドキュメントは<a href="/settings">設定</a>で有効・無効にできます。
    もしくは、検索結果の「有効」リンクをクリックすることでもドキュメントを有効にできます。
    速く、よい検索には、ドキュメントを有効だけ　行う使い方で計画。
    For faster and better search, only enable the documentations you plan on actively using.
  <p>
    一度ドキュメントを有効にしたら、検索の一部になります。また、内容はオフラインアクセスのためにダウンロードできるようになります。-オンラインの時ページを速く読み込めます-<a href="/offline">オフライン</a>で。
    Once a documentation is enabled, it becomes part of the search and its content can be downloaded for offline access — and faster page loads when online — in the <a href="/offline">Offline</a> area.
  <h2 class="_block-heading" id="search">検索</h2>
  <p>
    検索は空白を無視します。曖昧なサポートします。
    The search is case-insensitive and ignores whitespace. It supports fuzzy matching
    (e.g. <code class="_label">bgcp</code> matches <code class="_label">background-clip</code>)
    as well as aliases (full list <a href="#aliases">below</a>).
  <dl>
    <dt id="doc_search">一つのドキュメントを検索する
    <dd>
      名前（または略語）を入力することによって、一つのドキュメント内を検索できます。
      The search can be scoped to a single documentation by typing its name (or an abbreviation)
      また、<code class="_label">タブ</code> (モバイルでは<code class="_label">スペース</code>&nbsp;)を押します。
      and pressing <code class="_label">tab</code> (<code class="_label">space</code>&nbsp;on mobile).
      例えば、JavaScriptのドキュメントを検索するには、<code class="_label">javascript</code>
      か<code class="_label">js</code>と入れるよりも、<code class="_label">タブ</code>。<br>
      For example, to search the JavaScript documentation, enter <code class="_label">javascript</code>
      or <code class="_label">js</code>, then <code class="_label">tab</code>.<br>
      正確な範囲で、空のサーチ部分に<code class="_label">バックスペース</code>または、
      <code class="_label">esc</code>。
      To clear the current scope, empty the search field and hit <code class="_label">backspace</code> or
      <code class="_label">esc</code>.
    <dt id="url_search">Prefilling the search field
    <dd>
      The search can be prefilled from the URL by visiting <a href="/#q=keyword" target="_top">devdocs.io/#q=keyword</a>.
      <code class="_label">#q=</code>以降はサーチクエリが使用されています。
      一つのドキュメント内の検索で、名前（または、略語）を追加したり、キーワードの前にスペースを入れます：
      <a href="/#q=js%20date" target="_top">devdocs.io/#q=js date</a>.
    <dt id="browser_search">アドレスバーを検索に使う
    <dd>
      DevDocsはオープンサーチをサポートしています。webブラウザのサーチエンジンのように、簡単にインストールできます。
      <ul>
        <li>Chromeでは、自動的にセットアップします、devdocs.io
        <li>On Chrome, the setup is done automatically. Simply press <code class="_label">tab</code> when devdocs.io is autocompleted
            in the omnibox (to set a custom keyword, click <em>Manage search engines\u2026</em> in Chrome's settings).
        <li>On Firefox, right-click the DevDocs search field and select <em>Add a Keyword for this Search…</em>. Then, type the added keyword followed by a query in the address bar to search DevDocs.
  </dl>
  <p>
    <i>ノート：サーチは有効なドキュメントでのみ動作します。</i>
    <i>Note: the above search features only work for documentations that are enabled.</i>
  <h2 class="_block-heading" id="shortcuts">キーボードショートカット</h2>
  <h3 class="_shortcuts-title">サイドバー</h3>
  <dl class="_shortcuts-dl">
    <dt class="_shortcuts-dt">
      <code class="_shortcut-code">&darr;</code>
      <code class="_shortcut-code">&uarr;</code>
    <dd class="_shortcuts-dd">セレクションの移動
    <dt class="_shortcuts-dt">
      <code class="_shortcut-code">&rarr;</code>
      <code class="_shortcut-code">&larr;</code>
    <dd class="_shortcuts-dd">サブリストの表示/非表示
    <dt class="_shortcuts-dt">
      <code class="_shortcut-code">enter</code>
    <dd class="_shortcuts-dd">セレクションを開く
    <dt class="_shortcuts-dt">
      <code class="_shortcut-code">{ctrlKey} + enter</code>
    <dd class="_shortcuts-dd">セレクションを新しいタブで開く
    <dt class="_shortcuts-dt">
      <code class="_shortcut-code">alt + r</code>
    <dd class="_shortcuts-dd">Reveal current page in sidebar
  </dl>
  <h3 class="_shortcuts-title">ブラウジング</h3>
  <dl class="_shortcuts-dl">
    <dt class="_shortcuts-dt">
      <code class="_shortcut-code">{navKey} + &larr;</code>
      <code class="_shortcut-code">{navKey} + &rarr;</code>
    <dd class="_shortcuts-dd">戻る/進む
    <dt class="_shortcuts-dt">
      <code class="_shortcut-code">alt + &darr;</code>
      <code class="_shortcut-code">alt + &uarr;</code>
      <br>
      <code class="_shortcut-code">shift + &darr;</code>
      <code class="_shortcut-code">shift + &uarr;</code>
    <dd class="_shortcuts-dd">順にスクロールする<br><br>
    <dt class="_shortcuts-dt">
      <code class="_shortcut-code">space</code>
      <code class="_shortcut-code">shift + space</code>
    <dd class="_shortcuts-dd">Scroll screen by screen
    <dt class="_shortcuts-dt">
      <code class="_shortcut-code">{ctrlKey} + &uarr;</code>
      <code class="_shortcut-code">{ctrlKey} + &darr;</code>
    <dd class="_shortcuts-dd">上部/下部にスクロールする
    <dt class="_shortcuts-dt">
      <code class="_shortcut-code">alt + f</code>
    <dd class="_shortcuts-dd">内容内の最初のリンクにフォーカスする<br>(press tab to focus the other links)
  </dl>
  <h3 class="_shortcuts-title">アプリ</h3>
  <dl class="_shortcuts-dl">
    <dt class="_shortcuts-dt">
      <code class="_shortcut-code">ctrl + ,</code>
    <dd class="_shortcuts-dd">設定を開く
    <dt class="_shortcuts-dt">
      <code class="_shortcut-code">esc</code>
    <dd class="_shortcuts-dd">サーチフィールドをクリア/UIリセット
    <dt class="_shortcuts-dt">
      <code class="_shortcut-code">?</code>
    <dd class="_shortcuts-dd">このページを見る
  </dl>
  <h3 class="_shortcuts-title">その他</h3>
  <dl class="_shortcuts-dl">
    <dt class="_shortcuts-dt">
      <code class="_shortcut-code">alt + o</code>
    <dd class="_shortcuts-dd">オリジナルページを開く
    <dt class="_shortcuts-dt">
      <code class="_shortcut-code">alt + g</code>
    <dd class="_shortcuts-dd">Googleで検索する
    <dt class="_shortcuts-dt">
      <code class="_shortcut-code">alt + s</code>
    <dd class="_shortcuts-dd">Stack Overflowで検索する
  </dl>
  <p class="_note _note-green">
    <strong>Tip:</strong>サーチフィールドでカーソルが　たら、<code class="_label">/</code>を押すか、
    タイプを続けてサーチフィールドにリフォーカスすると新しい検索結果が表示されます。
    <strong>Tip:</strong> If the cursor is no longer in the search field, press <code class="_label">/</code> or
    continue to type and it will refocus the search field and start showing new results.
  <h2 class="_block-heading" id="aliases">Search Aliases</h2>
  <div class="_aliases">
    <table>
      <tr>
        <th>Word
        <th>Alias
      {aliases_one}
    </table>
    <table>
      <tr>
        <th>Word
        <th>Alias
      {aliases_two}
    </table>
  </div>
  <p>新しいエイリアスは<a href="https://github.com/freeCodeCamp/devdocs/issues/new">GitHub</a>で自由に提案できます。</p>
  <p>Feel free to suggest new aliases on <a href="https://github.com/freeCodeCamp/devdocs/issues/new">GitHub</a>.
"""
