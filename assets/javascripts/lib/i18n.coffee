class @I18n
  default: 'en'
  constructor: (@langs = [@default]) ->

  _: (obj, substitution) =>
    if typeof obj is 'object' or typeof obj is 'function'
      @interpolate obj[@get_lang obj], substitution
    else
      obj

  get_lang: (obj) ->
    for lang in @langs
      # eg. en-US
      return lang if obj[lang]

      lang = lang.replace /_\w+$/, ''
      # eg. en
      return lang if obj[lang]

    @default

  interpolate: (str, substitution) ->
    return '' if not str?
    if substitution?
      for key in Object.keys(substitution)
        str = str.replace("{#{key}}", substitution[key])
    str

@i18n = new I18n navigator.languages
@_ = @i18n._
