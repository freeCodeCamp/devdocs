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
    el = el.parentElement

$.closestLink = (el, parent = document.body) ->
  while el
    return el if el.tagName is 'A'
    return if el is parent
    el = el.parentElement

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

  el.parentElement.insertBefore(value, el)
  return

$.after = (el, value) ->
  if typeof value is 'string' or $.isCollection(value)
    value = buildFragment(value)

  if el.nextSibling
    el.parentElement.insertBefore(value, el.nextSibling)
  else
    el.parentElement.appendChild(value)
  return

$.remove = (value) ->
  if $.isCollection(value)
    el.parentElement.removeChild(el) for el in $.makeArray(value)
  else
    value.parentElement.removeChild(value)
  return

$.empty = (el) ->
  el.removeChild(el.firstChild) while el.firstChild
  return

# Calls the function while the element is off the DOM to avoid triggering
# unecessary reflows and repaints.
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
  while el = el.parentElement
    break if el.scrollTop > 0
    break if getComputedStyle(el).overflowY in ['auto', 'scroll']
  el

$.scrollTo = (el, parent, position = 'center', options = {}) ->
  return unless el

  parent ?= $.scrollParent(el)
  return unless parent

  parentHeight = parent.clientHeight
  return unless parent.scrollHeight > parentHeight

  top = $.offset(el, parent).top

  switch position
    when 'top'
      parent.scrollTop = top - (if options.margin? then options.margin else 20)
    when 'center'
      parent.scrollTop = top - Math.round(parentHeight / 2 - el.offsetHeight / 2)
    when 'continuous'
      scrollTop = parent.scrollTop
      height = el.offsetHeight

      # If the target element is above the visible portion of its scrollable
      # ancestor, move it near the top with a gap = options.topGap * target's height.
      if top <= scrollTop + height * (options.topGap or 1)
        parent.scrollTop = top - height * (options.topGap or 1)
      # If the target element is below the visible portion of its scrollable
      # ancestor, move it near the bottom with a gap = options.bottomGap * target's height.
      else if top >= scrollTop + parentHeight - height * ((options.bottomGap or 1) + 1)
        parent.scrollTop = top - parentHeight + height * ((options.bottomGap or 1) + 1)
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

#
# Miscellaneous
#

$.noop = ->

$.popup = (value) ->
  open value.href or value, '_blank'
  return

$.isTouchScreen = ->
  typeof ontouchstart isnt 'undefined'

$.isWindows = ->
  navigator.platform?.indexOf('Win') >= 0

$.isMac = ->
  navigator.userAgent?.indexOf('Mac') >= 0

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
