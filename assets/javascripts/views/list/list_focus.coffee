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
    @focus = $.framify(@focus, @)

  focus: (el) ->
    if el and not el.classList.contains @constructor.activeClass
      @blur()
      el.classList.add @constructor.activeClass
      $.trigger el, 'focus'
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
        if cursor.className.indexOf('open') >= 0
          @findFirst(next) or @findNext(next)
        else
          @findNext(next)
      else if next.tagName is 'H6' # title
        @findNext(next)
    else if cursor.parentElement isnt @el
      @findNext cursor.parentElement

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
    else if cursor.parentElement isnt @el
      @findPrev cursor.parentElement

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
      @focus @findNext(cursor)
    else
      @focus @findByTag('a')
    return

  onUp: =>
    if cursor = @getCursor()
      @focus @findPrev(cursor)
    else
      @focus @findLastByTag('a')
    return

  onLeft: =>
    cursor = @getCursor()
    if cursor and not cursor.classList.contains(app.views.ListFold.activeClass) and cursor.parentElement isnt @el
      @focus cursor.parentElement.previousSibling
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
    if event.target.tagName is 'A'
      @focus event.target
    return
