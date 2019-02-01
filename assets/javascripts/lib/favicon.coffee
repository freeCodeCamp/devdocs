defaultUrl = null
currentSlug = null

imageCache = {}
urlCache = {}

withImage = (url, action) ->
  if imageCache[url]
    action(imageCache[url])
  else
    img = new Image()
    img.src = url
    img.onload = () =>
      imageCache[url] = img
      action(img)

@setFaviconForDoc = (doc) ->
  return if currentSlug == doc.slug

  favicon = $('link[rel="icon"]')

  if urlCache[doc.slug]
    favicon.href = urlCache[doc.slug]
    currentSlug = doc.slug
    return

  styles = window.getComputedStyle($("._icon-#{doc.slug}"), ':before')

  bgUrl = styles['background-image'].slice(5, -2)
  bgSize = if bgUrl.includes('@2x') then 32 else 16
  bgX = parseInt(styles['background-position-x'].slice(0, -2))
  bgY = parseInt(styles['background-position-y'].slice(0, -2))

  withImage(bgUrl, (img) ->
    canvas = document.createElement('canvas')

    canvas.width = bgSize
    canvas.height = bgSize
    canvas.getContext('2d').drawImage(img, bgX, bgY)

    if defaultUrl == null
      defaultUrl = favicon.href

    urlCache[doc.slug] = canvas.toDataURL()
    favicon.href = urlCache[doc.slug]

    currentSlug = doc.slug
  )

@resetFavicon = () ->
  if defaultUrl != null and currentSlug != null
    $('link[rel="icon"]').href = defaultUrl
    currentSlug = null
