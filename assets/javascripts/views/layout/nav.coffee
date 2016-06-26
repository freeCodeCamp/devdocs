class app.views.Nav extends app.View
  @el: '._nav'
  @activeClass: '_nav-current'

  @routes:
    after: 'afterRoute'

  select: (href) ->
    @deselect()
    if @current = @find "a[href='#{href}']"
      @current.classList.add @constructor.activeClass
      @current.setAttribute 'tabindex', '-1'
    return

  deselect: ->
    if @current
      @current.classList.remove @constructor.activeClass
      @current.removeAttribute 'tabindex'
      @current = null
    return

  afterRoute: (route, context) =>
    if route in ['page', 'offline']
      @select context.pathname
    else
      @deselect()
