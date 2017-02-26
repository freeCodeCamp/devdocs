class app.views.DocPicker extends app.View
  @className: '_list _list-picker'

  @events:
    mousedown: 'onMouseDown'

  init: ->
    @addSubview @listFold = new app.views.ListFold(@el)
    return

  activate: ->
    if super
      @render()
      $.on @el, 'focus', @onDOMFocus, true
    return

  deactivate: ->
    if super
      @empty()
      $.off @el, 'focus', @onDOMFocus, true
      @focusEl = null
    return

  render: ->
    html = ''
    docs = app.docs.all().concat(app.disabledDocs.all()...)

    while doc = docs.shift()
      if doc.version?
        [docs, versions] = @extractVersions(docs, doc)
        html += @tmpl('sidebarVersionedDoc', doc, @renderVersions(versions), open: app.docs.contains(doc))
      else
        html += @tmpl('sidebarLabel', doc, checked: app.docs.contains(doc))

    @html html + @tmpl('docPickerNote')

    $.requestAnimationFrame =>
      @addClass '_in'
      @findByTag('input')?.focus()
    return

  renderVersions: (docs) ->
    html = ''
    html += @tmpl('sidebarLabel', doc, checked: app.docs.contains(doc)) for doc in docs
    html

  extractVersions: (originalDocs, version) ->
    docs = []
    versions = [version]
    for doc in originalDocs
      (if doc.name is version.name then versions else docs).push(doc)
    [docs, versions]

  empty: ->
    @resetClass()
    super
    return

  getSelectedDocs: ->
    for input in @findAllByTag 'input' when input?.checked
      input.name

  onMouseDown: =>
    @mouseDown = Date.now()
    return

  onDOMFocus: (event) =>
    target = event.target
    if target.tagName is 'INPUT'
      $.scrollTo target.parentNode, null, 'continuous', bottomGap: 2
    else if target.classList.contains(app.views.ListFold.targetClass)
      target.blur()
      unless @mouseDown and @mouseDown > Date.now() - 100
        if @focusEl is $('input', target.nextElementSibling)
          @listFold.close(target) if target.classList.contains(app.views.ListFold.activeClass)
          prev = target.previousElementSibling
          prev = prev.previousElementSibling until prev.tagName is 'LABEL' or prev.classList.contains(app.views.ListFold.targetClass)
          prev = $.makeArray($$('input', prev.nextElementSibling)).pop() if prev.classList.contains(app.views.ListFold.activeClass)
          @delay -> prev.focus()
        else
          @listFold.open(target) unless target.classList.contains(app.views.ListFold.activeClass)
          @delay -> $('input', target.nextElementSibling).focus()
    @focusEl = target
    return
