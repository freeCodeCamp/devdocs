defaultUrl = null
currentSlug = null

imageCache = {}
urlCache = {}

withImage = (url, action) ->
  if imageCache[url]
    action(imageCache[url])
  else
    img = new Image()
    img.crossOrigin = 'anonymous'
    img.src = url
    img.onload = () =>
      imageCache[url] = img
      action(img)

@setFaviconForDoc = (doc) ->
  return if currentSlug == doc.slug

  favicon = $('link[rel="icon"]')

  if defaultUrl == null
    defaultUrl = favicon.href

  if urlCache[doc.slug]
    favicon.href = urlCache[doc.slug]
    currentSlug = doc.slug
    return

  iconEl = $("._icon-#{doc.slug.split('~')[0]}")
  return if iconEl == null

  styles = window.getComputedStyle(iconEl, ':before')

  backgroundPositionX = styles['background-position-x']
  backgroundPositionY = styles['background-position-y']
  return if backgroundPositionX == undefined || backgroundPositionY == undefined

  bgUrl = app.config.favicon_spritesheet
  sourceSize = 16
  sourceX = Math.abs(parseInt(backgroundPositionX.slice(0, -2)))
  sourceY = Math.abs(parseInt(backgroundPositionY.slice(0, -2)))

  withImage(bgUrl, (docImg) ->
    withImage(defaultUrl, (defaultImg) ->
      size = defaultImg.width

      canvas = document.createElement('canvas')
      ctx = canvas.getContext('2d')

      canvas.width = size
      canvas.height = size
      ctx.drawImage(defaultImg, 0, 0)

      docIconPercentage = 65
      destinationCoords = size / 100 * (100 - docIconPercentage)
      destinationSize = size / 100 * docIconPercentage

      ctx.drawImage(docImg, sourceX, sourceY, sourceSize, sourceSize, destinationCoords, destinationCoords, destinationSize, destinationSize)

      urlCache[doc.slug] = canvas.toDataURL()
      favicon.href = urlCache[doc.slug]

      currentSlug = doc.slug
    )
  )

@resetFavicon = () ->
  if defaultUrl != null and currentSlug != null
    $('link[rel="icon"]').href = defaultUrl
    currentSlug = null
