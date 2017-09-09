class app.views.ListFocus extends app.View
  @activeClass: 'focus'

  @events:
    click: 'onClick'

  @shortcuts:
    up:         'onUp'
    down:       'onDown'
    left:       'onLeft'
    enter:      'onEnter'
    superEnter: 'onSuperEnter'
    escape:     'blur'

  constructor: (@el) ->
    super
    @focusOnNextFrame = $.framify(@focus, @)

  focus: (el, options = {}) ->
    if el and not el.classList.contains @constructor.activeClass
      @blur()
      el.classList.add @constructor.activeClass
      $.trigger el, 'focus' unless options.silent is true
    return

  blur: =>
    if cursor = @getCursor()
      cursor.classList.remove @constructor.activeClass
      $.trigger cursor, 'blur'
    return

  getCursor: ->
    @findByClass(@constructor.activeClass) or @findByClass(app.views.ListSelect.activeClass)

  findNext: (cursor) ->
    if next = cursor.nextSibling
      if next.tagName is 'A'
        next
      else if next.tagName is 'SPAN' # pagination link
        $.click(next)
        @findNext cursor
      else if next.tagName is 'DIV' # sub-list
        if cursor.className.indexOf(' open') >= 0
          @findFirst(next) or @findNext(next)
        else
          @findNext(next)
      else if next.tagName is 'H6' # title
        @findNext(next)
    else if cursor.parentNode isnt @el
      @findNext cursor.parentNode

  findFirst: (cursor) ->
    return unless first = cursor.firstChild

    if first.tagName is 'A'
      first
    else if first.tagName is 'SPAN' # pagination link
      $.click(first)
      @findFirst cursor

  findPrev: (cursor) ->
    if prev = cursor.previousSibling
      if prev.tagName is 'A'
        prev
      else if prev.tagName is 'SPAN' # pagination link
        $.click(prev)
        @findPrev cursor
      else if prev.tagName is 'DIV' # sub-list
        if prev.previousSibling.className.indexOf('open') >= 0
          @findLast(prev) or @findPrev(prev)
        else
          @findPrev(prev)
      else if prev.tagName is 'H6' # title
        @findPrev(prev)
    else if cursor.parentNode isnt @el
      @findPrev cursor.parentNode

  findLast: (cursor) ->
    return unless last = cursor.lastChild

    if last.tagName is 'A'
      last
    else if last.tagName is 'SPAN' or last.tagName is 'H6' # pagination link or title
      @findPrev last
    else if last.tagName is 'DIV' # sub-list
      @findLast last

  onDown: =>
    if cursor = @getCursor()
      @focusOnNextFrame @findNext(cursor)
    else
      @focusOnNextFrame @findByTag('a')
    return

  onUp: =>
    if cursor = @getCursor()
      @focusOnNextFrame @findPrev(cursor)
    else
      @focusOnNextFrame @findLastByTag('a')
    return

  onLeft: =>
    cursor = @getCursor()
    if cursor and not cursor.classList.contains(app.views.ListFold.activeClass) and cursor.parentNode isnt @el
      prev = cursor.parentNode.previousSibling
      @focusOnNextFrame cursor.parentNode.previousSibling if prev and prev.classList.contains(app.views.ListFold.targetClass)
    return

  onEnter: =>
    if cursor = @getCursor()
      $.click(cursor)
    return

  onSuperEnter: =>
    if cursor = @getCursor()
      $.popup(cursor)
    return

  onClick: (event) =>
    return if event.which isnt 1 or event.metaKey or event.ctrlKey
    target = $.eventTarget(event)
    if target.tagName is 'A'
      @focus target, silent: true
    return
