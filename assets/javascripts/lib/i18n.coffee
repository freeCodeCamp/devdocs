class @I18n
  default: 'en'
  constructor: (@langs = [@default], @phrases) ->

  _: (obj, substitution) =>
    if typeof obj is 'object' or typeof obj is 'function'
      @interpolate obj[@get_lang obj], substitution
    else
      obj

  __: (key) =>
    lang = @get_lang @phrases, (lang) => @phrases[lang]?[key]
    @phrases[lang]?[key] ? ''

  get_lang: (obj, test = (lang) -> obj[lang]) ->
    for lang in @langs
      # eg. en-US
      return lang if test lang

      lang = lang.replace /_\w+$/, ''
      # eg. en
      return lang if test lang

    @default

  interpolate: (str, substitution) ->
    return '' if not str?
    if substitution?
      for key in Object.keys(substitution)
        str = str.replace("{#{key}}", substitution[key])
    str

@i18n = new I18n navigator.languages,
  en:
    enable: "Enable"
    documentation: "Documentation"
  ja:
    enable: "有効"
    documentation: "ドキュメンテーション"

@_ = @i18n._
@__ = @i18n.__
