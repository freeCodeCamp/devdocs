//
// Traversing
//

let smoothDistance, smoothDuration, smoothEnd, smoothStart;
this.$ = function (selector, el) {
  if (el == null) {
    el = document;
  }
  try {
    return el.querySelector(selector);
  } catch (error) {}
};

this.$$ = function (selector, el) {
  if (el == null) {
    el = document;
  }
  try {
    return el.querySelectorAll(selector);
  } catch (error) {}
};

$.id = (id) => document.getElementById(id);

$.hasChild = function (parent, el) {
  if (!parent) {
    return;
  }
  while (el) {
    if (el === parent) {
      return true;
    }
    if (el === document.body) {
      return;
    }
    el = el.parentNode;
  }
};

$.closestLink = function (el, parent) {
  if (parent == null) {
    parent = document.body;
  }
  while (el) {
    if (el.tagName === "A") {
      return el;
    }
    if (el === parent) {
      return;
    }
    el = el.parentNode;
  }
};

//
// Events
//

$.on = function (el, event, callback, useCapture) {
  if (useCapture == null) {
    useCapture = false;
  }
  if (event.includes(" ")) {
    for (var name of event.split(" ")) {
      $.on(el, name, callback);
    }
  } else {
    el.addEventListener(event, callback, useCapture);
  }
};

$.off = function (el, event, callback, useCapture) {
  if (useCapture == null) {
    useCapture = false;
  }
  if (event.includes(" ")) {
    for (var name of event.split(" ")) {
      $.off(el, name, callback);
    }
  } else {
    el.removeEventListener(event, callback, useCapture);
  }
};

$.trigger = function (el, type, canBubble, cancelable) {
  const event = new Event(type, {
    bubbles: canBubble ?? true,
    cancelable: cancelable ?? true,
  });
  el.dispatchEvent(event);
};

$.click = function (el) {
  const event = new MouseEvent("click", {
    bubbles: true,
    cancelable: true,
  });
  el.dispatchEvent(event);
};

$.stopEvent = function (event) {
  event.preventDefault();
  event.stopPropagation();
  event.stopImmediatePropagation();
};

$.eventTarget = (event) => event.target.correspondingUseElement || event.target;

//
// Manipulation
//

const buildFragment = function (value) {
  const fragment = document.createDocumentFragment();

  if ($.isCollection(value)) {
    for (var child of $.makeArray(value)) {
      fragment.appendChild(child);
    }
  } else {
    fragment.innerHTML = value;
  }

  return fragment;
};

$.append = function (el, value) {
  if (typeof value === "string") {
    el.insertAdjacentHTML("beforeend", value);
  } else {
    if ($.isCollection(value)) {
      value = buildFragment(value);
    }
    el.appendChild(value);
  }
};

$.prepend = function (el, value) {
  if (!el.firstChild) {
    $.append(value);
  } else if (typeof value === "string") {
    el.insertAdjacentHTML("afterbegin", value);
  } else {
    if ($.isCollection(value)) {
      value = buildFragment(value);
    }
    el.insertBefore(value, el.firstChild);
  }
};

$.before = function (el, value) {
  if (typeof value === "string" || $.isCollection(value)) {
    value = buildFragment(value);
  }

  el.parentNode.insertBefore(value, el);
};

$.after = function (el, value) {
  if (typeof value === "string" || $.isCollection(value)) {
    value = buildFragment(value);
  }

  if (el.nextSibling) {
    el.parentNode.insertBefore(value, el.nextSibling);
  } else {
    el.parentNode.appendChild(value);
  }
};

$.remove = function (value) {
  if ($.isCollection(value)) {
    for (var el of $.makeArray(value)) {
      if (el.parentNode != null) {
        el.parentNode.removeChild(el);
      }
    }
  } else {
    if (value.parentNode != null) {
      value.parentNode.removeChild(value);
    }
  }
};

$.empty = function (el) {
  while (el.firstChild) {
    el.removeChild(el.firstChild);
  }
};

// Calls the function while the element is off the DOM to avoid triggering
// unnecessary reflows and repaints.
$.batchUpdate = function (el, fn) {
  const parent = el.parentNode;
  const sibling = el.nextSibling;
  parent.removeChild(el);

  fn(el);

  if (sibling) {
    parent.insertBefore(el, sibling);
  } else {
    parent.appendChild(el);
  }
};

//
// Offset
//

$.rect = (el) => el.getBoundingClientRect();

$.offset = function (el, container) {
  if (container == null) {
    container = document.body;
  }
  let top = 0;
  let left = 0;

  while (el && el !== container) {
    top += el.offsetTop;
    left += el.offsetLeft;
    el = el.offsetParent;
  }

  return {
    top,
    left,
  };
};

$.scrollParent = function (el) {
  while ((el = el.parentNode) && el.nodeType === 1) {
    if (el.scrollTop > 0) {
      break;
    }
    if (["auto", "scroll"].includes(getComputedStyle(el)?.overflowY ?? "")) {
      break;
    }
  }
  return el;
};

$.scrollTo = function (el, parent, position, options) {
  if (position == null) {
    position = "center";
  }
  if (options == null) {
    options = {};
  }
  if (!el) {
    return;
  }

  if (parent == null) {
    parent = $.scrollParent(el);
  }
  if (!parent) {
    return;
  }

  const parentHeight = parent.clientHeight;
  const parentScrollHeight = parent.scrollHeight;
  if (!(parentScrollHeight > parentHeight)) {
    return;
  }

  const { top } = $.offset(el, parent);
  const { offsetTop } = parent.firstElementChild;

  switch (position) {
    case "top":
      parent.scrollTop = top - offsetTop - (options.margin || 0);
      break;
    case "center":
      parent.scrollTop =
        top - Math.round(parentHeight / 2 - el.offsetHeight / 2);
      break;
    case "continuous":
      var { scrollTop } = parent;
      var height = el.offsetHeight;

      var lastElementOffset =
        parent.lastElementChild.offsetTop +
        parent.lastElementChild.offsetHeight;
      var offsetBottom =
        lastElementOffset > 0 ? parentScrollHeight - lastElementOffset : 0;

      // If the target element is above the visible portion of its scrollable
      // ancestor, move it near the top with a gap = options.topGap * target's height.
      if (top - offsetTop <= scrollTop + height * (options.topGap || 1)) {
        parent.scrollTop = top - offsetTop - height * (options.topGap || 1);
        // If the target element is below the visible portion of its scrollable
        // ancestor, move it near the bottom with a gap = options.bottomGap * target's height.
      } else if (
        top + offsetBottom >=
        scrollTop + parentHeight - height * ((options.bottomGap || 1) + 1)
      ) {
        parent.scrollTop =
          top +
          offsetBottom -
          parentHeight +
          height * ((options.bottomGap || 1) + 1);
      }
      break;
  }
};

$.scrollToWithImageLock = function (el, parent, ...args) {
  if (parent == null) {
    parent = $.scrollParent(el);
  }
  if (!parent) {
    return;
  }

  $.scrollTo(el, parent, ...args);

  // Lock the scroll position on the target element for up to 3 seconds while
  // nearby images are loaded and rendered.
  for (var image of parent.getElementsByTagName("img")) {
    if (!image.complete) {
      (function () {
        let timeout;
        const onLoad = function (event) {
          clearTimeout(timeout);
          unbind(event.target);
          return $.scrollTo(el, parent, ...args);
        };

        var unbind = (target) => $.off(target, "load", onLoad);

        $.on(image, "load", onLoad);
        return (timeout = setTimeout(unbind.bind(null, image), 3000));
      })();
    }
  }
};

// Calls the function while locking the element's position relative to the window.
$.lockScroll = function (el, fn) {
  let parent;
  if ((parent = $.scrollParent(el))) {
    let { top } = $.rect(el);
    if (![document.body, document.documentElement].includes(parent)) {
      top -= $.rect(parent).top;
    }
    fn();
    parent.scrollTop = $.offset(el, parent).top - top;
  } else {
    fn();
  }
};

let smoothScroll =
  (smoothStart =
  smoothEnd =
  smoothDistance =
  smoothDuration =
    null);

$.smoothScroll = function (el, end) {
  smoothEnd = end;

  if (smoothScroll) {
    const newDistance = smoothEnd - smoothStart;
    smoothDuration += Math.min(300, Math.abs(smoothDistance - newDistance));
    smoothDistance = newDistance;
    return;
  }

  smoothStart = el.scrollTop;
  smoothDistance = smoothEnd - smoothStart;
  smoothDuration = Math.min(300, Math.abs(smoothDistance));
  const startTime = Date.now();

  smoothScroll = function () {
    const p = Math.min(1, (Date.now() - startTime) / smoothDuration);
    const y = Math.max(
      0,
      Math.floor(
        smoothStart +
          smoothDistance * (p < 0.5 ? 2 * p * p : p * (4 - p * 2) - 1),
      ),
    );
    el.scrollTop = y;
    if (p === 1) {
      return (smoothScroll = null);
    } else {
      return requestAnimationFrame(smoothScroll);
    }
  };
  return requestAnimationFrame(smoothScroll);
};

//
// Utilities
//

$.makeArray = function (object) {
  if (Array.isArray(object)) {
    return object;
  } else {
    return Array.prototype.slice.apply(object);
  }
};

$.arrayDelete = function (array, object) {
  const index = array.indexOf(object);
  if (index >= 0) {
    array.splice(index, 1);
    return true;
  } else {
    return false;
  }
};

// Returns true if the object is an array or a collection of DOM elements.
$.isCollection = (object) =>
  Array.isArray(object) || typeof object?.item === "function";

const ESCAPE_HTML_MAP = {
  "&": "&amp;",
  "<": "&lt;",
  ">": "&gt;",
  '"': "&quot;",
  "'": "&#x27;",
  "/": "&#x2F;",
};

const ESCAPE_HTML_REGEXP = /[&<>"'\/]/g;

$.escape = (string) =>
  string.replace(ESCAPE_HTML_REGEXP, (match) => ESCAPE_HTML_MAP[match]);

const ESCAPE_REGEXP = /([.*+?^=!:${}()|\[\]\/\\])/g;

$.escapeRegexp = (string) => string.replace(ESCAPE_REGEXP, "\\$1");

$.urlDecode = (string) => decodeURIComponent(string.replace(/\+/g, "%20"));

$.classify = function (string) {
  string = string.split("_");
  for (let i = 0; i < string.length; i++) {
    var substr = string[i];
    string[i] = substr[0].toUpperCase() + substr.slice(1);
  }
  return string.join("");
};

//
// Miscellaneous
//

$.noop = function () {};

$.popup = function (value) {
  try {
    window.open(value.href || value, "_blank", "noopener");
  } catch (error) {
    const win = window.open();
    if (win.opener) {
      win.opener = null;
    }
    win.location = value.href || value;
  }
};

let isMac = null;
$.isMac = () =>
  isMac != null ? isMac : (isMac = navigator.userAgent.includes("Mac"));

let isIE = null;
$.isIE = () =>
  isIE != null
    ? isIE
    : (isIE =
        navigator.userAgent.includes("MSIE") ||
        navigator.userAgent.includes("rv:11.0"));

let isChromeForAndroid = null;
$.isChromeForAndroid = () =>
  isChromeForAndroid != null
    ? isChromeForAndroid
    : (isChromeForAndroid =
        navigator.userAgent.includes("Android") &&
        /Chrome\/([.0-9])+ Mobile/.test(navigator.userAgent));

let isAndroid = null;
$.isAndroid = () =>
  isAndroid != null
    ? isAndroid
    : (isAndroid = navigator.userAgent.includes("Android"));

let isIOS = null;
$.isIOS = () =>
  isIOS != null
    ? isIOS
    : (isIOS =
        navigator.userAgent.includes("iPhone") ||
        navigator.userAgent.includes("iPad"));

$.overlayScrollbarsEnabled = function () {
  if (!$.isMac()) {
    return false;
  }
  const div = document.createElement("div");
  div.setAttribute(
    "style",
    "width: 100px; height: 100px; overflow: scroll; position: absolute",
  );
  document.body.appendChild(div);
  const result = div.offsetWidth === div.clientWidth;
  document.body.removeChild(div);
  return result;
};

const HIGHLIGHT_DEFAULTS = {
  className: "highlight",
  delay: 1000,
};

$.highlight = function (el, options) {
  options = { ...HIGHLIGHT_DEFAULTS, ...(options || {}) };
  el.classList.add(options.className);
  setTimeout(() => el.classList.remove(options.className), options.delay);
};
