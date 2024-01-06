class app.Collection
  constructor: (objects = []) ->
    @reset objects

  model: ->
    app.models[@constructor.model]

  reset: (objects = []) ->
    @models = []
    @add object for object in objects
    return

  add: (object) ->
    if object instanceof app.Model
      @models.push object
    else if object instanceof Array
      @add obj for obj in object
    else if object instanceof app.Collection
      @models.push object.all()...
    else
      @models.push new (@model())(object)
    return

  remove: (model) ->
    @models.splice @models.indexOf(model), 1
    return

  size: ->
    @models.length

  isEmpty: ->
    @models.length is 0

  each: (fn) ->
    fn(model) for model in @models
    return

  all: ->
    @models

  contains: (model) ->
    @models.indexOf(model) >= 0

  findBy: (attr, value) ->
    for model in @models
      return model if model[attr] is value
    return

  findAllBy: (attr, value) ->
    model for model in @models when model[attr] is value

  countAllBy: (attr, value) ->
    i = 0
    i += 1 for model in @models when model[attr] is value
    i
