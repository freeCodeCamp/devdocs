app.templates.render = (name, value, args...) ->
  template = app.templates[name]

  if Array.isArray(value)
    result = ''
    result += template(val, args...) for val in value
    result
  else if typeof template is 'function'
    template(value, args...)
  else
    template
