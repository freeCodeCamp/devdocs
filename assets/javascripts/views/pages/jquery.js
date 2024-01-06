#= require views/pages/base

class app.views.JqueryPage extends app.views.BasePage
  @demoClassName: '_jquery-demo'

  afterRender: ->
    # Prevent jQuery Mobile's demo iframes from scrolling the page
    for iframe in @findAllByTag 'iframe'
      iframe.style.display = 'none'
      $.on iframe, 'load', @onIframeLoaded

    @runExamples()

  onIframeLoaded: (event) =>
    event.target.style.display = ''
    $.off event.target, 'load', @onIframeLoaded
    return

  runExamples: ->
    for el in @findAllByClass 'entry-example'
      try @runExample el catch
    return

  runExample: (el) ->
    source = el.getElementsByClassName('syntaxhighlighter')[0]
    return unless source and source.innerHTML.indexOf('!doctype') isnt -1

    unless iframe = el.getElementsByClassName(@constructor.demoClassName)[0]
      iframe = document.createElement 'iframe'
      iframe.className = @constructor.demoClassName
      iframe.width = '100%'
      iframe.height = 200
      el.appendChild(iframe)

    doc = iframe.contentDocument
    doc.write @fixIframeSource(source.textContent)
    doc.close()
    return

  fixIframeSource: (source) ->
    source = source.replace '"/resources/', '"https://api.jquery.com/resources/' # attr(), keydown()
    source = source.replace '</head>', """
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
      </head>
    """
    source.replace /<script>/gi, '<script nonce="devdocs">'
