const MIME_TYPES = {
  json: "application/json",
  html: "text/html",
};

function ajax(options) {
  applyDefaults(options);
  serializeData(options);

  const xhr = new XMLHttpRequest();
  xhr.open(options.type, options.url, options.async);

  applyCallbacks(xhr, options);
  applyHeaders(xhr, options);

  xhr.send(options.data);

  if (options.async) {
    return { abort: abort.bind(undefined, xhr) };
  } else {
    return parseResponse(xhr, options);
  }

  function applyDefaults(options) {
    for (var key in ajax.defaults) {
      if (options[key] == null) {
        options[key] = ajax.defaults[key];
      }
    }
  }

  function serializeData(options) {
    if (!options.data) {
      return;
    }

    if (options.type === "GET") {
      options.url += "?" + serializeParams(options.data);
      options.data = null;
    } else {
      options.data = serializeParams(options.data);
    }
  }

  function serializeParams(params) {
    return Object.entries(params)
      .map(
        ([key, value]) =>
          `${encodeURIComponent(key)}=${encodeURIComponent(value)}`,
      )
      .join("&");
  }

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

  function onComplete(xhr, options) {
    if (200 <= xhr.status && xhr.status < 300) {
      let response;
      if ((response = parseResponse(xhr, options)) != null) {
        onSuccess(response, xhr, options);
      } else {
        onError("invalid", xhr, options);
      }
    } else {
      onError("error", xhr, options);
    }
  }

  function onSuccess(response, xhr, options) {
    if (options.success != null) {
      options.success.call(options.context, response, xhr, options);
    }
  }

  function onError(type, xhr, options) {
    if (options.error != null) {
      options.error.call(options.context, type, xhr, options);
    }
  }

  function onTimeout(xhr, options) {
    xhr.abort();
    onError("timeout", xhr, options);
  }

  function abort(xhr) {
    clearTimeout(xhr.timer);
    xhr.onreadystatechange = null;
    xhr.abort();
  }

  function parseResponse(xhr, options) {
    if (options.dataType === "json") {
      return parseJSON(xhr.responseText);
    } else {
      return xhr.responseText;
    }
  }

  function parseJSON(json) {
    try {
      return JSON.parse(json);
    } catch (error) {}
  }
}

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
