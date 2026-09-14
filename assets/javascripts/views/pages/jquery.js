// @ts-check

//= require views/pages/base

/**
 * The jQuery docs' runnable examples, each rendered into its own iframe.
 *
 * The example's source is rewritten first: its relative URLs are pointed at
 * the API site, and a prefilter is injected that aborts any request that would
 * leave it, since they can't work from inside DevDocs.
 */
class JqueryPage extends BasePage {
  static demoClassName = "_jquery-demo";

  /** @inheritdoc */
  afterRender() {
    // Prevent jQuery Mobile's demo iframes from scrolling the page
    for (var iframe of this.findAllByTag("iframe")) {
      iframe.style.display = "none";
      this.onIframeLoaded = this.onIframeLoaded.bind(this);
      $.on(iframe, "load", this.onIframeLoaded);
    }

    return this.runExamples();
  }

  /** @param {ViewEvent} event */
  onIframeLoaded(event) {
    event.target.style.display = "";
    $.off(event.target, "load", this.onIframeLoaded);
  }

  /** Renders every example on the page. */
  runExamples() {
    for (var el of this.findAllByClass("entry-example")) {
      try {
        this.runExample(el);
      } catch (error) {}
    }
  }

  /** @param {HTMLElement} el The example's container. */
  runExample(el) {
    const source = el.getElementsByClassName("syntaxhighlighter")[0];
    if (!source || source.innerHTML.indexOf("!doctype") === -1) {
      return;
    }

    let iframe = /** @type {HTMLIFrameElement} */ (
      el.getElementsByClassName(JqueryPage.demoClassName)[0]
    );
    if (!iframe) {
      iframe = document.createElement("iframe");
      iframe.className = JqueryPage.demoClassName;
      iframe.width = "100%";
      iframe.height = "200";
      el.appendChild(iframe);
    }

    const doc = iframe.contentDocument;
    doc.write(this.fixIframeSource(source.textContent));
    doc.close();
  }

  /**
   * @param {string} source
   * @returns {string} The example's HTML, fixed up to run inside the app.
   */
  fixIframeSource(source) {
    source = source.replace(
      '"/resources/',
      '"https://api.jquery.com/resources/',
    ); // attr(), keydown()
    source = source.replace(
      "</head>",
      `\
<style>
  html, body { border: 0; margin: 0; padding: 0; }
  body { font-family: 'Helvetica Neue', Helvetica, Arial, sans-serif; }
</style>
<script>
  $.ajaxPrefilter(function(opt, opt2, xhr) {
    if (opt.url.indexOf('http') !== 0) {
      xhr.abort();
      document.body.innerHTML = "<p><strong>This demo cannot run inside DevDocs.</strong></p>";
    }
  });
</script>
</head>\
`,
    );
    return source.replace(/<script>/gi, '<script nonce="devdocs">');
  }
}

// Registered on `app` so that the rest of the code can reach it; declared at
// the top level so that it can be named in a type.
app.views.JqueryPage = JqueryPage;
