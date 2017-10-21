#
# Traversing
#

@$ = (selector, el = document) ->
  try el.querySelector(selector) catch

@$$ = (selector, el = document) ->
  try el.querySelectorAll(selector) catch

$.id = (id) ->
  document.getElementById(id)

$.hasChild = (parent, el) ->
  return unless parent
  while el
    return true if el is parent
    return if el is document.body
    el = el.parentNode

$.closestLink = (el, parent = document.body) ->
  while el
    return el if el.tagName is 'A'
    return if el is parent
    el = el.parentNode

#
# Events
#

$.on = (el, event, callback, useCapture = false) ->
  if event.indexOf(' ') >= 0
    $.on el, name, callback for name in event.split(' ')
  else
    el.addEventListener(event, callback, useCapture)
  return

$.off = (el, event, callback, useCapture = false) ->
  if event.indexOf(' ') >= 0
    $.off el, name, callback for name in event.split(' ')
  else
    el.removeEventListener(event, callback, useCapture)
  return

$.trigger = (el, type, canBubble = true, cancelable = true) ->
  event = document.createEvent 'Event'
  event.initEvent(type, canBubble, cancelable)
  el.dispatchEvent(event)
  return

$.click = (el) ->
  event = document.createEvent 'MouseEvent'
  event.initMouseEvent 'click', true, true, window, null, 0, 0, 0, 0, false, false, false, false, 0, null
  el.dispatchEvent(event)
  return

$.stopEvent = (event) ->
  event.preventDefault()
  event.stopPropagation()
  event.stopImmediatePropagation()
  return

$.eventTarget = (event) ->
  event.target.correspondingUseElement || event.target

#
# Manipulation
#

buildFragment = (value) ->
  fragment = document.createDocumentFragment()

  if $.isCollection(value)
    fragment.appendChild(child) for child in $.makeArray(value)
  else
    fragment.innerHTML = value

  fragment

$.append = (el, value) ->
  if typeof value is 'string'
    el.insertAdjacentHTML 'beforeend', value
  else
    value = buildFragment(value) if $.isCollection(value)
    el.appendChild(value)
  return

$.prepend = (el, value) ->
  if not el.firstChild
    $.append(value)
  else if typeof value is 'string'
    el.insertAdjacentHTML 'afterbegin', value
  else
    value = buildFragment(value) if $.isCollection(value)
    el.insertBefore(value, el.firstChild)
  return

$.before = (el, value) ->
  if typeof value is 'string' or $.isCollection(value)
    value = buildFragment(value)

  el.parentNode.insertBefore(value, el)
  return

$.after = (el, value) ->
  if typeof value is 'string' or $.isCollection(value)
    value = buildFragment(value)

  if el.nextSibling
    el.parentNode.insertBefore(value, el.nextSibling)
  else
    el.parentNode.appendChild(value)
  return

$.remove = (value) ->
  if $.isCollection(value)
    el.parentNode?.removeChild(el) for el in $.makeArray(value)
  else
    value.parentNode?.removeChild(value)
  return

$.empty = (el) ->
  el.removeChild(el.firstChild) while el.firstChild
  return

# Calls the function while the element is off the DOM to avoid triggering
# unnecessary reflows and repaints.
$.batchUpdate = (el, fn) ->
  parent = el.parentNode
  sibling = el.nextSibling
  parent.removeChild(el)

  fn(el)

  if (sibling)
    parent.insertBefore(el, sibling)
  else
    parent.appendChild(el)
  return

#
# Offset
#

$.rect = (el) ->
  el.getBoundingClientRect()

$.offset = (el, container = document.body) ->
  top = 0
  left = 0

  while el and el isnt container
    top += el.offsetTop
    left += el.offsetLeft
    el = el.offsetParent

  top: top
  left: left

$.scrollParent = (el) ->
  while (el = el.parentNode) and el.nodeType is 1
    break if el.scrollTop > 0
    break if getComputedStyle(el)?.overflowY in ['auto', 'scroll']
  el

$.scrollTo = (el, parent, position = 'center', options = {}) ->
  return unless el

  parent ?= $.scrollParent(el)
  return unless parent

  parentHeight = parent.clientHeight
  parentScrollHeight = parent.scrollHeight
  return unless parentScrollHeight > parentHeight

  top = $.offset(el, parent).top
  offsetTop = parent.firstElementChild.offsetTop

  switch position
    when 'top'
      parent.scrollTop = top - offsetTop - (if options.margin? then options.margin else 0)
    when 'center'
      parent.scrollTop = top - Math.round(parentHeight / 2 - el.offsetHeight / 2)
    when 'continuous'
      scrollTop = parent.scrollTop
      height = el.offsetHeight

      lastElementOffset = parent.lastElementChild.offsetTop + parent.lastElementChild.offsetHeight
      offsetBottom = if lastElementOffset > 0 then parentScrollHeight - lastElementOffset else 0

      # If the target element is above the visible portion of its scrollable
      # ancestor, move it near the top with a gap = options.topGap * target's height.
      if top - offsetTop <= scrollTop + height * (options.topGap or 1)
        parent.scrollTop = top - offsetTop - height * (options.topGap or 1)
      # If the target element is below the visible portion of its scrollable
      # ancestor, move it near the bottom with a gap = options.bottomGap * target's height.
      else if top + offsetBottom >= scrollTop + parentHeight - height * ((options.bottomGap or 1) + 1)
        parent.scrollTop = top + offsetBottom - parentHeight + height * ((options.bottomGap or 1) + 1)
  return

$.scrollToWithImageLock = (el, parent, args...) ->
  parent ?= $.scrollParent(el)
  return unless parent

  $.scrollTo el, parent, args...

  # Lock the scroll position on the target element for up to 3 seconds while
  # nearby images are loaded and rendered.
  for image in parent.getElementsByTagName('img') when not image.complete
    do ->
      onLoad = (event) ->
        clearTimeout(timeout)
        unbind(event.target)
        $.scrollTo el, parent, args...

      unbind = (target) ->
        $.off target, 'load', onLoad

      $.on image, 'load', onLoad
      timeout = setTimeout unbind.bind(null, image), 3000
  return

# Calls the function while locking the element's position relative to the window.
$.lockScroll = (el, fn) ->
  if parent = $.scrollParent(el)
    top = $.rect(el).top
    top -= $.rect(parent).top unless parent in [document.body, document.documentElement]
    fn()
    parent.scrollTop = $.offset(el, parent).top - top
  else
    fn()
  return

smoothScroll =  smoothStart = smoothEnd = smoothDistance = smoothDuration = null

$.smoothScroll = (el, end) ->
  unless window.requestAnimationFrame
    el.scrollTop = end
    return

  smoothEnd = end

  if smoothScroll
    newDistance = smoothEnd - smoothStart
    smoothDuration += Math.min 300, Math.abs(smoothDistance - newDistance)
    smoothDistance = newDistance
    return

  smoothStart = el.scrollTop
  smoothDistance = smoothEnd - smoothStart
  smoothDuration = Math.min 300, Math.abs(smoothDistance)
  startTime = Date.now()

  smoothScroll = ->
    p = Math.min 1, (Date.now() - startTime) / smoothDuration
    y = Math.max 0, Math.floor(smoothStart + smoothDistance * (if p < 0.5 then 2 * p * p else p * (4 - p * 2) - 1))
    el.scrollTop = y
    if p is 1
      smoothScroll = null
    else
      requestAnimationFrame(smoothScroll)
  requestAnimationFrame(smoothScroll)

#
# Utilities
#

$.extend = (target, objects...) ->
  for object in objects when object
    for key, value of object
      target[key] = value
  target

$.makeArray = (object) ->
  if Array.isArray(object)
    object
  else
    Array::slice.apply(object)

$.arrayDelete = (array, object) ->
  index = array.indexOf(object)
  if index >= 0
    array.splice(index, 1)
    true
  else
    false

# Returns true if the object is an array or a collection of DOM elements.
$.isCollection = (object) ->
  Array.isArray(object) or typeof object?.item is 'function'

ESCAPE_HTML_MAP =
  '&': '&amp;'
  '<': '&lt;'
  '>': '&gt;'
  '"': '&quot;'
  "'": '&#x27;'
  '/': '&#x2F;'

ESCAPE_HTML_REGEXP = /[&<>"'\/]/g

$.escape = (string) ->
  string.replace ESCAPE_HTML_REGEXP, (match) -> ESCAPE_HTML_MAP[match]

ESCAPE_REGEXP = /([.*+?^=!:${}()|\[\]\/\\])/g

$.escapeRegexp = (string) ->
  string.replace ESCAPE_REGEXP, "\\$1"

$.urlDecode = (string) ->
  decodeURIComponent string.replace(/\+/g, '%20')

$.classify = (string) ->
  string = string.split('_')
  for substr, i in string
    string[i] = substr[0].toUpperCase() + substr[1..]
  string.join('')

$.framify = (fn, obj) ->
  if window.requestAnimationFrame
    (args...) -> requestAnimationFrame(fn.bind(obj, args...))
  else
    fn

$.requestAnimationFrame = (fn) ->
  if window.requestAnimationFrame
    requestAnimationFrame(fn)
  else
    setTimeout(fn, 0)
  return

#
# Miscellaneous
#

$.noop = ->

$.popup = (value) ->
  try
    win = window.open()
    win.opener = null if win.opener
    win.location = value.href or value
  catch
    window.open value.href or value, '_blank'
  return

isMac = null
$.isMac = ->
  isMac ?= navigator.userAgent?.indexOf('Mac') >= 0

isIE = null
$.isIE = ->
  isIE ?= navigator.userAgent?.indexOf('MSIE') >= 0 || navigator.userAgent?.indexOf('rv:11.0') >= 0

isAndroid = null
$.isAndroid = ->
  isAndroid ?= navigator.userAgent?.indexOf('Android') >= 0

isIOS = null
$.isIOS = ->
  isIOS ?= navigator.userAgent?.indexOf('iPhone') >= 0 || navigator.userAgent?.indexOf('iPad') >= 0

$.overlayScrollbarsEnabled = ->
  return false unless $.isMac()
  div = document.createElement('div')
  div.setAttribute('style', 'width: 100px; height: 100px; overflow: scroll; position: absolute')
  document.body.appendChild(div)
  result = div.offsetWidth is div.clientWidth
  document.body.removeChild(div)
  result

HIGHLIGHT_DEFAULTS =
  className: 'highlight'
  delay: 1000

$.highlight = (el, options = {}) ->
  options = $.extend {}, HIGHLIGHT_DEFAULTS, options
  el.classList.add(options.className)
  setTimeout (-> el.classList.remove(options.className)), options.delay
  return

$.copyToClipboard = (string) ->
  textarea = document.createElement('textarea')
  textarea.style.position = 'fixed'
  textarea.style.opacity = 0
  textarea.value = string
  document.body.appendChild(textarea)
  try
    textarea.select()
    result = !!document.execCommand('copy')
  catch
    result = false
  finally
    document.body.removeChild(textarea)
  result
