class app.Model
  constructor: (attributes) ->
    @[key] = value for key, value of attributes
