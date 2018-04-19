class @I18n
  constructor: (@data, lang = 'en') ->
    @setLanguage lang

  setLanguage: (lang) ->
    return false unless @data[lang]
    @lang = lang
    true

  _: (key, substitution) ->
    str = @data[@lang][key]
    return unless str?

    if substitution?
      for key in Object.keys(substitution)
        str = str.replace("{#{key}}", substitution[key])
    str
