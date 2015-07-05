#= require views/pages/base

class app.views.JavascriptPage extends app.views.BasePage
  afterRender: ->
    @highlightCode @findAllByTag('pre'), 'javascript'
    return

class app.views.JavascriptWithMarkupCheckPage extends app.views.BasePage
  afterRender: ->
    for el in @findAllByTag('pre')
      language = if el.textContent.match(/^\s*</)
        'markup'
      else
        'javascript'
      @highlightCode el, language
    return

app.views.ChaiPage =
app.views.ExpressPage =
app.views.GruntPage =
app.views.LodashPage =
app.views.MarionettePage =
app.views.MochaPage =
app.views.ModernizrPage =
app.views.MomentPage =
app.views.MongoosePage =
app.views.NodePage =
app.views.PhaserPage =
app.views.RethinkdbPage =
app.views.SinonPage =
app.views.UnderscorePage =
app.views.WebpackPage =
app.views.JavascriptPage

app.views.RequirejsPage =
app.views.SocketioPage =
app.views.VuePage =
app.views.JavascriptWithMarkupCheckPage
