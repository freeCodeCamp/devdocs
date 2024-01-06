class app.views.PaginatedList extends app.View
  PER_PAGE = app.config.max_results

  constructor: (@data) ->
    (@constructor.events or= {}).click ?= 'onClick'
    super

  renderPaginated: ->
    @page = 0

    if @totalPages() > 1
      @paginateNext()
    else
      @html @renderAll()
    return

  # render: (dataSlice) -> implemented by subclass

  renderAll: ->
    @render @data

  renderPage: (page) ->
    @render @data[((page - 1) * PER_PAGE)...(page * PER_PAGE)]

  renderPageLink: (count) ->
    @tmpl 'sidebarPageLink', count

  renderPrevLink: (page) ->
    @renderPageLink (page - 1) * PER_PAGE

  renderNextLink: (page) ->
    @renderPageLink @data.length - page * PER_PAGE

  totalPages: ->
    Math.ceil @data.length / PER_PAGE

  paginate: (link) ->
    $.lockScroll link.nextSibling or link.previousSibling, =>
      $.batchUpdate @el, =>
        if link.nextSibling then @paginatePrev link else @paginateNext link
        return
      return
    return

  paginateNext: ->
    @remove @el.lastChild if @el.lastChild # remove link
    @hideTopPage() if @page >= 2 # keep previous page into view
    @page++
    @append @renderPage(@page)
    @append @renderNextLink(@page) if @page < @totalPages()
    return

  paginatePrev: ->
    @remove @el.firstChild # remove link
    @hideBottomPage()
    @page--
    @prepend @renderPage(@page - 1) # previous page is offset by one
    @prepend @renderPrevLink(@page - 1) if @page >= 3
    return

  paginateTo: (object) ->
    index = @data.indexOf(object)
    if index >= PER_PAGE
      @paginateNext() for [0...(index // PER_PAGE)]
    return

  hideTopPage: ->
    n = if @page <= 2
      PER_PAGE
    else
      PER_PAGE + 1 # remove link
    @remove @el.firstChild for [0...n]
    @prepend @renderPrevLink(@page)
    return

  hideBottomPage: ->
    n = if @page is @totalPages()
      @data.length % PER_PAGE or PER_PAGE
    else
      PER_PAGE + 1 # remove link
    @remove @el.lastChild for [0...n]
    @append @renderNextLink(@page - 1)
    return

  onClick: (event) =>
    target = $.eventTarget(event)
    if target.tagName is 'SPAN' # link
      $.stopEvent(event)
      @paginate target
    return
