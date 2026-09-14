// @ts-check

// A classic script, deliberately not a module: it has to run in browsers that
// cannot load the module graph at all.
//
// The app is served as ES modules whose relative imports are rewritten onto
// their digested URLs by an import map. A browser that supports modules but
// not import maps resolves those imports against the undigested paths, gets a
// 404 for every one, and sits on the loading screen forever — and because the
// in-app compatibility check lives inside the graph, it never runs to say why.
//
// Import maps are the newest thing the app needs, so testing for them stands
// in for the whole baseline.
(function () {
  if (
    window.HTMLScriptElement &&
    typeof HTMLScriptElement.supports === "function" &&
    HTMLScriptElement.supports("importmap")
  ) {
    return;
  }

  document.body.innerHTML = `\
<div class="_fail">
  <h1 class="_fail-title">Your browser is unsupported, sorry.</h1>
  <p class="_fail-text">DevDocs is an API documentation browser which supports the following browsers:
  <ul class="_fail-list">
    <li>Recent versions of Firefox, Chrome, or Opera
    <li>Safari 16.4+
    <li>Edge 89+
    <li>iOS 16.4+
  </ul>
  <p class="_fail-text">
    If you're unable to upgrade, we apologize.
    We decided to prioritize speed and new features over support for older browsers.
</div>`;
})();
