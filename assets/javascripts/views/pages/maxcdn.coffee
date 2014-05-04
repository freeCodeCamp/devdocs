#= require views/pages/base

class app.views.MaxcdnPage extends app.views.BasePage
  @events:
    click: 'onClick'

  afterRender: ->
    @highlightCode @findAll('.tab-pane[id^="ruby"] > pre'), 'ruby'
    @highlightCode @findAll('.tab-pane[id^="python"] > pre'), 'python'
    @highlightCode @findAll('.tab-pane[id^="node"] > pre, .tab-pane[id^="resp"] > pre'), 'javascript'
    return

  onClick: (event) ->
    return unless (link = event.target).getAttribute('data-toggle') is 'tab'
    $.stopEvent(event)

    list = link.parentNode.parentNode
    tabs = list.nextElementSibling

    li = link.parentNode
    position = 1
    position++ while li = li.previousElementSibling

    $('.active', list).classList.remove('active')
    $('.active', tabs).classList.remove('active')

    link.parentNode.classList.add('active')
    $(".tab-pane:nth-child(#{position})", tabs).classList.add('active')
