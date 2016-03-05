#= require views/pages/base

class app.views.HaxePage extends app.views.BasePage
  @className: '_haxe'

  # We need to extract data from a header to have the name of the class reconize as the title of the page
  prepare: ->
    nodes = []
    # Extract all children of page-header
    header = @findByClass('page-header')
    if header
      for child in header.children
          nodes.push(child)

      # Ensure H1 is on top
      nodes.sort (a,b) ->
        if a.nodeName == 'h1'
          return -1
        return 0

      firstChild = header.parentNode.firstChild
      # Add them to the parent of header
      for node in nodes
        header.parentNode.insertBefore( node, firstChild )

    # Add an id to class fields for additional entries
    for el in @findAllByClass('identifier')
      el['id'] = el.textContent

    return
