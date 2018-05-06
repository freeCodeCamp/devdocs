app.templates.settingsPage = (settings) -> _
  en: """
    <h1 class="_lined-heading">Preferences</h1>

    <div class="_settings-fieldset">
      <h2 class="_settings-legend">General:</h2>

      <div class="_settings-inputs">
        <label class="_settings-label">
          <input type="checkbox" form="settings" name="dark" value="1"#{if settings.dark then ' checked' else ''}>Enable dark theme
        </label>
        <label class="_settings-label _setting-max-width">
          <input type="checkbox" form="settings" name="layout" value="_max-width"#{if settings['_max-width'] then ' checked' else ''}>Enable fixed-width layout
        </label>
        <label class="_settings-label _hide-on-mobile">
          <input type="checkbox" form="settings" name="layout" value="_sidebar-hidden"#{if settings['_sidebar-hidden'] then ' checked' else ''}>Automatically hide and show the sidebar
          <small>Tip: drag the edge of the sidebar to resize it.</small>
        </label>
      </div>
    </div>

    <div class="_settings-fieldset _hide-on-mobile">
      <h2 class="_settings-legend">Scrolling:</h2>

      <div class="_settings-inputs">
        <label class="_settings-label">
          <input type="checkbox" form="settings" name="smoothScroll" value="1"#{if settings.smoothScroll then ' checked' else ''}>Use smooth scrolling
        </label>
        <label class="_settings-label _setting-native-scrollbar">
          <input type="checkbox" form="settings" name="layout" value="_native-scrollbars"#{if settings['_native-scrollbars'] then ' checked' else ''}>Use native scrollbars
        </label>
        <label class="_settings-label">
          <input type="checkbox" form="settings" name="arrowScroll" value="1"#{if settings.arrowScroll then ' checked' else ''}>Use arrow keys to scroll the main content area
          <small>With this checked, use <code class="_label">alt</code> + <code class="_label">&uarr;</code><code class="_label">&darr;</code><code class="_label">&larr;</code><code class="_label">&rarr;</code> to navigate the sidebar.</small>
        </label>
      </div>
    </div>

    <p class="_hide-on-mobile">
      <button type="button" class="_btn" data-action="export">Export</button>
      <label class="_btn _file-btn"><input type="file" form="settings" name="import" accept=".json">Import</label>

    <p>
      <button type="button" class="_btn-link _reset-btn" data-behavior="reset">Reset all preferences and data</button>
  """
  ja: """
    <h1 class="_lined-heading">設定</h1>
    <div class="_settings-fieldset">
      <h2 class="_settings-legend">一般:</h2>
      <div class="_settings-inputs">
        <label class="_settings-label">
          <input type="checkbox" form="settings" name="dark" value="1"#{if settings.dark then ' checked' else ''}>ダークテーマを有効にする
        </label>
        <label class="_settings-label _setting-max-width">
          <input type="checkbox" form="settings" name="layout" value="_max-width"#{if settings['_max-width'] then ' checked' else ''}>fixed-width レイアウトを有効にする
        </label>
        <label class="_settings-label _hide-on-mobile">
          <input type="checkbox" form="settings" name="layout" value="_sidebar-hidden"#{if settings['_sidebar-hidden'] then ' checked' else ''}>サイドバーを自動で開閉する
          <small>Tip:サイドバーのふちをドラッグすると、サイズ調整できます。</small>
        </label>
      </div>
    </div>
    <div class="_settings-fieldset _hide-on-mobile">
      <h2 class="_settings-legend">スクロール:</h2>
      <div class="_settings-inputs">
        <label class="_settings-label">
          <input type="checkbox" form="settings" name="smoothScroll" value="1"#{if settings.smoothScroll then ' checked' else ''}>スムーズスクロールを使用する
        </label>
        <label class="_settings-label _setting-native-scrollbar">
          <input type="checkbox" form="settings" name="layout" value="_native-scrollbars"#{if settings['_native-scrollbars'] then ' checked' else ''}>本来のスクロールバーを使用する
        </label>
        <label class="_settings-label">
          <input type="checkbox" form="settings" name="arrowScroll" value="1"#{if settings.arrowScroll then ' checked' else ''}>矢印キーを使用してメインコンテンツエリアをスクロールする
          <small>With this checked, use <code class="_label">alt</code> + <code class="_label">&uarr;</code><code class="_label">&darr;</code><code class="_label">&larr;</code><code class="_label">&rarr;</code> to navigate the sidebar.</small>
        </label>
      </div>
    </div>
    <p class="_hide-on-mobile">
      <button type="button" class="_btn" data-action="export">エクスポート</button>
      <label class="_btn _file-btn"><input type="file" form="settings" name="import" accept=".json">インポート</label>
    <p>
      <button type="button" class="_btn-link _reset-btn" data-behavior="reset">すべての設定とデータをリセットする</button>
  """
