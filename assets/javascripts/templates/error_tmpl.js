const error = function (title, text, links) {
  if (text == null) {
    text = "";
  }
  if (links == null) {
    links = "";
  }
  if (text) {
    text = `<p class="_error-text">${text}</p>`;
  }
  if (links) {
    links = `<p class="_error-links">${links}</p>`;
  }
  return `<div class="_error"><h1 class="_error-title">${title}</h1>${text}${links}</div>`;
};

const back = '<a href="#" data-behavior="back" class="_error-link">Go back</a>';

app.templates.notFoundPage = () =>
  error(
    " Page not found. ",
    " It may be missing from the source documentation or this could be a bug. ",
    back,
  );

app.templates.pageLoadError = () =>
  error(
    " The page failed to load. ",
    ` It may be missing from the server (try reloading the app) or you could be offline (try <a href="/offline">installing the documentation for offline usage</a> when online again).<br>
If you're online and you keep seeing this, you're likely behind a proxy or firewall that blocks cross-domain requests. `,
    ` ${back} &middot; <a href="/#${location.pathname}" target="_top" class="_error-link">Reload</a>
&middot; <a href="#" class="_error-link" data-retry>Retry</a> `,
  );

app.templates.bootError = () =>
  error(
    " The app failed to load. ",
    ` Check your Internet connection and try <a href="#" data-behavior="reload">reloading</a>.<br>
If you keep seeing this, you're likely behind a proxy or firewall that blocks cross-domain requests. `,
  );

app.templates.offlineError = function (reason, exception) {
  if (reason === "cookie_blocked") {
    return error(" Cookies must be enabled to use offline mode. ");
  }

  reason = (() => {
    switch (reason) {
      case "not_supported":
        return ` DevDocs requires IndexedDB to cache documentations for offline access.<br>
Unfortunately your browser either doesn't support IndexedDB or doesn't make it available. `;
      case "buggy":
        return ` DevDocs requires IndexedDB to cache documentations for offline access.<br>
Unfortunately your browser's implementation of IndexedDB contains bugs that prevent DevDocs from using it. `;
      case "private_mode":
        return ` Your browser appears to be running in private mode.<br>
This prevents DevDocs from caching documentations for offline access.`;
      case "exception":
        return ` An error occurred when trying to open the IndexedDB database:<br>
<code class="_label">${exception.name}: ${exception.message}</code> `;
      case "cant_open":
        return ` An error occurred when trying to open the IndexedDB database:<br>
<code class="_label">${exception.name}: ${exception.message}</code><br>
This could be because you're browsing in private mode or have disallowed offline storage on the domain. `;
      case "version":
        return ` The IndexedDB database was modified with a newer version of the app.<br>
<a href="#" data-behavior="reload">Reload the page</a> to use offline mode. `;
      case "empty":
        return ' The IndexedDB database appears to be corrupted. Try <a href="#" data-behavior="reset">resetting the app</a>. ';
    }
  })();

  return error("Offline mode is unavailable.", reason);
};

app.templates.unsupportedBrowser = `\
<div class="_fail">
  <h1 class="_fail-title">Your browser is unsupported, sorry.</h1>
  <p class="_fail-text">DevDocs is an API documentation browser which supports the following browsers:
  <ul class="_fail-list">
    <li>Recent versions of Firefox, Chrome, or Opera
    <li>Safari 11.1+
    <li>Edge 17+
    <li>iOS 11.3+
  </ul>
  <p class="_fail-text">
    If you're unable to upgrade, we apologize.
    We decided to prioritize speed and new features over support for older browsers.
  <p class="_fail-text">
    Note: if you're already using one of the browsers above, check your settings and add-ons.
    The app uses feature detection, not user agent sniffing.
  <p class="_fail-text">
    &mdash; <a href="https://twitter.com/DevDocs">@DevDocs</a>
</div>\
`;
