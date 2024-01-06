#= require_tree ./vendor

#= require lib/license
#= require_tree ./lib

#= require app/app
#= require app/config
#= require_tree ./app

#= require collections/collection
#= require_tree ./collections

#= require models/model
#= require_tree ./models

#= require views/view
#= require_tree ./views

#= require_tree ./templates

#= require tracking

init = ->
  document.removeEventListener 'DOMContentLoaded', init, false

  if document.body
    app.init()
  else
    setTimeout(init, 42)

document.addEventListener 'DOMContentLoaded', init, false
