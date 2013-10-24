class app.views.Nav extends app.View
  @el: '._nav'
  @activeClass: '_nav-current'

  @routes:
    after: 'afterRoute'

  select: (href) ->
    @deselect()
    if @current = @find "a[href='#{href}']"
      @current.classList.add @constructor.activeClass
    return

  deselect: ->
    if @current
      @current.classList.remove @constructor.activeClass
      @current = null
    return

  afterRoute: (route, context) =>
    if route is 'page'
      @select context.pathname
    else
      @deselect()
