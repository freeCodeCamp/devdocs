// @ts-check

/**
 * @typedef {"error" | "invalid" | "timeout"} AjaxErrorType
 *
 * @typedef {object} AjaxOptions
 * @property {string} [url]
 * @property {string} [type] HTTP method. Defaults to `"GET"`.
 * @property {boolean} [async] Defaults to `true`. When false, `ajax` returns the parsed response.
 * @property {string} [dataType] `"json"` (the default), `"html"`, or a MIME type.
 * @property {number} [timeout] Seconds before the request is aborted. Defaults to 30.
 * @property {string} [contentType]
 * @property {unknown} [context] `this` for the `success` and `error` callbacks.
 * @property {Record<string, unknown> | string | null} [data] Serialized into the query string for GET, into the body otherwise.
 * @property {Record<string, string>} [headers]
 * @property {(event: ProgressEvent) => void} [progress]
 * @property {(response: unknown, xhr: XMLHttpRequest, options: AjaxOptions) => void} [success]
 * @property {(type: AjaxErrorType, xhr: XMLHttpRequest, options: AjaxOptions) => void} [error]
 */

/** @type {Record<string, string>} */
const MIME_TYPES = {
  json: "application/json",
  html: "text/html",
};

/**
 * A small XMLHttpRequest wrapper.
 *
 * @param {AjaxOptions} options Merged over `ajax.defaults`. Mutated in place.
 * @returns {{ abort: () => void }} A handle to abort the request. A
 *   synchronous request returns the parsed response instead, but nothing asks
 *   for one.
 */
function ajax(options) {
  applyDefaults(options);
  serializeData(options);

  const xhr = new XMLHttpRequest();
  xhr.open(options.type, options.url, options.async);

  applyCallbacks(xhr, options);
  applyHeaders(xhr, options);

  // serializeData has already reduced `data` to a string or null.
  xhr.send(/** @type {string | null} */ (options.data));

  if (options.async) {
    return { abort: abort.bind(undefined, xhr) };
  } else {
    return /** @type {{ abort: () => void }} */ (parseResponse(xhr, options));
  }

  /** @param {AjaxOptions} options */
  function applyDefaults(options) {
    for (var key in ajax.defaults) {
      if (options[key] == null) {
        options[key] = ajax.defaults[key];
      }
    }
  }

  /** @param {AjaxOptions} options */
  function serializeData(options) {
    if (!options.data) {
      return;
    }

    if (options.type === "GET") {
      options.url +=
        "?" + serializeParams(/** @type {Record<string, unknown>} */ (options.data));
      options.data = null;
    } else {
      options.data = serializeParams(
        /** @type {Record<string, unknown>} */ (options.data),
      );
    }
  }

  /**
   * @param {Record<string, unknown>} params
   * @returns {string}
   */
  function serializeParams(params) {
    return Object.entries(params)
      .map(
        ([key, value]) =>
          `${encodeURIComponent(key)}=${encodeURIComponent(String(value))}`,
      )
      .join("&");
  }

  /**
   * @param {XMLHttpRequest} xhr
   * @param {AjaxOptions} options
   */
  function applyCallbacks(xhr, options) {
    if (!options.async) {
      return;
    }

    xhr.timer = setTimeout(
      onTimeout.bind(undefined, xhr, options),
      options.timeout * 1000,
    );
    if (options.progress) {
      xhr.onprogress = options.progress;
    }
    xhr.onreadystatechange = function () {
      if (xhr.readyState === 4) {
        clearTimeout(xhr.timer);
        onComplete(xhr, options);
      }
    };
  }

  /**
   * @param {XMLHttpRequest} xhr
   * @param {AjaxOptions} options
   */
  function applyHeaders(xhr, options) {
    if (!options.headers) {
      options.headers = {};
    }

    if (options.contentType) {
      options.headers["Content-Type"] = options.contentType;
    }

    if (
      !options.headers["Content-Type"] &&
      options.data &&
      options.type !== "GET"
    ) {
      options.headers["Content-Type"] = "application/x-www-form-urlencoded";
    }

    if (options.dataType) {
      options.headers["Accept"] =
        MIME_TYPES[options.dataType] || options.dataType;
    }

    for (var key in options.headers) {
      var value = options.headers[key];
      xhr.setRequestHeader(key, value);
    }
  }

  /**
   * @param {XMLHttpRequest} xhr
   * @param {AjaxOptions} options
   */
  function onComplete(xhr, options) {
    if (200 <= xhr.status && xhr.status < 300) {
      const response = parseResponse(xhr, options);
      if (response != null) {
        onSuccess(response, xhr, options);
      } else {
        onError("invalid", xhr, options);
      }
    } else {
      onError("error", xhr, options);
    }
  }

  /**
   * @param {unknown} response
   * @param {XMLHttpRequest} xhr
   * @param {AjaxOptions} options
   */
  function onSuccess(response, xhr, options) {
    if (options.success != null) {
      options.success.call(options.context, response, xhr, options);
    }
  }

  /**
   * @param {AjaxErrorType} type
   * @param {XMLHttpRequest} xhr
   * @param {AjaxOptions} options
   */
  function onError(type, xhr, options) {
    if (options.error != null) {
      options.error.call(options.context, type, xhr, options);
    }
  }

  /**
   * @param {XMLHttpRequest} xhr
   * @param {AjaxOptions} options
   */
  function onTimeout(xhr, options) {
    xhr.abort();
    onError("timeout", xhr, options);
  }

  /** @param {XMLHttpRequest} xhr */
  function abort(xhr) {
    clearTimeout(xhr.timer);
    xhr.onreadystatechange = null;
    xhr.abort();
  }

  /**
   * @param {XMLHttpRequest} xhr
   * @param {AjaxOptions} options
   * @returns {unknown} `undefined` when a JSON response fails to parse.
   */
  function parseResponse(xhr, options) {
    if (options.dataType === "json") {
      return parseJSON(xhr.responseText);
    } else {
      return xhr.responseText;
    }
  }

  /**
   * @param {string} json
   * @returns {unknown} `undefined` when parsing fails.
   */
  function parseJSON(json) {
    try {
      return JSON.parse(json);
    } catch (error) {}
  }
}

/** @type {AjaxOptions} */
ajax.defaults = {
  async: true,
  dataType: "json",
  timeout: 30,
  type: "GET",
  // contentType
  // context
  // data
  // error
  // headers
  // progress
  // success
  // url
};
