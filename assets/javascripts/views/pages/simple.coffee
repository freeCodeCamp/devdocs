#= require views/pages/base

class app.views.SimplePage extends app.views.BasePage
  prepare: ->
    for el in @findAll('pre[data-language]')
      @highlightCode el, el.getAttribute('data-language')
    return

app.views.AngularPage =
app.views.AngularjsPage =
app.views.CakephpPage =
app.views.ChaiPage =
app.views.CrystalPage =
app.views.DrupalPage =
app.views.ElixirPage =
app.views.EmberPage =
app.views.ExpressPage =
app.views.GoPage =
app.views.InfluxdataPage =
app.views.KotlinPage =
app.views.LaravelPage =
app.views.LodashPage =
app.views.LovePage =
app.views.MarionettePage =
app.views.MdnPage =
app.views.MeteorPage =
app.views.MochaPage =
app.views.ModernizrPage =
app.views.MomentPage =
app.views.MongoosePage =
app.views.NodePage =
app.views.PerlPage =
app.views.PhalconPage =
app.views.PhaserPage =
app.views.PhpPage =
app.views.PhpunitPage =
app.views.PostgresPage =
app.views.RamdaPage =
app.views.ReactPage =
app.views.ReduxPage =
app.views.RethinkdbPage =
app.views.RubydocPage =
app.views.SinonPage =
app.views.SocketioPage =
app.views.SphinxPage =
app.views.SphinxSimplePage =
app.views.TensorflowPage =
app.views.TypescriptPage =
app.views.UnderscorePage =
app.views.VagrantPage =
app.views.VuePage =
app.views.WebpackPage =
app.views.SimplePage
