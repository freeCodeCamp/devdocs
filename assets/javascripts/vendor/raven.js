/*! Raven.js 3.25.2 (30b6d4e) | github.com/getsentry/raven-js */

/*
 * Includes TraceKit
 * https://github.com/getsentry/TraceKit
 *
 * Copyright 2018 Matt Robenolt and other contributors
 * Released under the BSD license
 * https://github.com/getsentry/raven-js/blob/master/LICENSE
 *
 */

(function (f) {
  if (typeof exports === "object" && typeof module !== "undefined") {
    module.exports = f();
  } else if (typeof define === "function" && define.amd) {
    define([], f);
  } else {
    var g;
    if (typeof window !== "undefined") {
      g = window;
    } else if (typeof global !== "undefined") {
      g = global;
    } else if (typeof self !== "undefined") {
      g = self;
    } else {
      g = this;
    }
    g.Raven = f();
  }
})(function () {
  var define, module, exports;
  return (function e(t, n, r) {
    function s(o, u) {
      if (!n[o]) {
        if (!t[o]) {
          var a = typeof require == "function" && require;
          if (!u && a) return a(o, !0);
          if (i) return i(o, !0);
          var f = new Error("Cannot find module '" + o + "'");
          throw ((f.code = "MODULE_NOT_FOUND"), f);
        }
        var l = (n[o] = { exports: {} });
        t[o][0].call(
          l.exports,
          function (e) {
            var n = t[o][1][e];
            return s(n ? n : e);
          },
          l,
          l.exports,
          e,
          t,
          n,
          r,
        );
      }
      return n[o].exports;
    }
    var i = typeof require == "function" && require;
    for (var o = 0; o < r.length; o++) s(r[o]);
    return s;
  })(
    {
      1: [
        function (_dereq_, module, exports) {
          function RavenConfigError(message) {
            this.name = "RavenConfigError";
            this.message = message;
          }
          RavenConfigError.prototype = new Error();
          RavenConfigError.prototype.constructor = RavenConfigError;

          module.exports = RavenConfigError;
        },
        {},
      ],
      2: [
        function (_dereq_, module, exports) {
          var utils = _dereq_(5);

          var wrapMethod = function (console, level, callback) {
            var originalConsoleLevel = console[level];
            var originalConsole = console;

            if (!(level in console)) {
              return;
            }

            var sentryLevel = level === "warn" ? "warning" : level;

            console[level] = function () {
              var args = [].slice.call(arguments);

              var msg = utils.safeJoin(args, " ");
              var data = {
                level: sentryLevel,
                logger: "console",
                extra: { arguments: args },
              };

              if (level === "assert") {
                if (args[0] === false) {
                  // Default browsers message
                  msg =
                    "Assertion failed: " +
                    (utils.safeJoin(args.slice(1), " ") || "console.assert");
                  data.extra.arguments = args.slice(1);
                  callback && callback(msg, data);
                }
              } else {
                callback && callback(msg, data);
              }

              // this fails for some browsers. :(
              if (originalConsoleLevel) {
                // IE9 doesn't allow calling apply on console functions directly
                // See: https://stackoverflow.com/questions/5472938/does-ie9-support-console-log-and-is-it-a-real-function#answer-5473193
                Function.prototype.apply.call(
                  originalConsoleLevel,
                  originalConsole,
                  args,
                );
              }
            };
          };

          module.exports = {
            wrapMethod: wrapMethod,
          };
        },
        { 5: 5 },
      ],
      3: [
        function (_dereq_, module, exports) {
          (function (global) {
            /*global XDomainRequest:false */

            var TraceKit = _dereq_(6);
            var stringify = _dereq_(7);
            var md5 = _dereq_(8);
            var RavenConfigError = _dereq_(1);

            var utils = _dereq_(5);
            var isErrorEvent = utils.isErrorEvent;
            var isDOMError = utils.isDOMError;
            var isDOMException = utils.isDOMException;
            var isError = utils.isError;
            var isObject = utils.isObject;
            var isPlainObject = utils.isPlainObject;
            var isUndefined = utils.isUndefined;
            var isFunction = utils.isFunction;
            var isString = utils.isString;
            var isArray = utils.isArray;
            var isEmptyObject = utils.isEmptyObject;
            var each = utils.each;
            var objectMerge = utils.objectMerge;
            var truncate = utils.truncate;
            var objectFrozen = utils.objectFrozen;
            var hasKey = utils.hasKey;
            var joinRegExp = utils.joinRegExp;
            var urlencode = utils.urlencode;
            var uuid4 = utils.uuid4;
            var htmlTreeAsString = utils.htmlTreeAsString;
            var isSameException = utils.isSameException;
            var isSameStacktrace = utils.isSameStacktrace;
            var parseUrl = utils.parseUrl;
            var fill = utils.fill;
            var supportsFetch = utils.supportsFetch;
            var supportsReferrerPolicy = utils.supportsReferrerPolicy;
            var serializeKeysForMessage = utils.serializeKeysForMessage;
            var serializeException = utils.serializeException;
            var sanitize = utils.sanitize;

            var wrapConsoleMethod = _dereq_(2).wrapMethod;

            var dsnKeys = "source protocol user pass host port path".split(" "),
              dsnPattern =
                /^(?:(\w+):)?\/\/(?:(\w+)(:\w+)?@)?([\w\.-]+)(?::(\d+))?(\/.*)/;

            function now() {
              return +new Date();
            }

            // This is to be defensive in environments where window does not exist (see https://github.com/getsentry/raven-js/pull/785)
            var _window =
              typeof window !== "undefined"
                ? window
                : typeof global !== "undefined"
                  ? global
                  : typeof self !== "undefined"
                    ? self
                    : {};
            var _document = _window.document;
            var _navigator = _window.navigator;

            function keepOriginalCallback(original, callback) {
              return isFunction(callback)
                ? function (data) {
                    return callback(data, original);
                  }
                : callback;
            }

            // First, check for JSON support
            // If there is no JSON, we no-op the core features of Raven
            // since JSON is required to encode the payload
            function Raven() {
              this._hasJSON = !!(typeof JSON === "object" && JSON.stringify);
              // Raven can run in contexts where there's no document (react-native)
              this._hasDocument = !isUndefined(_document);
              this._hasNavigator = !isUndefined(_navigator);
              this._lastCapturedException = null;
              this._lastData = null;
              this._lastEventId = null;
              this._globalServer = null;
              this._globalKey = null;
              this._globalProject = null;
              this._globalContext = {};
              this._globalOptions = {
                // SENTRY_RELEASE can be injected by https://github.com/getsentry/sentry-webpack-plugin
                release: _window.SENTRY_RELEASE && _window.SENTRY_RELEASE.id,
                logger: "javascript",
                ignoreErrors: [],
                ignoreUrls: [],
                whitelistUrls: [],
                includePaths: [],
                headers: null,
                collectWindowErrors: true,
                captureUnhandledRejections: true,
                maxMessageLength: 0,
                // By default, truncates URL values to 250 chars
                maxUrlLength: 250,
                stackTraceLimit: 50,
                autoBreadcrumbs: true,
                instrument: true,
                sampleRate: 1,
                sanitizeKeys: [],
              };
              this._fetchDefaults = {
                method: "POST",
                keepalive: true,
                // Despite all stars in the sky saying that Edge supports old draft syntax, aka 'never', 'always', 'origin' and 'default
                // https://caniuse.com/#feat=referrer-policy
                // It doesn't. And it throw exception instead of ignoring this parameter...
                // REF: https://github.com/getsentry/raven-js/issues/1233
                referrerPolicy: supportsReferrerPolicy() ? "origin" : "",
              };
              this._ignoreOnError = 0;
              this._isRavenInstalled = false;
              this._originalErrorStackTraceLimit = Error.stackTraceLimit;
              // capture references to window.console *and* all its methods first
              // before the console plugin has a chance to monkey patch
              this._originalConsole = _window.console || {};
              this._originalConsoleMethods = {};
              this._plugins = [];
              this._startTime = now();
              this._wrappedBuiltIns = [];
              this._breadcrumbs = [];
              this._lastCapturedEvent = null;
              this._keypressTimeout;
              this._location = _window.location;
              this._lastHref = this._location && this._location.href;
              this._resetBackoff();

              // eslint-disable-next-line guard-for-in
              for (var method in this._originalConsole) {
                this._originalConsoleMethods[method] =
                  this._originalConsole[method];
              }
            }

            /*
             * The core Raven singleton
             *
             * @this {Raven}
             */

            Raven.prototype = {
              // Hardcode version string so that raven source can be loaded directly via
              // webpack (using a build step causes webpack #1617). Grunt verifies that
              // this value matches package.json during build.
              //   See: https://github.com/getsentry/raven-js/issues/465
              VERSION: "3.25.2",

              debug: false,

              TraceKit: TraceKit, // alias to TraceKit

              /*
               * Configure Raven with a DSN and extra options
               *
               * @param {string} dsn The public Sentry DSN
               * @param {object} options Set of global options [optional]
               * @return {Raven}
               */
              config: function (dsn, options) {
                var self = this;

                if (self._globalServer) {
                  this._logDebug(
                    "error",
                    "Error: Raven has already been configured",
                  );
                  return self;
                }
                if (!dsn) return self;

                var globalOptions = self._globalOptions;

                // merge in options
                if (options) {
                  each(options, function (key, value) {
                    // tags and extra are special and need to be put into context
                    if (key === "tags" || key === "extra" || key === "user") {
                      self._globalContext[key] = value;
                    } else {
                      globalOptions[key] = value;
                    }
                  });
                }

                self.setDSN(dsn);

                // "Script error." is hard coded into browsers for errors that it can't read.
                // this is the result of a script being pulled in from an external domain and CORS.
                globalOptions.ignoreErrors.push(/^Script error\.?$/);
                globalOptions.ignoreErrors.push(
                  /^Javascript error: Script error\.? on line 0$/,
                );

                // join regexp rules into one big rule
                globalOptions.ignoreErrors = joinRegExp(
                  globalOptions.ignoreErrors,
                );
                globalOptions.ignoreUrls = globalOptions.ignoreUrls.length
                  ? joinRegExp(globalOptions.ignoreUrls)
                  : false;
                globalOptions.whitelistUrls = globalOptions.whitelistUrls.length
                  ? joinRegExp(globalOptions.whitelistUrls)
                  : false;
                globalOptions.includePaths = joinRegExp(
                  globalOptions.includePaths,
                );
                globalOptions.maxBreadcrumbs = Math.max(
                  0,
                  Math.min(globalOptions.maxBreadcrumbs || 100, 100),
                ); // default and hard limit is 100

                var autoBreadcrumbDefaults = {
                  xhr: true,
                  console: true,
                  dom: true,
                  location: true,
                  sentry: true,
                };

                var autoBreadcrumbs = globalOptions.autoBreadcrumbs;
                if ({}.toString.call(autoBreadcrumbs) === "[object Object]") {
                  autoBreadcrumbs = objectMerge(
                    autoBreadcrumbDefaults,
                    autoBreadcrumbs,
                  );
                } else if (autoBreadcrumbs !== false) {
                  autoBreadcrumbs = autoBreadcrumbDefaults;
                }
                globalOptions.autoBreadcrumbs = autoBreadcrumbs;

                var instrumentDefaults = {
                  tryCatch: true,
                };

                var instrument = globalOptions.instrument;
                if ({}.toString.call(instrument) === "[object Object]") {
                  instrument = objectMerge(instrumentDefaults, instrument);
                } else if (instrument !== false) {
                  instrument = instrumentDefaults;
                }
                globalOptions.instrument = instrument;

                TraceKit.collectWindowErrors =
                  !!globalOptions.collectWindowErrors;

                // return for chaining
                return self;
              },

              /*
               * Installs a global window.onerror error handler
               * to capture and report uncaught exceptions.
               * At this point, install() is required to be called due
               * to the way TraceKit is set up.
               *
               * @return {Raven}
               */
              install: function () {
                var self = this;
                if (self.isSetup() && !self._isRavenInstalled) {
                  TraceKit.report.subscribe(function () {
                    self._handleOnErrorStackInfo.apply(self, arguments);
                  });

                  if (self._globalOptions.captureUnhandledRejections) {
                    self._attachPromiseRejectionHandler();
                  }

                  self._patchFunctionToString();

                  if (
                    self._globalOptions.instrument &&
                    self._globalOptions.instrument.tryCatch
                  ) {
                    self._instrumentTryCatch();
                  }

                  if (self._globalOptions.autoBreadcrumbs)
                    self._instrumentBreadcrumbs();

                  // Install all of the plugins
                  self._drainPlugins();

                  self._isRavenInstalled = true;
                }

                Error.stackTraceLimit = self._globalOptions.stackTraceLimit;
                return this;
              },

              /*
               * Set the DSN (can be called multiple time unlike config)
               *
               * @param {string} dsn The public Sentry DSN
               */
              setDSN: function (dsn) {
                var self = this,
                  uri = self._parseDSN(dsn),
                  lastSlash = uri.path.lastIndexOf("/"),
                  path = uri.path.substr(1, lastSlash);

                self._dsn = dsn;
                self._globalKey = uri.user;
                self._globalSecret = uri.pass && uri.pass.substr(1);
                self._globalProject = uri.path.substr(lastSlash + 1);

                self._globalServer = self._getGlobalServer(uri);

                self._globalEndpoint =
                  self._globalServer +
                  "/" +
                  path +
                  "api/" +
                  self._globalProject +
                  "/store/";

                // Reset backoff state since we may be pointing at a
                // new project/server
                this._resetBackoff();
              },

              /*
               * Wrap code within a context so Raven can capture errors
               * reliably across domains that is executed immediately.
               *
               * @param {object} options A specific set of options for this context [optional]
               * @param {function} func The callback to be immediately executed within the context
               * @param {array} args An array of arguments to be called with the callback [optional]
               */
              context: function (options, func, args) {
                if (isFunction(options)) {
                  args = func || [];
                  func = options;
                  options = undefined;
                }

                return this.wrap(options, func).apply(this, args);
              },

              /*
               * Wrap code within a context and returns back a new function to be executed
               *
               * @param {object} options A specific set of options for this context [optional]
               * @param {function} func The function to be wrapped in a new context
               * @param {function} func A function to call before the try/catch wrapper [optional, private]
               * @return {function} The newly wrapped functions with a context
               */
              wrap: function (options, func, _before) {
                var self = this;
                // 1 argument has been passed, and it's not a function
                // so just return it
                if (isUndefined(func) && !isFunction(options)) {
                  return options;
                }

                // options is optional
                if (isFunction(options)) {
                  func = options;
                  options = undefined;
                }

                // At this point, we've passed along 2 arguments, and the second one
                // is not a function either, so we'll just return the second argument.
                if (!isFunction(func)) {
                  return func;
                }

                // We don't wanna wrap it twice!
                try {
                  if (func.__raven__) {
                    return func;
                  }

                  // If this has already been wrapped in the past, return that
                  if (func.__raven_wrapper__) {
                    return func.__raven_wrapper__;
                  }
                } catch (e) {
                  // Just accessing custom props in some Selenium environments
                  // can cause a "Permission denied" exception (see raven-js#495).
                  // Bail on wrapping and return the function as-is (defers to window.onerror).
                  return func;
                }

                function wrapped() {
                  var args = [],
                    i = arguments.length,
                    deep = !options || (options && options.deep !== false);

                  if (_before && isFunction(_before)) {
                    _before.apply(this, arguments);
                  }

                  // Recursively wrap all of a function's arguments that are
                  // functions themselves.
                  while (i--)
                    args[i] = deep
                      ? self.wrap(options, arguments[i])
                      : arguments[i];

                  try {
                    // Attempt to invoke user-land function
                    // NOTE: If you are a Sentry user, and you are seeing this stack frame, it
                    //       means Raven caught an error invoking your application code. This is
                    //       expected behavior and NOT indicative of a bug with Raven.js.
                    return func.apply(this, args);
                  } catch (e) {
                    self._ignoreNextOnError();
                    self.captureException(e, options);
                    throw e;
                  }
                }

                // copy over properties of the old function
                for (var property in func) {
                  if (hasKey(func, property)) {
                    wrapped[property] = func[property];
                  }
                }
                wrapped.prototype = func.prototype;

                func.__raven_wrapper__ = wrapped;
                // Signal that this function has been wrapped/filled already
                // for both debugging and to prevent it to being wrapped/filled twice
                wrapped.__raven__ = true;
                wrapped.__orig__ = func;

                return wrapped;
              },

              /**
               * Uninstalls the global error handler.
               *
               * @return {Raven}
               */
              uninstall: function () {
                TraceKit.report.uninstall();

                this._detachPromiseRejectionHandler();
                this._unpatchFunctionToString();
                this._restoreBuiltIns();
                this._restoreConsole();

                Error.stackTraceLimit = this._originalErrorStackTraceLimit;
                this._isRavenInstalled = false;

                return this;
              },

              /**
               * Callback used for `unhandledrejection` event
               *
               * @param {PromiseRejectionEvent} event An object containing
               *   promise: the Promise that was rejected
               *   reason: the value with which the Promise was rejected
               * @return void
               */
              _promiseRejectionHandler: function (event) {
                this._logDebug(
                  "debug",
                  "Raven caught unhandled promise rejection:",
                  event,
                );
                this.captureException(event.reason, {
                  extra: {
                    unhandledPromiseRejection: true,
                  },
                });
              },

              /**
               * Installs the global promise rejection handler.
               *
               * @return {raven}
               */
              _attachPromiseRejectionHandler: function () {
                this._promiseRejectionHandler =
                  this._promiseRejectionHandler.bind(this);
                _window.addEventListener &&
                  _window.addEventListener(
                    "unhandledrejection",
                    this._promiseRejectionHandler,
                  );
                return this;
              },

              /**
               * Uninstalls the global promise rejection handler.
               *
               * @return {raven}
               */
              _detachPromiseRejectionHandler: function () {
                _window.removeEventListener &&
                  _window.removeEventListener(
                    "unhandledrejection",
                    this._promiseRejectionHandler,
                  );
                return this;
              },

              /**
               * Manually capture an exception and send it over to Sentry
               *
               * @param {error} ex An exception to be logged
               * @param {object} options A specific set of options for this error [optional]
               * @return {Raven}
               */
              captureException: function (ex, options) {
                options = objectMerge(
                  { trimHeadFrames: 0 },
                  options ? options : {},
                );

                if (isErrorEvent(ex) && ex.error) {
                  // If it is an ErrorEvent with `error` property, extract it to get actual Error
                  ex = ex.error;
                } else if (isDOMError(ex) || isDOMException(ex)) {
                  // If it is a DOMError or DOMException (which are legacy APIs, but still supported in some browsers)
                  // then we just extract the name and message, as they don't provide anything else
                  // https://developer.mozilla.org/en-US/docs/Web/API/DOMError
                  // https://developer.mozilla.org/en-US/docs/Web/API/DOMException
                  var name =
                    ex.name || (isDOMError(ex) ? "DOMError" : "DOMException");
                  var message = ex.message ? name + ": " + ex.message : name;

                  return this.captureMessage(
                    message,
                    objectMerge(options, {
                      // neither DOMError or DOMException provide stack trace and we most likely wont get it this way as well
                      // but it's barely any overhead so we may at least try
                      stacktrace: true,
                      trimHeadFrames: options.trimHeadFrames + 1,
                    }),
                  );
                } else if (isError(ex)) {
                  // we have a real Error object
                  ex = ex;
                } else if (isPlainObject(ex)) {
                  // If it is plain Object, serialize it manually and extract options
                  // This will allow us to group events based on top-level keys
                  // which is much better than creating new group when any key/value change
                  options = this._getCaptureExceptionOptionsFromPlainObject(
                    options,
                    ex,
                  );
                  ex = new Error(options.message);
                } else {
                  // If none of previous checks were valid, then it means that
                  // it's not a DOMError/DOMException
                  // it's not a plain Object
                  // it's not a valid ErrorEvent (one with an error property)
                  // it's not an Error
                  // So bail out and capture it as a simple message:
                  return this.captureMessage(
                    ex,
                    objectMerge(options, {
                      stacktrace: true, // if we fall back to captureMessage, default to attempting a new trace
                      trimHeadFrames: options.trimHeadFrames + 1,
                    }),
                  );
                }

                // Store the raw exception object for potential debugging and introspection
                this._lastCapturedException = ex;

                // TraceKit.report will re-raise any exception passed to it,
                // which means you have to wrap it in try/catch. Instead, we
                // can wrap it here and only re-raise if TraceKit.report
                // raises an exception different from the one we asked to
                // report on.
                try {
                  var stack = TraceKit.computeStackTrace(ex);
                  this._handleStackInfo(stack, options);
                } catch (ex1) {
                  if (ex !== ex1) {
                    throw ex1;
                  }
                }

                return this;
              },

              _getCaptureExceptionOptionsFromPlainObject: function (
                currentOptions,
                ex,
              ) {
                var exKeys = Object.keys(ex).sort();
                var options = objectMerge(currentOptions, {
                  message:
                    "Non-Error exception captured with keys: " +
                    serializeKeysForMessage(exKeys),
                  fingerprint: [md5(exKeys)],
                  extra: currentOptions.extra || {},
                });
                options.extra.__serialized__ = serializeException(ex);

                return options;
              },

              /*
               * Manually send a message to Sentry
               *
               * @param {string} msg A plain message to be captured in Sentry
               * @param {object} options A specific set of options for this message [optional]
               * @return {Raven}
               */
              captureMessage: function (msg, options) {
                // config() automagically converts ignoreErrors from a list to a RegExp so we need to test for an
                // early call; we'll error on the side of logging anything called before configuration since it's
                // probably something you should see:
                if (
                  !!this._globalOptions.ignoreErrors.test &&
                  this._globalOptions.ignoreErrors.test(msg)
                ) {
                  return;
                }

                options = options || {};
                msg = msg + ""; // Make sure it's actually a string

                var data = objectMerge(
                  {
                    message: msg,
                  },
                  options,
                );

                var ex;
                // Generate a "synthetic" stack trace from this point.
                // NOTE: If you are a Sentry user, and you are seeing this stack frame, it is NOT indicative
                //       of a bug with Raven.js. Sentry generates synthetic traces either by configuration,
                //       or if it catches a thrown object without a "stack" property.
                try {
                  throw new Error(msg);
                } catch (ex1) {
                  ex = ex1;
                }

                // null exception name so `Error` isn't prefixed to msg
                ex.name = null;
                var stack = TraceKit.computeStackTrace(ex);

                // stack[0] is `throw new Error(msg)` call itself, we are interested in the frame that was just before that, stack[1]
                var initialCall = isArray(stack.stack) && stack.stack[1];

                // if stack[1] is `Raven.captureException`, it means that someone passed a string to it and we redirected that call
                // to be handled by `captureMessage`, thus `initialCall` is the 3rd one, not 2nd
                // initialCall => captureException(string) => captureMessage(string)
                if (
                  initialCall &&
                  initialCall.func === "Raven.captureException"
                ) {
                  initialCall = stack.stack[2];
                }

                var fileurl = (initialCall && initialCall.url) || "";

                if (
                  !!this._globalOptions.ignoreUrls.test &&
                  this._globalOptions.ignoreUrls.test(fileurl)
                ) {
                  return;
                }

                if (
                  !!this._globalOptions.whitelistUrls.test &&
                  !this._globalOptions.whitelistUrls.test(fileurl)
                ) {
                  return;
                }

                if (
                  this._globalOptions.stacktrace ||
                  (options && options.stacktrace)
                ) {
                  // fingerprint on msg, not stack trace (legacy behavior, could be revisited)
                  data.fingerprint =
                    data.fingerprint == null ? msg : data.fingerprint;

                  options = objectMerge(
                    {
                      trimHeadFrames: 0,
                    },
                    options,
                  );
                  // Since we know this is a synthetic trace, the top frame (this function call)
                  // MUST be from Raven.js, so mark it for trimming
                  // We add to the trim counter so that callers can choose to trim extra frames, such
                  // as utility functions.
                  options.trimHeadFrames += 1;

                  var frames = this._prepareFrames(stack, options);
                  data.stacktrace = {
                    // Sentry expects frames oldest to newest
                    frames: frames.reverse(),
                  };
                }

                // Make sure that fingerprint is always wrapped in an array
                if (data.fingerprint) {
                  data.fingerprint = isArray(data.fingerprint)
                    ? data.fingerprint
                    : [data.fingerprint];
                }

                // Fire away!
                this._send(data);

                return this;
              },

              captureBreadcrumb: function (obj) {
                var crumb = objectMerge(
                  {
                    timestamp: now() / 1000,
                  },
                  obj,
                );

                if (isFunction(this._globalOptions.breadcrumbCallback)) {
                  var result = this._globalOptions.breadcrumbCallback(crumb);

                  if (isObject(result) && !isEmptyObject(result)) {
                    crumb = result;
                  } else if (result === false) {
                    return this;
                  }
                }

                this._breadcrumbs.push(crumb);
                if (
                  this._breadcrumbs.length > this._globalOptions.maxBreadcrumbs
                ) {
                  this._breadcrumbs.shift();
                }
                return this;
              },

              addPlugin: function (plugin /*arg1, arg2, ... argN*/) {
                var pluginArgs = [].slice.call(arguments, 1);

                this._plugins.push([plugin, pluginArgs]);
                if (this._isRavenInstalled) {
                  this._drainPlugins();
                }

                return this;
              },

              /*
               * Set/clear a user to be sent along with the payload.
               *
               * @param {object} user An object representing user data [optional]
               * @return {Raven}
               */
              setUserContext: function (user) {
                // Intentionally do not merge here since that's an unexpected behavior.
                this._globalContext.user = user;

                return this;
              },

              /*
               * Merge extra attributes to be sent along with the payload.
               *
               * @param {object} extra An object representing extra data [optional]
               * @return {Raven}
               */
              setExtraContext: function (extra) {
                this._mergeContext("extra", extra);

                return this;
              },

              /*
               * Merge tags to be sent along with the payload.
               *
               * @param {object} tags An object representing tags [optional]
               * @return {Raven}
               */
              setTagsContext: function (tags) {
                this._mergeContext("tags", tags);

                return this;
              },

              /*
               * Clear all of the context.
               *
               * @return {Raven}
               */
              clearContext: function () {
                this._globalContext = {};

                return this;
              },

              /*
               * Get a copy of the current context. This cannot be mutated.
               *
               * @return {object} copy of context
               */
              getContext: function () {
                // lol javascript
                return JSON.parse(stringify(this._globalContext));
              },

              /*
               * Set environment of application
               *
               * @param {string} environment Typically something like 'production'.
               * @return {Raven}
               */
              setEnvironment: function (environment) {
                this._globalOptions.environment = environment;

                return this;
              },

              /*
               * Set release version of application
               *
               * @param {string} release Typically something like a git SHA to identify version
               * @return {Raven}
               */
              setRelease: function (release) {
                this._globalOptions.release = release;

                return this;
              },

              /*
               * Set the dataCallback option
               *
               * @param {function} callback The callback to run which allows the
               *                            data blob to be mutated before sending
               * @return {Raven}
               */
              setDataCallback: function (callback) {
                var original = this._globalOptions.dataCallback;
                this._globalOptions.dataCallback = keepOriginalCallback(
                  original,
                  callback,
                );
                return this;
              },

              /*
               * Set the breadcrumbCallback option
               *
               * @param {function} callback The callback to run which allows filtering
               *                            or mutating breadcrumbs
               * @return {Raven}
               */
              setBreadcrumbCallback: function (callback) {
                var original = this._globalOptions.breadcrumbCallback;
                this._globalOptions.breadcrumbCallback = keepOriginalCallback(
                  original,
                  callback,
                );
                return this;
              },

              /*
               * Set the shouldSendCallback option
               *
               * @param {function} callback The callback to run which allows
               *                            introspecting the blob before sending
               * @return {Raven}
               */
              setShouldSendCallback: function (callback) {
                var original = this._globalOptions.shouldSendCallback;
                this._globalOptions.shouldSendCallback = keepOriginalCallback(
                  original,
                  callback,
                );
                return this;
              },

              /**
               * Override the default HTTP transport mechanism that transmits data
               * to the Sentry server.
               *
               * @param {function} transport Function invoked instead of the default
               *                             `makeRequest` handler.
               *
               * @return {Raven}
               */
              setTransport: function (transport) {
                this._globalOptions.transport = transport;

                return this;
              },

              /*
               * Get the latest raw exception that was captured by Raven.
               *
               * @return {error}
               */
              lastException: function () {
                return this._lastCapturedException;
              },

              /*
               * Get the last event id
               *
               * @return {string}
               */
              lastEventId: function () {
                return this._lastEventId;
              },

              /*
               * Determine if Raven is setup and ready to go.
               *
               * @return {boolean}
               */
              isSetup: function () {
                if (!this._hasJSON) return false; // needs JSON support
                if (!this._globalServer) {
                  if (!this.ravenNotConfiguredError) {
                    this.ravenNotConfiguredError = true;
                    this._logDebug(
                      "error",
                      "Error: Raven has not been configured.",
                    );
                  }
                  return false;
                }
                return true;
              },

              afterLoad: function () {
                // TODO: remove window dependence?

                // Attempt to initialize Raven on load
                var RavenConfig = _window.RavenConfig;
                if (RavenConfig) {
                  this.config(RavenConfig.dsn, RavenConfig.config).install();
                }
              },

              showReportDialog: function (options) {
                if (
                  !_document // doesn't work without a document (React native)
                )
                  return;

                options = options || {};

                var lastEventId = options.eventId || this.lastEventId();
                if (!lastEventId) {
                  throw new RavenConfigError("Missing eventId");
                }

                var dsn = options.dsn || this._dsn;
                if (!dsn) {
                  throw new RavenConfigError("Missing DSN");
                }

                var encode = encodeURIComponent;
                var qs = "";
                qs += "?eventId=" + encode(lastEventId);
                qs += "&dsn=" + encode(dsn);

                var user = options.user || this._globalContext.user;
                if (user) {
                  if (user.name) qs += "&name=" + encode(user.name);
                  if (user.email) qs += "&email=" + encode(user.email);
                }

                var globalServer = this._getGlobalServer(this._parseDSN(dsn));

                var script = _document.createElement("script");
                script.async = true;
                script.src = globalServer + "/api/embed/error-page/" + qs;
                (_document.head || _document.body).appendChild(script);
              },

              /**** Private functions ****/
              _ignoreNextOnError: function () {
                var self = this;
                this._ignoreOnError += 1;
                setTimeout(function () {
                  // onerror should trigger before setTimeout
                  self._ignoreOnError -= 1;
                });
              },

              _triggerEvent: function (eventType, options) {
                // NOTE: `event` is a native browser thing, so let's avoid conflicting wiht it
                var evt, key;

                if (!this._hasDocument) return;

                options = options || {};

                eventType =
                  "raven" +
                  eventType.substr(0, 1).toUpperCase() +
                  eventType.substr(1);

                if (_document.createEvent) {
                  evt = _document.createEvent("HTMLEvents");
                  evt.initEvent(eventType, true, true);
                } else {
                  evt = _document.createEventObject();
                  evt.eventType = eventType;
                }

                for (key in options)
                  if (hasKey(options, key)) {
                    evt[key] = options[key];
                  }

                if (_document.createEvent) {
                  // IE9 if standards
                  _document.dispatchEvent(evt);
                } else {
                  // IE8 regardless of Quirks or Standards
                  // IE9 if quirks
                  try {
                    _document.fireEvent(
                      "on" + evt.eventType.toLowerCase(),
                      evt,
                    );
                  } catch (e) {
                    // Do nothing
                  }
                }
              },

              /**
               * Wraps addEventListener to capture UI breadcrumbs
               * @param evtName the event name (e.g. "click")
               * @returns {Function}
               * @private
               */
              _breadcrumbEventHandler: function (evtName) {
                var self = this;
                return function (evt) {
                  // reset keypress timeout; e.g. triggering a 'click' after
                  // a 'keypress' will reset the keypress debounce so that a new
                  // set of keypresses can be recorded
                  self._keypressTimeout = null;

                  // It's possible this handler might trigger multiple times for the same
                  // event (e.g. event propagation through node ancestors). Ignore if we've
                  // already captured the event.
                  if (self._lastCapturedEvent === evt) return;

                  self._lastCapturedEvent = evt;

                  // try/catch both:
                  // - accessing evt.target (see getsentry/raven-js#838, #768)
                  // - `htmlTreeAsString` because it's complex, and just accessing the DOM incorrectly
                  //   can throw an exception in some circumstances.
                  var target;
                  try {
                    target = htmlTreeAsString(evt.target);
                  } catch (e) {
                    target = "<unknown>";
                  }

                  self.captureBreadcrumb({
                    category: "ui." + evtName, // e.g. ui.click, ui.input
                    message: target,
                  });
                };
              },

              /**
               * Wraps addEventListener to capture keypress UI events
               * @returns {Function}
               * @private
               */
              _keypressEventHandler: function () {
                var self = this,
                  debounceDuration = 1000; // milliseconds

                // TODO: if somehow user switches keypress target before
                //       debounce timeout is triggered, we will only capture
                //       a single breadcrumb from the FIRST target (acceptable?)
                return function (evt) {
                  var target;
                  try {
                    target = evt.target;
                  } catch (e) {
                    // just accessing event properties can throw an exception in some rare circumstances
                    // see: https://github.com/getsentry/raven-js/issues/838
                    return;
                  }
                  var tagName = target && target.tagName;

                  // only consider keypress events on actual input elements
                  // this will disregard keypresses targeting body (e.g. tabbing
                  // through elements, hotkeys, etc)
                  if (
                    !tagName ||
                    (tagName !== "INPUT" &&
                      tagName !== "TEXTAREA" &&
                      !target.isContentEditable)
                  )
                    return;

                  // record first keypress in a series, but ignore subsequent
                  // keypresses until debounce clears
                  var timeout = self._keypressTimeout;
                  if (!timeout) {
                    self._breadcrumbEventHandler("input")(evt);
                  }
                  clearTimeout(timeout);
                  self._keypressTimeout = setTimeout(function () {
                    self._keypressTimeout = null;
                  }, debounceDuration);
                };
              },

              /**
               * Captures a breadcrumb of type "navigation", normalizing input URLs
               * @param to the originating URL
               * @param from the target URL
               * @private
               */
              _captureUrlChange: function (from, to) {
                var parsedLoc = parseUrl(this._location.href);
                var parsedTo = parseUrl(to);
                var parsedFrom = parseUrl(from);

                // because onpopstate only tells you the "new" (to) value of location.href, and
                // not the previous (from) value, we need to track the value of the current URL
                // state ourselves
                this._lastHref = to;

                // Use only the path component of the URL if the URL matches the current
                // document (almost all the time when using pushState)
                if (
                  parsedLoc.protocol === parsedTo.protocol &&
                  parsedLoc.host === parsedTo.host
                )
                  to = parsedTo.relative;
                if (
                  parsedLoc.protocol === parsedFrom.protocol &&
                  parsedLoc.host === parsedFrom.host
                )
                  from = parsedFrom.relative;

                this.captureBreadcrumb({
                  category: "navigation",
                  data: {
                    to: to,
                    from: from,
                  },
                });
              },

              _patchFunctionToString: function () {
                var self = this;
                self._originalFunctionToString = Function.prototype.toString;
                // eslint-disable-next-line no-extend-native
                Function.prototype.toString = function () {
                  if (typeof this === "function" && this.__raven__) {
                    return self._originalFunctionToString.apply(
                      this.__orig__,
                      arguments,
                    );
                  }
                  return self._originalFunctionToString.apply(this, arguments);
                };
              },

              _unpatchFunctionToString: function () {
                if (this._originalFunctionToString) {
                  // eslint-disable-next-line no-extend-native
                  Function.prototype.toString = this._originalFunctionToString;
                }
              },

              /**
               * Wrap timer functions and event targets to catch errors and provide
               * better metadata.
               */
              _instrumentTryCatch: function () {
                var self = this;

                var wrappedBuiltIns = self._wrappedBuiltIns;

                function wrapTimeFn(orig) {
                  return function (fn, t) {
                    // preserve arity
                    // Make a copy of the arguments to prevent deoptimization
                    // https://github.com/petkaantonov/bluebird/wiki/Optimization-killers#32-leaking-arguments
                    var args = new Array(arguments.length);
                    for (var i = 0; i < args.length; ++i) {
                      args[i] = arguments[i];
                    }
                    var originalCallback = args[0];
                    if (isFunction(originalCallback)) {
                      args[0] = self.wrap(originalCallback);
                    }

                    // IE < 9 doesn't support .call/.apply on setInterval/setTimeout, but it
                    // also supports only two arguments and doesn't care what this is, so we
                    // can just call the original function directly.
                    if (orig.apply) {
                      return orig.apply(this, args);
                    } else {
                      return orig(args[0], args[1]);
                    }
                  };
                }

                var autoBreadcrumbs = this._globalOptions.autoBreadcrumbs;

                function wrapEventTarget(global) {
                  var proto = _window[global] && _window[global].prototype;
                  if (
                    proto &&
                    proto.hasOwnProperty &&
                    proto.hasOwnProperty("addEventListener")
                  ) {
                    fill(
                      proto,
                      "addEventListener",
                      function (orig) {
                        return function (evtName, fn, capture, secure) {
                          // preserve arity
                          try {
                            if (fn && fn.handleEvent) {
                              fn.handleEvent = self.wrap(fn.handleEvent);
                            }
                          } catch (err) {
                            // can sometimes get 'Permission denied to access property "handle Event'
                          }

                          // More breadcrumb DOM capture ... done here and not in `_instrumentBreadcrumbs`
                          // so that we don't have more than one wrapper function
                          var before, clickHandler, keypressHandler;

                          if (
                            autoBreadcrumbs &&
                            autoBreadcrumbs.dom &&
                            (global === "EventTarget" || global === "Node")
                          ) {
                            // NOTE: generating multiple handlers per addEventListener invocation, should
                            //       revisit and verify we can just use one (almost certainly)
                            clickHandler =
                              self._breadcrumbEventHandler("click");
                            keypressHandler = self._keypressEventHandler();
                            before = function (evt) {
                              // need to intercept every DOM event in `before` argument, in case that
                              // same wrapped method is re-used for different events (e.g. mousemove THEN click)
                              // see #724
                              if (!evt) return;

                              var eventType;
                              try {
                                eventType = evt.type;
                              } catch (e) {
                                // just accessing event properties can throw an exception in some rare circumstances
                                // see: https://github.com/getsentry/raven-js/issues/838
                                return;
                              }
                              if (eventType === "click")
                                return clickHandler(evt);
                              else if (eventType === "keypress")
                                return keypressHandler(evt);
                            };
                          }
                          return orig.call(
                            this,
                            evtName,
                            self.wrap(fn, undefined, before),
                            capture,
                            secure,
                          );
                        };
                      },
                      wrappedBuiltIns,
                    );
                    fill(
                      proto,
                      "removeEventListener",
                      function (orig) {
                        return function (evt, fn, capture, secure) {
                          try {
                            fn =
                              fn &&
                              (fn.__raven_wrapper__
                                ? fn.__raven_wrapper__
                                : fn);
                          } catch (e) {
                            // ignore, accessing __raven_wrapper__ will throw in some Selenium environments
                          }
                          return orig.call(this, evt, fn, capture, secure);
                        };
                      },
                      wrappedBuiltIns,
                    );
                  }
                }

                fill(_window, "setTimeout", wrapTimeFn, wrappedBuiltIns);
                fill(_window, "setInterval", wrapTimeFn, wrappedBuiltIns);
                if (_window.requestAnimationFrame) {
                  fill(
                    _window,
                    "requestAnimationFrame",
                    function (orig) {
                      return function (cb) {
                        return orig(self.wrap(cb));
                      };
                    },
                    wrappedBuiltIns,
                  );
                }

                // event targets borrowed from bugsnag-js:
                // https://github.com/bugsnag/bugsnag-js/blob/master/src/bugsnag.js#L666
                var eventTargets = [
                  "EventTarget",
                  "Window",
                  "Node",
                  "ApplicationCache",
                  "AudioTrackList",
                  "ChannelMergerNode",
                  "CryptoOperation",
                  "EventSource",
                  "FileReader",
                  "HTMLUnknownElement",
                  "IDBDatabase",
                  "IDBRequest",
                  "IDBTransaction",
                  "KeyOperation",
                  "MediaController",
                  "MessagePort",
                  "ModalWindow",
                  "Notification",
                  "SVGElementInstance",
                  "Screen",
                  "TextTrack",
                  "TextTrackCue",
                  "TextTrackList",
                  "WebSocket",
                  "WebSocketWorker",
                  "Worker",
                  "XMLHttpRequest",
                  "XMLHttpRequestEventTarget",
                  "XMLHttpRequestUpload",
                ];
                for (var i = 0; i < eventTargets.length; i++) {
                  wrapEventTarget(eventTargets[i]);
                }
              },

              /**
               * Instrument browser built-ins w/ breadcrumb capturing
               *  - XMLHttpRequests
               *  - DOM interactions (click/typing)
               *  - window.location changes
               *  - console
               *
               * Can be disabled or individually configured via the `autoBreadcrumbs` config option
               */
              _instrumentBreadcrumbs: function () {
                var self = this;
                var autoBreadcrumbs = this._globalOptions.autoBreadcrumbs;

                var wrappedBuiltIns = self._wrappedBuiltIns;

                function wrapProp(prop, xhr) {
                  if (prop in xhr && isFunction(xhr[prop])) {
                    fill(xhr, prop, function (orig) {
                      return self.wrap(orig);
                    }); // intentionally don't track filled methods on XHR instances
                  }
                }

                if (autoBreadcrumbs.xhr && "XMLHttpRequest" in _window) {
                  var xhrproto =
                    _window.XMLHttpRequest && _window.XMLHttpRequest.prototype;
                  fill(
                    xhrproto,
                    "open",
                    function (origOpen) {
                      return function (method, url) {
                        // preserve arity

                        // if Sentry key appears in URL, don't capture
                        if (
                          isString(url) &&
                          url.indexOf(self._globalKey) === -1
                        ) {
                          this.__raven_xhr = {
                            method: method,
                            url: url,
                            status_code: null,
                          };
                        }

                        return origOpen.apply(this, arguments);
                      };
                    },
                    wrappedBuiltIns,
                  );

                  fill(
                    xhrproto,
                    "send",
                    function (origSend) {
                      return function () {
                        // preserve arity
                        var xhr = this;

                        function onreadystatechangeHandler() {
                          if (xhr.__raven_xhr && xhr.readyState === 4) {
                            try {
                              // touching statusCode in some platforms throws
                              // an exception
                              xhr.__raven_xhr.status_code = xhr.status;
                            } catch (e) {
                              /* do nothing */
                            }

                            self.captureBreadcrumb({
                              type: "http",
                              category: "xhr",
                              data: xhr.__raven_xhr,
                            });
                          }
                        }

                        var props = ["onload", "onerror", "onprogress"];
                        for (var j = 0; j < props.length; j++) {
                          wrapProp(props[j], xhr);
                        }

                        if (
                          "onreadystatechange" in xhr &&
                          isFunction(xhr.onreadystatechange)
                        ) {
                          fill(
                            xhr,
                            "onreadystatechange",
                            function (orig) {
                              return self.wrap(
                                orig,
                                undefined,
                                onreadystatechangeHandler,
                              );
                            } /* intentionally don't track this instrumentation */,
                          );
                        } else {
                          // if onreadystatechange wasn't actually set by the page on this xhr, we
                          // are free to set our own and capture the breadcrumb
                          xhr.onreadystatechange = onreadystatechangeHandler;
                        }

                        return origSend.apply(this, arguments);
                      };
                    },
                    wrappedBuiltIns,
                  );
                }

                if (autoBreadcrumbs.xhr && supportsFetch()) {
                  fill(
                    _window,
                    "fetch",
                    function (origFetch) {
                      return function () {
                        // preserve arity
                        // Make a copy of the arguments to prevent deoptimization
                        // https://github.com/petkaantonov/bluebird/wiki/Optimization-killers#32-leaking-arguments
                        var args = new Array(arguments.length);
                        for (var i = 0; i < args.length; ++i) {
                          args[i] = arguments[i];
                        }

                        var fetchInput = args[0];
                        var method = "GET";
                        var url;

                        if (typeof fetchInput === "string") {
                          url = fetchInput;
                        } else if (
                          "Request" in _window &&
                          fetchInput instanceof _window.Request
                        ) {
                          url = fetchInput.url;
                          if (fetchInput.method) {
                            method = fetchInput.method;
                          }
                        } else {
                          url = "" + fetchInput;
                        }

                        // if Sentry key appears in URL, don't capture, as it's our own request
                        if (url.indexOf(self._globalKey) !== -1) {
                          return origFetch.apply(this, args);
                        }

                        if (args[1] && args[1].method) {
                          method = args[1].method;
                        }

                        var fetchData = {
                          method: method,
                          url: url,
                          status_code: null,
                        };

                        return origFetch
                          .apply(this, args)
                          .then(function (response) {
                            fetchData.status_code = response.status;

                            self.captureBreadcrumb({
                              type: "http",
                              category: "fetch",
                              data: fetchData,
                            });

                            return response;
                          })
                          ["catch"](function (err) {
                            // if there is an error performing the request
                            self.captureBreadcrumb({
                              type: "http",
                              category: "fetch",
                              data: fetchData,
                              level: "error",
                            });

                            throw err;
                          });
                      };
                    },
                    wrappedBuiltIns,
                  );
                }

                // Capture breadcrumbs from any click that is unhandled / bubbled up all the way
                // to the document. Do this before we instrument addEventListener.
                if (autoBreadcrumbs.dom && this._hasDocument) {
                  if (_document.addEventListener) {
                    _document.addEventListener(
                      "click",
                      self._breadcrumbEventHandler("click"),
                      false,
                    );
                    _document.addEventListener(
                      "keypress",
                      self._keypressEventHandler(),
                      false,
                    );
                  } else if (_document.attachEvent) {
                    // IE8 Compatibility
                    _document.attachEvent(
                      "onclick",
                      self._breadcrumbEventHandler("click"),
                    );
                    _document.attachEvent(
                      "onkeypress",
                      self._keypressEventHandler(),
                    );
                  }
                }

                // record navigation (URL) changes
                // NOTE: in Chrome App environment, touching history.pushState, *even inside
                //       a try/catch block*, will cause Chrome to output an error to console.error
                // borrowed from: https://github.com/angular/angular.js/pull/13945/files
                var chrome = _window.chrome;
                var isChromePackagedApp =
                  chrome && chrome.app && chrome.app.runtime;
                var hasPushAndReplaceState =
                  !isChromePackagedApp &&
                  _window.history &&
                  _window.history.pushState &&
                  _window.history.replaceState;
                if (autoBreadcrumbs.location && hasPushAndReplaceState) {
                  // TODO: remove onpopstate handler on uninstall()
                  var oldOnPopState = _window.onpopstate;
                  _window.onpopstate = function () {
                    var currentHref = self._location.href;
                    self._captureUrlChange(self._lastHref, currentHref);

                    if (oldOnPopState) {
                      return oldOnPopState.apply(this, arguments);
                    }
                  };

                  var historyReplacementFunction = function (origHistFunction) {
                    // note history.pushState.length is 0; intentionally not declaring
                    // params to preserve 0 arity
                    return function (/* state, title, url */) {
                      var url = arguments.length > 2 ? arguments[2] : undefined;

                      // url argument is optional
                      if (url) {
                        // coerce to string (this is what pushState does)
                        self._captureUrlChange(self._lastHref, url + "");
                      }

                      return origHistFunction.apply(this, arguments);
                    };
                  };

                  fill(
                    _window.history,
                    "pushState",
                    historyReplacementFunction,
                    wrappedBuiltIns,
                  );
                  fill(
                    _window.history,
                    "replaceState",
                    historyReplacementFunction,
                    wrappedBuiltIns,
                  );
                }

                if (
                  autoBreadcrumbs.console &&
                  "console" in _window &&
                  console.log
                ) {
                  // console
                  var consoleMethodCallback = function (msg, data) {
                    self.captureBreadcrumb({
                      message: msg,
                      level: data.level,
                      category: "console",
                    });
                  };

                  each(
                    ["debug", "info", "warn", "error", "log"],
                    function (_, level) {
                      wrapConsoleMethod(console, level, consoleMethodCallback);
                    },
                  );
                }
              },

              _restoreBuiltIns: function () {
                // restore any wrapped builtins
                var builtin;
                while (this._wrappedBuiltIns.length) {
                  builtin = this._wrappedBuiltIns.shift();

                  var obj = builtin[0],
                    name = builtin[1],
                    orig = builtin[2];

                  obj[name] = orig;
                }
              },

              _restoreConsole: function () {
                // eslint-disable-next-line guard-for-in
                for (var method in this._originalConsoleMethods) {
                  this._originalConsole[method] =
                    this._originalConsoleMethods[method];
                }
              },

              _drainPlugins: function () {
                var self = this;

                // FIX ME TODO
                each(this._plugins, function (_, plugin) {
                  var installer = plugin[0];
                  var args = plugin[1];
                  installer.apply(self, [self].concat(args));
                });
              },

              _parseDSN: function (str) {
                var m = dsnPattern.exec(str),
                  dsn = {},
                  i = 7;

                try {
                  while (i--) dsn[dsnKeys[i]] = m[i] || "";
                } catch (e) {
                  throw new RavenConfigError("Invalid DSN: " + str);
                }

                if (dsn.pass && !this._globalOptions.allowSecretKey) {
                  throw new RavenConfigError(
                    "Do not specify your secret key in the DSN. See: http://bit.ly/raven-secret-key",
                  );
                }

                return dsn;
              },

              _getGlobalServer: function (uri) {
                // assemble the endpoint from the uri pieces
                var globalServer =
                  "//" + uri.host + (uri.port ? ":" + uri.port : "");

                if (uri.protocol) {
                  globalServer = uri.protocol + ":" + globalServer;
                }
                return globalServer;
              },

              _handleOnErrorStackInfo: function () {
                // if we are intentionally ignoring errors via onerror, bail out
                if (!this._ignoreOnError) {
                  this._handleStackInfo.apply(this, arguments);
                }
              },

              _handleStackInfo: function (stackInfo, options) {
                var frames = this._prepareFrames(stackInfo, options);

                this._triggerEvent("handle", {
                  stackInfo: stackInfo,
                  options: options,
                });

                this._processException(
                  stackInfo.name,
                  stackInfo.message,
                  stackInfo.url,
                  stackInfo.lineno,
                  frames,
                  options,
                );
              },

              _prepareFrames: function (stackInfo, options) {
                var self = this;
                var frames = [];
                if (stackInfo.stack && stackInfo.stack.length) {
                  each(stackInfo.stack, function (i, stack) {
                    var frame = self._normalizeFrame(stack, stackInfo.url);
                    if (frame) {
                      frames.push(frame);
                    }
                  });

                  // e.g. frames captured via captureMessage throw
                  if (options && options.trimHeadFrames) {
                    for (
                      var j = 0;
                      j < options.trimHeadFrames && j < frames.length;
                      j++
                    ) {
                      frames[j].in_app = false;
                    }
                  }
                }
                frames = frames.slice(0, this._globalOptions.stackTraceLimit);
                return frames;
              },

              _normalizeFrame: function (frame, stackInfoUrl) {
                // normalize the frames data
                var normalized = {
                  filename: frame.url,
                  lineno: frame.line,
                  colno: frame.column,
                  function: frame.func || "?",
                };

                // Case when we don't have any information about the error
                // E.g. throwing a string or raw object, instead of an `Error` in Firefox
                // Generating synthetic error doesn't add any value here
                //
                // We should probably somehow let a user know that they should fix their code
                if (!frame.url) {
                  normalized.filename = stackInfoUrl; // fallback to whole stacks url from onerror handler
                }

                normalized.in_app = !(
                  // determine if an exception came from outside of our app
                  // first we check the global includePaths list.
                  (
                    (!!this._globalOptions.includePaths.test &&
                      !this._globalOptions.includePaths.test(
                        normalized.filename,
                      )) ||
                    // Now we check for fun, if the function name is Raven or TraceKit
                    /(Raven|TraceKit)\./.test(normalized["function"]) ||
                    // finally, we do a last ditch effort and check for raven.min.js
                    /raven\.(min\.)?js$/.test(normalized.filename)
                  )
                );

                return normalized;
              },

              _processException: function (
                type,
                message,
                fileurl,
                lineno,
                frames,
                options,
              ) {
                var prefixedMessage =
                  (type ? type + ": " : "") + (message || "");
                if (
                  !!this._globalOptions.ignoreErrors.test &&
                  (this._globalOptions.ignoreErrors.test(message) ||
                    this._globalOptions.ignoreErrors.test(prefixedMessage))
                ) {
                  return;
                }

                var stacktrace;

                if (frames && frames.length) {
                  fileurl = frames[0].filename || fileurl;
                  // Sentry expects frames oldest to newest
                  // and JS sends them as newest to oldest
                  frames.reverse();
                  stacktrace = { frames: frames };
                } else if (fileurl) {
                  stacktrace = {
                    frames: [
                      {
                        filename: fileurl,
                        lineno: lineno,
                        in_app: true,
                      },
                    ],
                  };
                }

                if (
                  !!this._globalOptions.ignoreUrls.test &&
                  this._globalOptions.ignoreUrls.test(fileurl)
                ) {
                  return;
                }

                if (
                  !!this._globalOptions.whitelistUrls.test &&
                  !this._globalOptions.whitelistUrls.test(fileurl)
                ) {
                  return;
                }

                var data = objectMerge(
                  {
                    // sentry.interfaces.Exception
                    exception: {
                      values: [
                        {
                          type: type,
                          value: message,
                          stacktrace: stacktrace,
                        },
                      ],
                    },
                    transaction: fileurl,
                  },
                  options,
                );

                // Fire away!
                this._send(data);
              },

              _trimPacket: function (data) {
                // For now, we only want to truncate the two different messages
                // but this could/should be expanded to just trim everything
                var max = this._globalOptions.maxMessageLength;
                if (data.message) {
                  data.message = truncate(data.message, max);
                }
                if (data.exception) {
                  var exception = data.exception.values[0];
                  exception.value = truncate(exception.value, max);
                }

                var request = data.request;
                if (request) {
                  if (request.url) {
                    request.url = truncate(
                      request.url,
                      this._globalOptions.maxUrlLength,
                    );
                  }
                  if (request.Referer) {
                    request.Referer = truncate(
                      request.Referer,
                      this._globalOptions.maxUrlLength,
                    );
                  }
                }

                if (data.breadcrumbs && data.breadcrumbs.values)
                  this._trimBreadcrumbs(data.breadcrumbs);

                return data;
              },

              /**
               * Truncate breadcrumb values (right now just URLs)
               */
              _trimBreadcrumbs: function (breadcrumbs) {
                // known breadcrumb properties with urls
                // TODO: also consider arbitrary prop values that start with (https?)?://
                var urlProps = ["to", "from", "url"],
                  urlProp,
                  crumb,
                  data;

                for (var i = 0; i < breadcrumbs.values.length; ++i) {
                  crumb = breadcrumbs.values[i];
                  if (
                    !crumb.hasOwnProperty("data") ||
                    !isObject(crumb.data) ||
                    objectFrozen(crumb.data)
                  )
                    continue;

                  data = objectMerge({}, crumb.data);
                  for (var j = 0; j < urlProps.length; ++j) {
                    urlProp = urlProps[j];
                    if (data.hasOwnProperty(urlProp) && data[urlProp]) {
                      data[urlProp] = truncate(
                        data[urlProp],
                        this._globalOptions.maxUrlLength,
                      );
                    }
                  }
                  breadcrumbs.values[i].data = data;
                }
              },

              _getHttpData: function () {
                if (!this._hasNavigator && !this._hasDocument) return;
                var httpData = {};

                if (this._hasNavigator && _navigator.userAgent) {
                  httpData.headers = {
                    "User-Agent": _navigator.userAgent,
                  };
                }

                // Check in `window` instead of `document`, as we may be in ServiceWorker environment
                if (_window.location && _window.location.href) {
                  httpData.url = _window.location.href;
                }

                if (this._hasDocument && _document.referrer) {
                  if (!httpData.headers) httpData.headers = {};
                  httpData.headers.Referer = _document.referrer;
                }

                return httpData;
              },

              _resetBackoff: function () {
                this._backoffDuration = 0;
                this._backoffStart = null;
              },

              _shouldBackoff: function () {
                return (
                  this._backoffDuration &&
                  now() - this._backoffStart < this._backoffDuration
                );
              },

              /**
               * Returns true if the in-process data payload matches the signature
               * of the previously-sent data
               *
               * NOTE: This has to be done at this level because TraceKit can generate
               *       data from window.onerror WITHOUT an exception object (IE8, IE9,
               *       other old browsers). This can take the form of an "exception"
               *       data object with a single frame (derived from the onerror args).
               */
              _isRepeatData: function (current) {
                var last = this._lastData;

                if (
                  !last ||
                  current.message !== last.message || // defined for captureMessage
                  current.transaction !== last.transaction // defined for captureException/onerror
                )
                  return false;

                // Stacktrace interface (i.e. from captureMessage)
                if (current.stacktrace || last.stacktrace) {
                  return isSameStacktrace(current.stacktrace, last.stacktrace);
                } else if (current.exception || last.exception) {
                  // Exception interface (i.e. from captureException/onerror)
                  return isSameException(current.exception, last.exception);
                }

                return true;
              },

              _setBackoffState: function (request) {
                // If we are already in a backoff state, don't change anything
                if (this._shouldBackoff()) {
                  return;
                }

                var status = request.status;

                // 400 - project_id doesn't exist or some other fatal
                // 401 - invalid/revoked dsn
                // 429 - too many requests
                if (!(status === 400 || status === 401 || status === 429))
                  return;

                var retry;
                try {
                  // If Retry-After is not in Access-Control-Expose-Headers, most
                  // browsers will throw an exception trying to access it
                  if (supportsFetch()) {
                    retry = request.headers.get("Retry-After");
                  } else {
                    retry = request.getResponseHeader("Retry-After");
                  }

                  // Retry-After is returned in seconds
                  retry = parseInt(retry, 10) * 1000;
                } catch (e) {
                  /* eslint no-empty:0 */
                }

                this._backoffDuration = retry
                  ? // If Sentry server returned a Retry-After value, use it
                    retry
                  : // Otherwise, double the last backoff duration (starts at 1 sec)
                    this._backoffDuration * 2 || 1000;

                this._backoffStart = now();
              },

              _send: function (data) {
                var globalOptions = this._globalOptions;

                var baseData = {
                    project: this._globalProject,
                    logger: globalOptions.logger,
                    platform: "javascript",
                  },
                  httpData = this._getHttpData();

                if (httpData) {
                  baseData.request = httpData;
                }

                // HACK: delete `trimHeadFrames` to prevent from appearing in outbound payload
                if (data.trimHeadFrames) delete data.trimHeadFrames;

                data = objectMerge(baseData, data);

                // Merge in the tags and extra separately since objectMerge doesn't handle a deep merge
                data.tags = objectMerge(
                  objectMerge({}, this._globalContext.tags),
                  data.tags,
                );
                data.extra = objectMerge(
                  objectMerge({}, this._globalContext.extra),
                  data.extra,
                );

                // Send along our own collected metadata with extra
                data.extra["session:duration"] = now() - this._startTime;

                if (this._breadcrumbs && this._breadcrumbs.length > 0) {
                  // intentionally make shallow copy so that additions
                  // to breadcrumbs aren't accidentally sent in this request
                  data.breadcrumbs = {
                    values: [].slice.call(this._breadcrumbs, 0),
                  };
                }

                if (this._globalContext.user) {
                  // sentry.interfaces.User
                  data.user = this._globalContext.user;
                }

                // Include the environment if it's defined in globalOptions
                if (globalOptions.environment)
                  data.environment = globalOptions.environment;

                // Include the release if it's defined in globalOptions
                if (globalOptions.release) data.release = globalOptions.release;

                // Include server_name if it's defined in globalOptions
                if (globalOptions.serverName)
                  data.server_name = globalOptions.serverName;

                data = this._sanitizeData(data);

                // Cleanup empty properties before sending them to the server
                Object.keys(data).forEach(function (key) {
                  if (
                    data[key] == null ||
                    data[key] === "" ||
                    isEmptyObject(data[key])
                  ) {
                    delete data[key];
                  }
                });

                if (isFunction(globalOptions.dataCallback)) {
                  data = globalOptions.dataCallback(data) || data;
                }

                // Why??????????
                if (!data || isEmptyObject(data)) {
                  return;
                }

                // Check if the request should be filtered or not
                if (
                  isFunction(globalOptions.shouldSendCallback) &&
                  !globalOptions.shouldSendCallback(data)
                ) {
                  return;
                }

                // Backoff state: Sentry server previously responded w/ an error (e.g. 429 - too many requests),
                // so drop requests until "cool-off" period has elapsed.
                if (this._shouldBackoff()) {
                  this._logDebug(
                    "warn",
                    "Raven dropped error due to backoff: ",
                    data,
                  );
                  return;
                }

                if (typeof globalOptions.sampleRate === "number") {
                  if (Math.random() < globalOptions.sampleRate) {
                    this._sendProcessedPayload(data);
                  }
                } else {
                  this._sendProcessedPayload(data);
                }
              },

              _sanitizeData: function (data) {
                return sanitize(data, this._globalOptions.sanitizeKeys);
              },

              _getUuid: function () {
                return uuid4();
              },

              _sendProcessedPayload: function (data, callback) {
                var self = this;
                var globalOptions = this._globalOptions;

                if (!this.isSetup()) return;

                // Try and clean up the packet before sending by truncating long values
                data = this._trimPacket(data);

                // ideally duplicate error testing should occur *before* dataCallback/shouldSendCallback,
                // but this would require copying an un-truncated copy of the data packet, which can be
                // arbitrarily deep (extra_data) -- could be worthwhile? will revisit
                if (
                  !this._globalOptions.allowDuplicates &&
                  this._isRepeatData(data)
                ) {
                  this._logDebug("warn", "Raven dropped repeat event: ", data);
                  return;
                }

                // Send along an event_id if not explicitly passed.
                // This event_id can be used to reference the error within Sentry itself.
                // Set lastEventId after we know the error should actually be sent
                this._lastEventId =
                  data.event_id || (data.event_id = this._getUuid());

                // Store outbound payload after trim
                this._lastData = data;

                this._logDebug("debug", "Raven about to send:", data);

                var auth = {
                  sentry_version: "7",
                  sentry_client: "raven-js/" + this.VERSION,
                  sentry_key: this._globalKey,
                };

                if (this._globalSecret) {
                  auth.sentry_secret = this._globalSecret;
                }

                var exception = data.exception && data.exception.values[0];

                // only capture 'sentry' breadcrumb is autoBreadcrumbs is truthy
                if (
                  this._globalOptions.autoBreadcrumbs &&
                  this._globalOptions.autoBreadcrumbs.sentry
                ) {
                  this.captureBreadcrumb({
                    category: "sentry",
                    message: exception
                      ? (exception.type ? exception.type + ": " : "") +
                        exception.value
                      : data.message,
                    event_id: data.event_id,
                    level: data.level || "error", // presume error unless specified
                  });
                }

                var url = this._globalEndpoint;
                (globalOptions.transport || this._makeRequest).call(this, {
                  url: url,
                  auth: auth,
                  data: data,
                  options: globalOptions,
                  onSuccess: function success() {
                    self._resetBackoff();

                    self._triggerEvent("success", {
                      data: data,
                      src: url,
                    });
                    callback && callback();
                  },
                  onError: function failure(error) {
                    self._logDebug(
                      "error",
                      "Raven transport failed to send: ",
                      error,
                    );

                    if (error.request) {
                      self._setBackoffState(error.request);
                    }

                    self._triggerEvent("failure", {
                      data: data,
                      src: url,
                    });
                    error =
                      error ||
                      new Error(
                        "Raven send failed (no additional details provided)",
                      );
                    callback && callback(error);
                  },
                });
              },

              _makeRequest: function (opts) {
                // Auth is intentionally sent as part of query string (NOT as custom HTTP header) to avoid preflight CORS requests
                var url = opts.url + "?" + urlencode(opts.auth);

                var evaluatedHeaders = null;
                var evaluatedFetchParameters = {};

                if (opts.options.headers) {
                  evaluatedHeaders = this._evaluateHash(opts.options.headers);
                }

                if (opts.options.fetchParameters) {
                  evaluatedFetchParameters = this._evaluateHash(
                    opts.options.fetchParameters,
                  );
                }

                if (supportsFetch()) {
                  evaluatedFetchParameters.body = stringify(opts.data);

                  var defaultFetchOptions = objectMerge(
                    {},
                    this._fetchDefaults,
                  );
                  var fetchOptions = objectMerge(
                    defaultFetchOptions,
                    evaluatedFetchParameters,
                  );

                  if (evaluatedHeaders) {
                    fetchOptions.headers = evaluatedHeaders;
                  }

                  return _window
                    .fetch(url, fetchOptions)
                    .then(function (response) {
                      if (response.ok) {
                        opts.onSuccess && opts.onSuccess();
                      } else {
                        var error = new Error(
                          "Sentry error code: " + response.status,
                        );
                        // It's called request only to keep compatibility with XHR interface
                        // and not add more redundant checks in setBackoffState method
                        error.request = response;
                        opts.onError && opts.onError(error);
                      }
                    })
                    ["catch"](function () {
                      opts.onError &&
                        opts.onError(
                          new Error("Sentry error code: network unavailable"),
                        );
                    });
                }

                var request =
                  _window.XMLHttpRequest && new _window.XMLHttpRequest();
                if (!request) return;

                // if browser doesn't support CORS (e.g. IE7), we are out of luck
                var hasCORS =
                  "withCredentials" in request ||
                  typeof XDomainRequest !== "undefined";

                if (!hasCORS) return;

                if ("withCredentials" in request) {
                  request.onreadystatechange = function () {
                    if (request.readyState !== 4) {
                      return;
                    } else if (request.status === 200) {
                      opts.onSuccess && opts.onSuccess();
                    } else if (opts.onError) {
                      var err = new Error(
                        "Sentry error code: " + request.status,
                      );
                      err.request = request;
                      opts.onError(err);
                    }
                  };
                } else {
                  request = new XDomainRequest();
                  // xdomainrequest cannot go http -> https (or vice versa),
                  // so always use protocol relative
                  url = url.replace(/^https?:/, "");

                  // onreadystatechange not supported by XDomainRequest
                  if (opts.onSuccess) {
                    request.onload = opts.onSuccess;
                  }
                  if (opts.onError) {
                    request.onerror = function () {
                      var err = new Error("Sentry error code: XDomainRequest");
                      err.request = request;
                      opts.onError(err);
                    };
                  }
                }

                request.open("POST", url);

                if (evaluatedHeaders) {
                  each(evaluatedHeaders, function (key, value) {
                    request.setRequestHeader(key, value);
                  });
                }

                request.send(stringify(opts.data));
              },

              _evaluateHash: function (hash) {
                var evaluated = {};

                for (var key in hash) {
                  if (hash.hasOwnProperty(key)) {
                    var value = hash[key];
                    evaluated[key] =
                      typeof value === "function" ? value() : value;
                  }
                }

                return evaluated;
              },

              _logDebug: function (level) {
                // We allow `Raven.debug` and `Raven.config(DSN, { debug: true })` to not make backward incompatible API change
                if (
                  this._originalConsoleMethods[level] &&
                  (this.debug || this._globalOptions.debug)
                ) {
                  // In IE<10 console methods do not have their own 'apply' method
                  Function.prototype.apply.call(
                    this._originalConsoleMethods[level],
                    this._originalConsole,
                    [].slice.call(arguments, 1),
                  );
                }
              },

              _mergeContext: function (key, context) {
                if (isUndefined(context)) {
                  delete this._globalContext[key];
                } else {
                  this._globalContext[key] = objectMerge(
                    this._globalContext[key] || {},
                    context,
                  );
                }
              },
            };

            // Deprecations
            Raven.prototype.setUser = Raven.prototype.setUserContext;
            Raven.prototype.setReleaseContext = Raven.prototype.setRelease;

            module.exports = Raven;
          }).call(
            this,
            typeof global !== "undefined"
              ? global
              : typeof self !== "undefined"
                ? self
                : typeof window !== "undefined"
                  ? window
                  : {},
          );
        },
        { 1: 1, 2: 2, 5: 5, 6: 6, 7: 7, 8: 8 },
      ],
      4: [
        function (_dereq_, module, exports) {
          (function (global) {
            /**
             * Enforces a single instance of the Raven client, and the
             * main entry point for Raven. If you are a consumer of the
             * Raven library, you SHOULD load this file (vs raven.js).
             **/

            var RavenConstructor = _dereq_(3);

            // This is to be defensive in environments where window does not exist (see https://github.com/getsentry/raven-js/pull/785)
            var _window =
              typeof window !== "undefined"
                ? window
                : typeof global !== "undefined"
                  ? global
                  : typeof self !== "undefined"
                    ? self
                    : {};
            var _Raven = _window.Raven;

            var Raven = new RavenConstructor();

            /*
             * Allow multiple versions of Raven to be installed.
             * Strip Raven from the global context and returns the instance.
             *
             * @return {Raven}
             */
            Raven.noConflict = function () {
              _window.Raven = _Raven;
              return Raven;
            };

            Raven.afterLoad();

            module.exports = Raven;

            /**
             * DISCLAIMER:
             *
             * Expose `Client` constructor for cases where user want to track multiple "sub-applications" in one larger app.
             * It's not meant to be used by a wide audience, so pleaaase make sure that you know what you're doing before using it.
             * Accidentally calling `install` multiple times, may result in an unexpected behavior that's very hard to debug.
             *
             * It's called `Client' to be in-line with Raven Node implementation.
             *
             * HOWTO:
             *
             * import Raven from 'raven-js';
             *
             * const someAppReporter = new Raven.Client();
             * const someOtherAppReporter = new Raven.Client();
             *
             * someAppReporter.config('__DSN__', {
             *   ...config goes here
             * });
             *
             * someOtherAppReporter.config('__OTHER_DSN__', {
             *   ...config goes here
             * });
             *
             * someAppReporter.captureMessage(...);
             * someAppReporter.captureException(...);
             * someAppReporter.captureBreadcrumb(...);
             *
             * someOtherAppReporter.captureMessage(...);
             * someOtherAppReporter.captureException(...);
             * someOtherAppReporter.captureBreadcrumb(...);
             *
             * It should "just work".
             */
            module.exports.Client = RavenConstructor;
          }).call(
            this,
            typeof global !== "undefined"
              ? global
              : typeof self !== "undefined"
                ? self
                : typeof window !== "undefined"
                  ? window
                  : {},
          );
        },
        { 3: 3 },
      ],
      5: [
        function (_dereq_, module, exports) {
          (function (global) {
            var stringify = _dereq_(7);

            var _window =
              typeof window !== "undefined"
                ? window
                : typeof global !== "undefined"
                  ? global
                  : typeof self !== "undefined"
                    ? self
                    : {};

            function isObject(what) {
              return typeof what === "object" && what !== null;
            }

            // Yanked from https://git.io/vS8DV re-used under CC0
            // with some tiny modifications
            function isError(value) {
              switch (Object.prototype.toString.call(value)) {
                case "[object Error]":
                  return true;
                case "[object Exception]":
                  return true;
                case "[object DOMException]":
                  return true;
                default:
                  return value instanceof Error;
              }
            }

            function isErrorEvent(value) {
              return (
                Object.prototype.toString.call(value) === "[object ErrorEvent]"
              );
            }

            function isDOMError(value) {
              return (
                Object.prototype.toString.call(value) === "[object DOMError]"
              );
            }

            function isDOMException(value) {
              return (
                Object.prototype.toString.call(value) ===
                "[object DOMException]"
              );
            }

            function isUndefined(what) {
              return what === void 0;
            }

            function isFunction(what) {
              return typeof what === "function";
            }

            function isPlainObject(what) {
              return Object.prototype.toString.call(what) === "[object Object]";
            }

            function isString(what) {
              return Object.prototype.toString.call(what) === "[object String]";
            }

            function isArray(what) {
              return Object.prototype.toString.call(what) === "[object Array]";
            }

            function isEmptyObject(what) {
              if (!isPlainObject(what)) return false;

              for (var _ in what) {
                if (what.hasOwnProperty(_)) {
                  return false;
                }
              }
              return true;
            }

            function supportsErrorEvent() {
              try {
                new ErrorEvent(""); // eslint-disable-line no-new
                return true;
              } catch (e) {
                return false;
              }
            }

            function supportsDOMError() {
              try {
                new DOMError(""); // eslint-disable-line no-new
                return true;
              } catch (e) {
                return false;
              }
            }

            function supportsDOMException() {
              try {
                new DOMException(""); // eslint-disable-line no-new
                return true;
              } catch (e) {
                return false;
              }
            }

            function supportsFetch() {
              if (!("fetch" in _window)) return false;

              try {
                new Headers(); // eslint-disable-line no-new
                new Request(""); // eslint-disable-line no-new
                new Response(); // eslint-disable-line no-new
                return true;
              } catch (e) {
                return false;
              }
            }

            // Despite all stars in the sky saying that Edge supports old draft syntax, aka 'never', 'always', 'origin' and 'default
            // https://caniuse.com/#feat=referrer-policy
            // It doesn't. And it throw exception instead of ignoring this parameter...
            // REF: https://github.com/getsentry/raven-js/issues/1233
            function supportsReferrerPolicy() {
              if (!supportsFetch()) return false;

              try {
                // eslint-disable-next-line no-new
                new Request("pickleRick", {
                  referrerPolicy: "origin",
                });
                return true;
              } catch (e) {
                return false;
              }
            }

            function supportsPromiseRejectionEvent() {
              return typeof PromiseRejectionEvent === "function";
            }

            function wrappedCallback(callback) {
              function dataCallback(data, original) {
                var normalizedData = callback(data) || data;
                if (original) {
                  return original(normalizedData) || normalizedData;
                }
                return normalizedData;
              }

              return dataCallback;
            }

            function each(obj, callback) {
              var i, j;

              if (isUndefined(obj.length)) {
                for (i in obj) {
                  if (hasKey(obj, i)) {
                    callback.call(null, i, obj[i]);
                  }
                }
              } else {
                j = obj.length;
                if (j) {
                  for (i = 0; i < j; i++) {
                    callback.call(null, i, obj[i]);
                  }
                }
              }
            }

            function objectMerge(obj1, obj2) {
              if (!obj2) {
                return obj1;
              }
              each(obj2, function (key, value) {
                obj1[key] = value;
              });
              return obj1;
            }

            /**
             * This function is only used for react-native.
             * react-native freezes object that have already been sent over the
             * js bridge. We need this function in order to check if the object is frozen.
             * So it's ok that objectFrozen returns false if Object.isFrozen is not
             * supported because it's not relevant for other "platforms". See related issue:
             * https://github.com/getsentry/react-native-sentry/issues/57
             */
            function objectFrozen(obj) {
              if (!Object.isFrozen) {
                return false;
              }
              return Object.isFrozen(obj);
            }

            function truncate(str, max) {
              if (typeof max !== "number") {
                throw new Error(
                  "2nd argument to `truncate` function should be a number",
                );
              }
              if (typeof str !== "string" || max === 0) {
                return str;
              }
              return str.length <= max ? str : str.substr(0, max) + "\u2026";
            }

            /**
             * hasKey, a better form of hasOwnProperty
             * Example: hasKey(MainHostObject, property) === true/false
             *
             * @param {Object} host object to check property
             * @param {string} key to check
             */
            function hasKey(object, key) {
              return Object.prototype.hasOwnProperty.call(object, key);
            }

            function joinRegExp(patterns) {
              // Combine an array of regular expressions and strings into one large regexp
              // Be mad.
              var sources = [],
                i = 0,
                len = patterns.length,
                pattern;

              for (; i < len; i++) {
                pattern = patterns[i];
                if (isString(pattern)) {
                  // If it's a string, we need to escape it
                  // Taken from: https://developer.mozilla.org/en-US/docs/Web/JavaScript/Guide/Regular_Expressions
                  sources.push(
                    pattern.replace(/([.*+?^=!:${}()|\[\]\/\\])/g, "\\$1"),
                  );
                } else if (pattern && pattern.source) {
                  // If it's a regexp already, we want to extract the source
                  sources.push(pattern.source);
                }
                // Intentionally skip other cases
              }
              return new RegExp(sources.join("|"), "i");
            }

            function urlencode(o) {
              var pairs = [];
              each(o, function (key, value) {
                pairs.push(
                  encodeURIComponent(key) + "=" + encodeURIComponent(value),
                );
              });
              return pairs.join("&");
            }

            // borrowed from https://tools.ietf.org/html/rfc3986#appendix-B
            // intentionally using regex and not <a/> href parsing trick because React Native and other
            // environments where DOM might not be available
            function parseUrl(url) {
              if (typeof url !== "string") return {};
              var match = url.match(
                /^(([^:\/?#]+):)?(\/\/([^\/?#]*))?([^?#]*)(\?([^#]*))?(#(.*))?$/,
              );

              // coerce to undefined values to empty string so we don't get 'undefined'
              var query = match[6] || "";
              var fragment = match[8] || "";
              return {
                protocol: match[2],
                host: match[4],
                path: match[5],
                relative: match[5] + query + fragment, // everything minus origin
              };
            }
            function uuid4() {
              var crypto = _window.crypto || _window.msCrypto;

              if (!isUndefined(crypto) && crypto.getRandomValues) {
                // Use window.crypto API if available
                // eslint-disable-next-line no-undef
                var arr = new Uint16Array(8);
                crypto.getRandomValues(arr);

                // set 4 in byte 7
                arr[3] = (arr[3] & 0xfff) | 0x4000;
                // set 2 most significant bits of byte 9 to '10'
                arr[4] = (arr[4] & 0x3fff) | 0x8000;

                var pad = function (num) {
                  var v = num.toString(16);
                  while (v.length < 4) {
                    v = "0" + v;
                  }
                  return v;
                };

                return (
                  pad(arr[0]) +
                  pad(arr[1]) +
                  pad(arr[2]) +
                  pad(arr[3]) +
                  pad(arr[4]) +
                  pad(arr[5]) +
                  pad(arr[6]) +
                  pad(arr[7])
                );
              } else {
                // http://stackoverflow.com/questions/105034/how-to-create-a-guid-uuid-in-javascript/2117523#2117523
                return "xxxxxxxxxxxx4xxxyxxxxxxxxxxxxxxx".replace(
                  /[xy]/g,
                  function (c) {
                    var r = (Math.random() * 16) | 0,
                      v = c === "x" ? r : (r & 0x3) | 0x8;
                    return v.toString(16);
                  },
                );
              }
            }

            /**
             * Given a child DOM element, returns a query-selector statement describing that
             * and its ancestors
             * e.g. [HTMLElement] => body > div > input#foo.btn[name=baz]
             * @param elem
             * @returns {string}
             */
            function htmlTreeAsString(elem) {
              /* eslint no-extra-parens:0*/
              var MAX_TRAVERSE_HEIGHT = 5,
                MAX_OUTPUT_LEN = 80,
                out = [],
                height = 0,
                len = 0,
                separator = " > ",
                sepLength = separator.length,
                nextStr;

              while (elem && height++ < MAX_TRAVERSE_HEIGHT) {
                nextStr = htmlElementAsString(elem);
                // bail out if
                // - nextStr is the 'html' element
                // - the length of the string that would be created exceeds MAX_OUTPUT_LEN
                //   (ignore this limit if we are on the first iteration)
                if (
                  nextStr === "html" ||
                  (height > 1 &&
                    len + out.length * sepLength + nextStr.length >=
                      MAX_OUTPUT_LEN)
                ) {
                  break;
                }

                out.push(nextStr);

                len += nextStr.length;
                elem = elem.parentNode;
              }

              return out.reverse().join(separator);
            }

            /**
             * Returns a simple, query-selector representation of a DOM element
             * e.g. [HTMLElement] => input#foo.btn[name=baz]
             * @param HTMLElement
             * @returns {string}
             */
            function htmlElementAsString(elem) {
              var out = [],
                className,
                classes,
                key,
                attr,
                i;

              if (!elem || !elem.tagName) {
                return "";
              }

              out.push(elem.tagName.toLowerCase());
              if (elem.id) {
                out.push("#" + elem.id);
              }

              className = elem.className;
              if (className && isString(className)) {
                classes = className.split(/\s+/);
                for (i = 0; i < classes.length; i++) {
                  out.push("." + classes[i]);
                }
              }
              var attrWhitelist = ["type", "name", "title", "alt"];
              for (i = 0; i < attrWhitelist.length; i++) {
                key = attrWhitelist[i];
                attr = elem.getAttribute(key);
                if (attr) {
                  out.push("[" + key + '="' + attr + '"]');
                }
              }
              return out.join("");
            }

            /**
             * Returns true if either a OR b is truthy, but not both
             */
            function isOnlyOneTruthy(a, b) {
              return !!(!!a ^ !!b);
            }

            /**
             * Returns true if both parameters are undefined
             */
            function isBothUndefined(a, b) {
              return isUndefined(a) && isUndefined(b);
            }

            /**
             * Returns true if the two input exception interfaces have the same content
             */
            function isSameException(ex1, ex2) {
              if (isOnlyOneTruthy(ex1, ex2)) return false;

              ex1 = ex1.values[0];
              ex2 = ex2.values[0];

              if (ex1.type !== ex2.type || ex1.value !== ex2.value)
                return false;

              // in case both stacktraces are undefined, we can't decide so default to false
              if (isBothUndefined(ex1.stacktrace, ex2.stacktrace)) return false;

              return isSameStacktrace(ex1.stacktrace, ex2.stacktrace);
            }

            /**
             * Returns true if the two input stack trace interfaces have the same content
             */
            function isSameStacktrace(stack1, stack2) {
              if (isOnlyOneTruthy(stack1, stack2)) return false;

              var frames1 = stack1.frames;
              var frames2 = stack2.frames;

              // Exit early if frame count differs
              if (frames1.length !== frames2.length) return false;

              // Iterate through every frame; bail out if anything differs
              var a, b;
              for (var i = 0; i < frames1.length; i++) {
                a = frames1[i];
                b = frames2[i];
                if (
                  a.filename !== b.filename ||
                  a.lineno !== b.lineno ||
                  a.colno !== b.colno ||
                  a["function"] !== b["function"]
                )
                  return false;
              }
              return true;
            }

            /**
             * Polyfill a method
             * @param obj object e.g. `document`
             * @param name method name present on object e.g. `addEventListener`
             * @param replacement replacement function
             * @param track {optional} record instrumentation to an array
             */
            function fill(obj, name, replacement, track) {
              if (obj == null) return;
              var orig = obj[name];
              obj[name] = replacement(orig);
              obj[name].__raven__ = true;
              obj[name].__orig__ = orig;
              if (track) {
                track.push([obj, name, orig]);
              }
            }

            /**
             * Join values in array
             * @param input array of values to be joined together
             * @param delimiter string to be placed in-between values
             * @returns {string}
             */
            function safeJoin(input, delimiter) {
              if (!isArray(input)) return "";

              var output = [];

              for (var i = 0; i < input.length; i++) {
                try {
                  output.push(String(input[i]));
                } catch (e) {
                  output.push("[value cannot be serialized]");
                }
              }

              return output.join(delimiter);
            }

            // Default Node.js REPL depth
            var MAX_SERIALIZE_EXCEPTION_DEPTH = 3;
            // 50kB, as 100kB is max payload size, so half sounds reasonable
            var MAX_SERIALIZE_EXCEPTION_SIZE = 50 * 1024;
            var MAX_SERIALIZE_KEYS_LENGTH = 40;

            function utf8Length(value) {
              return ~-encodeURI(value).split(/%..|./).length;
            }

            function jsonSize(value) {
              return utf8Length(JSON.stringify(value));
            }

            function serializeValue(value) {
              if (typeof value === "string") {
                var maxLength = 40;
                return truncate(value, maxLength);
              } else if (
                typeof value === "number" ||
                typeof value === "boolean" ||
                typeof value === "undefined"
              ) {
                return value;
              }

              var type = Object.prototype.toString.call(value);

              // Node.js REPL notation
              if (type === "[object Object]") return "[Object]";
              if (type === "[object Array]") return "[Array]";
              if (type === "[object Function]")
                return value.name
                  ? "[Function: " + value.name + "]"
                  : "[Function]";

              return value;
            }

            function serializeObject(value, depth) {
              if (depth === 0) return serializeValue(value);

              if (isPlainObject(value)) {
                return Object.keys(value).reduce(function (acc, key) {
                  acc[key] = serializeObject(value[key], depth - 1);
                  return acc;
                }, {});
              } else if (Array.isArray(value)) {
                return value.map(function (val) {
                  return serializeObject(val, depth - 1);
                });
              }

              return serializeValue(value);
            }

            function serializeException(ex, depth, maxSize) {
              if (!isPlainObject(ex)) return ex;

              depth =
                typeof depth !== "number"
                  ? MAX_SERIALIZE_EXCEPTION_DEPTH
                  : depth;
              maxSize =
                typeof depth !== "number"
                  ? MAX_SERIALIZE_EXCEPTION_SIZE
                  : maxSize;

              var serialized = serializeObject(ex, depth);

              if (jsonSize(stringify(serialized)) > maxSize) {
                return serializeException(ex, depth - 1);
              }

              return serialized;
            }

            function serializeKeysForMessage(keys, maxLength) {
              if (typeof keys === "number" || typeof keys === "string")
                return keys.toString();
              if (!Array.isArray(keys)) return "";

              keys = keys.filter(function (key) {
                return typeof key === "string";
              });
              if (keys.length === 0) return "[object has no keys]";

              maxLength =
                typeof maxLength !== "number"
                  ? MAX_SERIALIZE_KEYS_LENGTH
                  : maxLength;
              if (keys[0].length >= maxLength) return keys[0];

              for (var usedKeys = keys.length; usedKeys > 0; usedKeys--) {
                var serialized = keys.slice(0, usedKeys).join(", ");
                if (serialized.length > maxLength) continue;
                if (usedKeys === keys.length) return serialized;
                return serialized + "\u2026";
              }

              return "";
            }

            function sanitize(input, sanitizeKeys) {
              if (
                !isArray(sanitizeKeys) ||
                (isArray(sanitizeKeys) && sanitizeKeys.length === 0)
              )
                return input;

              var sanitizeRegExp = joinRegExp(sanitizeKeys);
              var sanitizeMask = "********";
              var safeInput;

              try {
                safeInput = JSON.parse(stringify(input));
              } catch (o_O) {
                return input;
              }

              function sanitizeWorker(workerInput) {
                if (isArray(workerInput)) {
                  return workerInput.map(function (val) {
                    return sanitizeWorker(val);
                  });
                }

                if (isPlainObject(workerInput)) {
                  return Object.keys(workerInput).reduce(function (acc, k) {
                    if (sanitizeRegExp.test(k)) {
                      acc[k] = sanitizeMask;
                    } else {
                      acc[k] = sanitizeWorker(workerInput[k]);
                    }
                    return acc;
                  }, {});
                }

                return workerInput;
              }

              return sanitizeWorker(safeInput);
            }

            module.exports = {
              isObject: isObject,
              isError: isError,
              isErrorEvent: isErrorEvent,
              isDOMError: isDOMError,
              isDOMException: isDOMException,
              isUndefined: isUndefined,
              isFunction: isFunction,
              isPlainObject: isPlainObject,
              isString: isString,
              isArray: isArray,
              isEmptyObject: isEmptyObject,
              supportsErrorEvent: supportsErrorEvent,
              supportsDOMError: supportsDOMError,
              supportsDOMException: supportsDOMException,
              supportsFetch: supportsFetch,
              supportsReferrerPolicy: supportsReferrerPolicy,
              supportsPromiseRejectionEvent: supportsPromiseRejectionEvent,
              wrappedCallback: wrappedCallback,
              each: each,
              objectMerge: objectMerge,
              truncate: truncate,
              objectFrozen: objectFrozen,
              hasKey: hasKey,
              joinRegExp: joinRegExp,
              urlencode: urlencode,
              uuid4: uuid4,
              htmlTreeAsString: htmlTreeAsString,
              htmlElementAsString: htmlElementAsString,
              isSameException: isSameException,
              isSameStacktrace: isSameStacktrace,
              parseUrl: parseUrl,
              fill: fill,
              safeJoin: safeJoin,
              serializeException: serializeException,
              serializeKeysForMessage: serializeKeysForMessage,
              sanitize: sanitize,
            };
          }).call(
            this,
            typeof global !== "undefined"
              ? global
              : typeof self !== "undefined"
                ? self
                : typeof window !== "undefined"
                  ? window
                  : {},
          );
        },
        { 7: 7 },
      ],
      6: [
        function (_dereq_, module, exports) {
          (function (global) {
            var utils = _dereq_(5);

            /*
   TraceKit - Cross brower stack traces
  
   This was originally forked from github.com/occ/TraceKit, but has since been
   largely re-written and is now maintained as part of raven-js.  Tests for
   this are in test/vendor.
  
   MIT license
  */

            var TraceKit = {
              collectWindowErrors: true,
              debug: false,
            };

            // This is to be defensive in environments where window does not exist (see https://github.com/getsentry/raven-js/pull/785)
            var _window =
              typeof window !== "undefined"
                ? window
                : typeof global !== "undefined"
                  ? global
                  : typeof self !== "undefined"
                    ? self
                    : {};

            // global reference to slice
            var _slice = [].slice;
            var UNKNOWN_FUNCTION = "?";

            // https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Error#Error_types
            var ERROR_TYPES_RE =
              /^(?:[Uu]ncaught (?:exception: )?)?(?:((?:Eval|Internal|Range|Reference|Syntax|Type|URI|)Error): )?(.*)$/;

            function getLocationHref() {
              if (typeof document === "undefined" || document.location == null)
                return "";
              return document.location.href;
            }

            function getLocationOrigin() {
              if (typeof document === "undefined" || document.location == null)
                return "";

              // Oh dear IE10...
              if (!document.location.origin) {
                document.location.origin =
                  document.location.protocol +
                  "//" +
                  document.location.hostname +
                  (document.location.port ? ":" + document.location.port : "");
              }

              return document.location.origin;
            }

            /**
             * TraceKit.report: cross-browser processing of unhandled exceptions
             *
             * Syntax:
             *   TraceKit.report.subscribe(function(stackInfo) { ... })
             *   TraceKit.report.unsubscribe(function(stackInfo) { ... })
             *   TraceKit.report(exception)
             *   try { ...code... } catch(ex) { TraceKit.report(ex); }
             *
             * Supports:
             *   - Firefox: full stack trace with line numbers, plus column number
             *              on top frame; column number is not guaranteed
             *   - Opera:   full stack trace with line and column numbers
             *   - Chrome:  full stack trace with line and column numbers
             *   - Safari:  line and column number for the top frame only; some frames
             *              may be missing, and column number is not guaranteed
             *   - IE:      line and column number for the top frame only; some frames
             *              may be missing, and column number is not guaranteed
             *
             * In theory, TraceKit should work on all of the following versions:
             *   - IE5.5+ (only 8.0 tested)
             *   - Firefox 0.9+ (only 3.5+ tested)
             *   - Opera 7+ (only 10.50 tested; versions 9 and earlier may require
             *     Exceptions Have Stacktrace to be enabled in opera:config)
             *   - Safari 3+ (only 4+ tested)
             *   - Chrome 1+ (only 5+ tested)
             *   - Konqueror 3.5+ (untested)
             *
             * Requires TraceKit.computeStackTrace.
             *
             * Tries to catch all unhandled exceptions and report them to the
             * subscribed handlers. Please note that TraceKit.report will rethrow the
             * exception. This is REQUIRED in order to get a useful stack trace in IE.
             * If the exception does not reach the top of the browser, you will only
             * get a stack trace from the point where TraceKit.report was called.
             *
             * Handlers receive a stackInfo object as described in the
             * TraceKit.computeStackTrace docs.
             */
            TraceKit.report = (function reportModuleWrapper() {
              var handlers = [],
                lastArgs = null,
                lastException = null,
                lastExceptionStack = null;

              /**
               * Add a crash handler.
               * @param {Function} handler
               */
              function subscribe(handler) {
                installGlobalHandler();
                handlers.push(handler);
              }

              /**
               * Remove a crash handler.
               * @param {Function} handler
               */
              function unsubscribe(handler) {
                for (var i = handlers.length - 1; i >= 0; --i) {
                  if (handlers[i] === handler) {
                    handlers.splice(i, 1);
                  }
                }
              }

              /**
               * Remove all crash handlers.
               */
              function unsubscribeAll() {
                uninstallGlobalHandler();
                handlers = [];
              }

              /**
               * Dispatch stack information to all handlers.
               * @param {Object.<string, *>} stack
               */
              function notifyHandlers(stack, isWindowError) {
                var exception = null;
                if (isWindowError && !TraceKit.collectWindowErrors) {
                  return;
                }
                for (var i in handlers) {
                  if (handlers.hasOwnProperty(i)) {
                    try {
                      handlers[i].apply(
                        null,
                        [stack].concat(_slice.call(arguments, 2)),
                      );
                    } catch (inner) {
                      exception = inner;
                    }
                  }
                }

                if (exception) {
                  throw exception;
                }
              }

              var _oldOnerrorHandler, _onErrorHandlerInstalled;

              /**
               * Ensures all global unhandled exceptions are recorded.
               * Supported by Gecko and IE.
               * @param {string} msg Error message.
               * @param {string} url URL of script that generated the exception.
               * @param {(number|string)} lineNo The line number at which the error
               * occurred.
               * @param {?(number|string)} colNo The column number at which the error
               * occurred.
               * @param {?Error} ex The actual Error object.
               */
              function traceKitWindowOnError(msg, url, lineNo, colNo, ex) {
                var stack = null;
                // If 'ex' is ErrorEvent, get real Error from inside
                var exception = utils.isErrorEvent(ex) ? ex.error : ex;
                // If 'msg' is ErrorEvent, get real message from inside
                var message = utils.isErrorEvent(msg) ? msg.message : msg;

                if (lastExceptionStack) {
                  TraceKit.computeStackTrace.augmentStackTraceWithInitialElement(
                    lastExceptionStack,
                    url,
                    lineNo,
                    message,
                  );
                  processLastException();
                } else if (exception && utils.isError(exception)) {
                  // non-string `exception` arg; attempt to extract stack trace

                  // New chrome and blink send along a real error object
                  // Let's just report that like a normal error.
                  // See: https://mikewest.org/2013/08/debugging-runtime-errors-with-window-onerror
                  stack = TraceKit.computeStackTrace(exception);
                  notifyHandlers(stack, true);
                } else {
                  var location = {
                    url: url,
                    line: lineNo,
                    column: colNo,
                  };

                  var name = undefined;
                  var groups;

                  if ({}.toString.call(message) === "[object String]") {
                    var groups = message.match(ERROR_TYPES_RE);
                    if (groups) {
                      name = groups[1];
                      message = groups[2];
                    }
                  }

                  location.func = UNKNOWN_FUNCTION;

                  stack = {
                    name: name,
                    message: message,
                    url: getLocationHref(),
                    stack: [location],
                  };
                  notifyHandlers(stack, true);
                }

                if (_oldOnerrorHandler) {
                  return _oldOnerrorHandler.apply(this, arguments);
                }

                return false;
              }

              function installGlobalHandler() {
                if (_onErrorHandlerInstalled) {
                  return;
                }
                _oldOnerrorHandler = _window.onerror;
                _window.onerror = traceKitWindowOnError;
                _onErrorHandlerInstalled = true;
              }

              function uninstallGlobalHandler() {
                if (!_onErrorHandlerInstalled) {
                  return;
                }
                _window.onerror = _oldOnerrorHandler;
                _onErrorHandlerInstalled = false;
                _oldOnerrorHandler = undefined;
              }

              function processLastException() {
                var _lastExceptionStack = lastExceptionStack,
                  _lastArgs = lastArgs;
                lastArgs = null;
                lastExceptionStack = null;
                lastException = null;
                notifyHandlers.apply(
                  null,
                  [_lastExceptionStack, false].concat(_lastArgs),
                );
              }

              /**
               * Reports an unhandled Error to TraceKit.
               * @param {Error} ex
               * @param {?boolean} rethrow If false, do not re-throw the exception.
               * Only used for window.onerror to not cause an infinite loop of
               * rethrowing.
               */
              function report(ex, rethrow) {
                var args = _slice.call(arguments, 1);
                if (lastExceptionStack) {
                  if (lastException === ex) {
                    return; // already caught by an inner catch block, ignore
                  } else {
                    processLastException();
                  }
                }

                var stack = TraceKit.computeStackTrace(ex);
                lastExceptionStack = stack;
                lastException = ex;
                lastArgs = args;

                // If the stack trace is incomplete, wait for 2 seconds for
                // slow slow IE to see if onerror occurs or not before reporting
                // this exception; otherwise, we will end up with an incomplete
                // stack trace
                setTimeout(
                  function () {
                    if (lastException === ex) {
                      processLastException();
                    }
                  },
                  stack.incomplete ? 2000 : 0,
                );

                if (rethrow !== false) {
                  throw ex; // re-throw to propagate to the top level (and cause window.onerror)
                }
              }

              report.subscribe = subscribe;
              report.unsubscribe = unsubscribe;
              report.uninstall = unsubscribeAll;
              return report;
            })();

            /**
             * TraceKit.computeStackTrace: cross-browser stack traces in JavaScript
             *
             * Syntax:
             *   s = TraceKit.computeStackTrace(exception) // consider using TraceKit.report instead (see below)
             * Returns:
             *   s.name              - exception name
             *   s.message           - exception message
             *   s.stack[i].url      - JavaScript or HTML file URL
             *   s.stack[i].func     - function name, or empty for anonymous functions (if guessing did not work)
             *   s.stack[i].args     - arguments passed to the function, if known
             *   s.stack[i].line     - line number, if known
             *   s.stack[i].column   - column number, if known
             *
             * Supports:
             *   - Firefox:  full stack trace with line numbers and unreliable column
             *               number on top frame
             *   - Opera 10: full stack trace with line and column numbers
             *   - Opera 9-: full stack trace with line numbers
             *   - Chrome:   full stack trace with line and column numbers
             *   - Safari:   line and column number for the topmost stacktrace element
             *               only
             *   - IE:       no line numbers whatsoever
             *
             * Tries to guess names of anonymous functions by looking for assignments
             * in the source code. In IE and Safari, we have to guess source file names
             * by searching for function bodies inside all page scripts. This will not
             * work for scripts that are loaded cross-domain.
             * Here be dragons: some function names may be guessed incorrectly, and
             * duplicate functions may be mismatched.
             *
             * TraceKit.computeStackTrace should only be used for tracing purposes.
             * Logging of unhandled exceptions should be done with TraceKit.report,
             * which builds on top of TraceKit.computeStackTrace and provides better
             * IE support by utilizing the window.onerror event to retrieve information
             * about the top of the stack.
             *
             * Note: In IE and Safari, no stack trace is recorded on the Error object,
             * so computeStackTrace instead walks its *own* chain of callers.
             * This means that:
             *  * in Safari, some methods may be missing from the stack trace;
             *  * in IE, the topmost function in the stack trace will always be the
             *    caller of computeStackTrace.
             *
             * This is okay for tracing (because you are likely to be calling
             * computeStackTrace from the function you want to be the topmost element
             * of the stack trace anyway), but not okay for logging unhandled
             * exceptions (because your catch block will likely be far away from the
             * inner function that actually caused the exception).
             *
             */
            TraceKit.computeStackTrace = (function computeStackTraceWrapper() {
              // Contents of Exception in various browsers.
              //
              // SAFARI:
              // ex.message = Can't find variable: qq
              // ex.line = 59
              // ex.sourceId = 580238192
              // ex.sourceURL = http://...
              // ex.expressionBeginOffset = 96
              // ex.expressionCaretOffset = 98
              // ex.expressionEndOffset = 98
              // ex.name = ReferenceError
              //
              // FIREFOX:
              // ex.message = qq is not defined
              // ex.fileName = http://...
              // ex.lineNumber = 59
              // ex.columnNumber = 69
              // ex.stack = ...stack trace... (see the example below)
              // ex.name = ReferenceError
              //
              // CHROME:
              // ex.message = qq is not defined
              // ex.name = ReferenceError
              // ex.type = not_defined
              // ex.arguments = ['aa']
              // ex.stack = ...stack trace...
              //
              // INTERNET EXPLORER:
              // ex.message = ...
              // ex.name = ReferenceError
              //
              // OPERA:
              // ex.message = ...message... (see the example below)
              // ex.name = ReferenceError
              // ex.opera#sourceloc = 11  (pretty much useless, duplicates the info in ex.message)
              // ex.stacktrace = n/a; see 'opera:config#UserPrefs|Exceptions Have Stacktrace'

              /**
               * Computes stack trace information from the stack property.
               * Chrome and Gecko use this property.
               * @param {Error} ex
               * @return {?Object.<string, *>} Stack trace information.
               */
              function computeStackTraceFromStackProp(ex) {
                if (typeof ex.stack === "undefined" || !ex.stack) return;

                var chrome =
                  /^\s*at (?:(.*?) ?\()?((?:file|https?|blob|chrome-extension|native|eval|webpack|<anonymous>|[a-z]:|\/).*?)(?::(\d+))?(?::(\d+))?\)?\s*$/i;
                var winjs =
                  /^\s*at (?:((?:\[object object\])?.+) )?\(?((?:file|ms-appx(?:-web)|https?|webpack|blob):.*?):(\d+)(?::(\d+))?\)?\s*$/i;
                // NOTE: blob urls are now supposed to always have an origin, therefore it's format
                // which is `blob:http://url/path/with-some-uuid`, is matched by `blob.*?:\/` as well
                var gecko =
                  /^\s*(.*?)(?:\((.*?)\))?(?:^|@)((?:file|https?|blob|chrome|webpack|resource|moz-extension).*?:\/.*?|\[native code\]|[^@]*bundle)(?::(\d+))?(?::(\d+))?\s*$/i;
                // Used to additionally parse URL/line/column from eval frames
                var geckoEval = /(\S+) line (\d+)(?: > eval line \d+)* > eval/i;
                var chromeEval = /\((\S*)(?::(\d+))(?::(\d+))\)/;
                var lines = ex.stack.split("\n");
                var stack = [];
                var submatch;
                var parts;
                var element;
                var reference = /^(.*) is undefined$/.exec(ex.message);

                for (var i = 0, j = lines.length; i < j; ++i) {
                  if ((parts = chrome.exec(lines[i]))) {
                    var isNative = parts[2] && parts[2].indexOf("native") === 0; // start of line
                    var isEval = parts[2] && parts[2].indexOf("eval") === 0; // start of line
                    if (isEval && (submatch = chromeEval.exec(parts[2]))) {
                      // throw out eval line/column and use top-most line/column number
                      parts[2] = submatch[1]; // url
                      parts[3] = submatch[2]; // line
                      parts[4] = submatch[3]; // column
                    }
                    element = {
                      url: !isNative ? parts[2] : null,
                      func: parts[1] || UNKNOWN_FUNCTION,
                      args: isNative ? [parts[2]] : [],
                      line: parts[3] ? +parts[3] : null,
                      column: parts[4] ? +parts[4] : null,
                    };
                  } else if ((parts = winjs.exec(lines[i]))) {
                    element = {
                      url: parts[2],
                      func: parts[1] || UNKNOWN_FUNCTION,
                      args: [],
                      line: +parts[3],
                      column: parts[4] ? +parts[4] : null,
                    };
                  } else if ((parts = gecko.exec(lines[i]))) {
                    var isEval = parts[3] && parts[3].indexOf(" > eval") > -1;
                    if (isEval && (submatch = geckoEval.exec(parts[3]))) {
                      // throw out eval line/column and use top-most line number
                      parts[3] = submatch[1];
                      parts[4] = submatch[2];
                      parts[5] = null; // no column when eval
                    } else if (
                      i === 0 &&
                      !parts[5] &&
                      typeof ex.columnNumber !== "undefined"
                    ) {
                      // FireFox uses this awesome columnNumber property for its top frame
                      // Also note, Firefox's column number is 0-based and everything else expects 1-based,
                      // so adding 1
                      // NOTE: this hack doesn't work if top-most frame is eval
                      stack[0].column = ex.columnNumber + 1;
                    }
                    element = {
                      url: parts[3],
                      func: parts[1] || UNKNOWN_FUNCTION,
                      args: parts[2] ? parts[2].split(",") : [],
                      line: parts[4] ? +parts[4] : null,
                      column: parts[5] ? +parts[5] : null,
                    };
                  } else {
                    continue;
                  }

                  if (!element.func && element.line) {
                    element.func = UNKNOWN_FUNCTION;
                  }

                  if (element.url && element.url.substr(0, 5) === "blob:") {
                    // Special case for handling JavaScript loaded into a blob.
                    // We use a synchronous AJAX request here as a blob is already in
                    // memory - it's not making a network request.  This will generate a warning
                    // in the browser console, but there has already been an error so that's not
                    // that much of an issue.
                    var xhr = new XMLHttpRequest();
                    xhr.open("GET", element.url, false);
                    xhr.send(null);

                    // If we failed to download the source, skip this patch
                    if (xhr.status === 200) {
                      var source = xhr.responseText || "";

                      // We trim the source down to the last 300 characters as sourceMappingURL is always at the end of the file.
                      // Why 300? To be in line with: https://github.com/getsentry/sentry/blob/4af29e8f2350e20c28a6933354e4f42437b4ba42/src/sentry/lang/javascript/processor.py#L164-L175
                      source = source.slice(-300);

                      // Now we dig out the source map URL
                      var sourceMaps = source.match(
                        /\/\/# sourceMappingURL=(.*)$/,
                      );

                      // If we don't find a source map comment or we find more than one, continue on to the next element.
                      if (sourceMaps) {
                        var sourceMapAddress = sourceMaps[1];

                        // Now we check to see if it's a relative URL.
                        // If it is, convert it to an absolute one.
                        if (sourceMapAddress.charAt(0) === "~") {
                          sourceMapAddress =
                            getLocationOrigin() + sourceMapAddress.slice(1);
                        }

                        // Now we strip the '.map' off of the end of the URL and update the
                        // element so that Sentry can match the map to the blob.
                        element.url = sourceMapAddress.slice(0, -4);
                      }
                    }
                  }

                  stack.push(element);
                }

                if (!stack.length) {
                  return null;
                }

                return {
                  name: ex.name,
                  message: ex.message,
                  url: getLocationHref(),
                  stack: stack,
                };
              }

              /**
               * Adds information about the first frame to incomplete stack traces.
               * Safari and IE require this to get complete data on the first frame.
               * @param {Object.<string, *>} stackInfo Stack trace information from
               * one of the compute* methods.
               * @param {string} url The URL of the script that caused an error.
               * @param {(number|string)} lineNo The line number of the script that
               * caused an error.
               * @param {string=} message The error generated by the browser, which
               * hopefully contains the name of the object that caused the error.
               * @return {boolean} Whether or not the stack information was
               * augmented.
               */
              function augmentStackTraceWithInitialElement(
                stackInfo,
                url,
                lineNo,
                message,
              ) {
                var initial = {
                  url: url,
                  line: lineNo,
                };

                if (initial.url && initial.line) {
                  stackInfo.incomplete = false;

                  if (!initial.func) {
                    initial.func = UNKNOWN_FUNCTION;
                  }

                  if (stackInfo.stack.length > 0) {
                    if (stackInfo.stack[0].url === initial.url) {
                      if (stackInfo.stack[0].line === initial.line) {
                        return false; // already in stack trace
                      } else if (
                        !stackInfo.stack[0].line &&
                        stackInfo.stack[0].func === initial.func
                      ) {
                        stackInfo.stack[0].line = initial.line;
                        return false;
                      }
                    }
                  }

                  stackInfo.stack.unshift(initial);
                  stackInfo.partial = true;
                  return true;
                } else {
                  stackInfo.incomplete = true;
                }

                return false;
              }

              /**
               * Computes stack trace information by walking the arguments.caller
               * chain at the time the exception occurred. This will cause earlier
               * frames to be missed but is the only way to get any stack trace in
               * Safari and IE. The top frame is restored by
               * {@link augmentStackTraceWithInitialElement}.
               * @param {Error} ex
               * @return {?Object.<string, *>} Stack trace information.
               */
              function computeStackTraceByWalkingCallerChain(ex, depth) {
                var functionName =
                    /function\s+([_$a-zA-Z\xA0-\uFFFF][_$a-zA-Z0-9\xA0-\uFFFF]*)?\s*\(/i,
                  stack = [],
                  funcs = {},
                  recursion = false,
                  parts,
                  item,
                  source;

                for (
                  var curr = computeStackTraceByWalkingCallerChain.caller;
                  curr && !recursion;
                  curr = curr.caller
                ) {
                  if (curr === computeStackTrace || curr === TraceKit.report) {
                    // console.log('skipping internal function');
                    continue;
                  }

                  item = {
                    url: null,
                    func: UNKNOWN_FUNCTION,
                    line: null,
                    column: null,
                  };

                  if (curr.name) {
                    item.func = curr.name;
                  } else if ((parts = functionName.exec(curr.toString()))) {
                    item.func = parts[1];
                  }

                  if (typeof item.func === "undefined") {
                    try {
                      item.func = parts.input.substring(
                        0,
                        parts.input.indexOf("{"),
                      );
                    } catch (e) {}
                  }

                  if (funcs["" + curr]) {
                    recursion = true;
                  } else {
                    funcs["" + curr] = true;
                  }

                  stack.push(item);
                }

                if (depth) {
                  // console.log('depth is ' + depth);
                  // console.log('stack is ' + stack.length);
                  stack.splice(0, depth);
                }

                var result = {
                  name: ex.name,
                  message: ex.message,
                  url: getLocationHref(),
                  stack: stack,
                };
                augmentStackTraceWithInitialElement(
                  result,
                  ex.sourceURL || ex.fileName,
                  ex.line || ex.lineNumber,
                  ex.message || ex.description,
                );
                return result;
              }

              /**
               * Computes a stack trace for an exception.
               * @param {Error} ex
               * @param {(string|number)=} depth
               */
              function computeStackTrace(ex, depth) {
                var stack = null;
                depth = depth == null ? 0 : +depth;

                try {
                  stack = computeStackTraceFromStackProp(ex);
                  if (stack) {
                    return stack;
                  }
                } catch (e) {
                  if (TraceKit.debug) {
                    throw e;
                  }
                }

                try {
                  stack = computeStackTraceByWalkingCallerChain(ex, depth + 1);
                  if (stack) {
                    return stack;
                  }
                } catch (e) {
                  if (TraceKit.debug) {
                    throw e;
                  }
                }
                return {
                  name: ex.name,
                  message: ex.message,
                  url: getLocationHref(),
                };
              }

              computeStackTrace.augmentStackTraceWithInitialElement =
                augmentStackTraceWithInitialElement;
              computeStackTrace.computeStackTraceFromStackProp =
                computeStackTraceFromStackProp;

              return computeStackTrace;
            })();

            module.exports = TraceKit;
          }).call(
            this,
            typeof global !== "undefined"
              ? global
              : typeof self !== "undefined"
                ? self
                : typeof window !== "undefined"
                  ? window
                  : {},
          );
        },
        { 5: 5 },
      ],
      7: [
        function (_dereq_, module, exports) {
          /*
   json-stringify-safe
   Like JSON.stringify, but doesn't throw on circular references.
  
   Originally forked from https://github.com/isaacs/json-stringify-safe
   version 5.0.1 on 3/8/2017 and modified to handle Errors serialization
   and IE8 compatibility. Tests for this are in test/vendor.
  
   ISC license: https://github.com/isaacs/json-stringify-safe/blob/master/LICENSE
  */

          exports = module.exports = stringify;
          exports.getSerialize = serializer;

          function indexOf(haystack, needle) {
            for (var i = 0; i < haystack.length; ++i) {
              if (haystack[i] === needle) return i;
            }
            return -1;
          }

          function stringify(obj, replacer, spaces, cycleReplacer) {
            return JSON.stringify(
              obj,
              serializer(replacer, cycleReplacer),
              spaces,
            );
          }

          // https://github.com/ftlabs/js-abbreviate/blob/fa709e5f139e7770a71827b1893f22418097fbda/index.js#L95-L106
          function stringifyError(value) {
            var err = {
              // These properties are implemented as magical getters and don't show up in for in
              stack: value.stack,
              message: value.message,
              name: value.name,
            };

            for (var i in value) {
              if (Object.prototype.hasOwnProperty.call(value, i)) {
                err[i] = value[i];
              }
            }

            return err;
          }

          function serializer(replacer, cycleReplacer) {
            var stack = [];
            var keys = [];

            if (cycleReplacer == null) {
              cycleReplacer = function (key, value) {
                if (stack[0] === value) {
                  return "[Circular ~]";
                }
                return (
                  "[Circular ~." +
                  keys.slice(0, indexOf(stack, value)).join(".") +
                  "]"
                );
              };
            }

            return function (key, value) {
              if (stack.length > 0) {
                var thisPos = indexOf(stack, this);
                ~thisPos ? stack.splice(thisPos + 1) : stack.push(this);
                ~thisPos ? keys.splice(thisPos, Infinity, key) : keys.push(key);

                if (~indexOf(stack, value)) {
                  value = cycleReplacer.call(this, key, value);
                }
              } else {
                stack.push(value);
              }

              return replacer == null
                ? value instanceof Error
                  ? stringifyError(value)
                  : value
                : replacer.call(this, key, value);
            };
          }
        },
        {},
      ],
      8: [
        function (_dereq_, module, exports) {
          /*
           * JavaScript MD5
           * https://github.com/blueimp/JavaScript-MD5
           *
           * Copyright 2011, Sebastian Tschan
           * https://blueimp.net
           *
           * Licensed under the MIT license:
           * https://opensource.org/licenses/MIT
           *
           * Based on
           * A JavaScript implementation of the RSA Data Security, Inc. MD5 Message
           * Digest Algorithm, as defined in RFC 1321.
           * Version 2.2 Copyright (C) Paul Johnston 1999 - 2009
           * Other contributors: Greg Holt, Andrew Kepert, Ydnar, Lostinet
           * Distributed under the BSD License
           * See http://pajhome.org.uk/crypt/md5 for more info.
           */

          /*
           * Add integers, wrapping at 2^32. This uses 16-bit operations internally
           * to work around bugs in some JS interpreters.
           */
          function safeAdd(x, y) {
            var lsw = (x & 0xffff) + (y & 0xffff);
            var msw = (x >> 16) + (y >> 16) + (lsw >> 16);
            return (msw << 16) | (lsw & 0xffff);
          }

          /*
           * Bitwise rotate a 32-bit number to the left.
           */
          function bitRotateLeft(num, cnt) {
            return (num << cnt) | (num >>> (32 - cnt));
          }

          /*
           * These functions implement the four basic operations the algorithm uses.
           */
          function md5cmn(q, a, b, x, s, t) {
            return safeAdd(
              bitRotateLeft(safeAdd(safeAdd(a, q), safeAdd(x, t)), s),
              b,
            );
          }
          function md5ff(a, b, c, d, x, s, t) {
            return md5cmn((b & c) | (~b & d), a, b, x, s, t);
          }
          function md5gg(a, b, c, d, x, s, t) {
            return md5cmn((b & d) | (c & ~d), a, b, x, s, t);
          }
          function md5hh(a, b, c, d, x, s, t) {
            return md5cmn(b ^ c ^ d, a, b, x, s, t);
          }
          function md5ii(a, b, c, d, x, s, t) {
            return md5cmn(c ^ (b | ~d), a, b, x, s, t);
          }

          /*
           * Calculate the MD5 of an array of little-endian words, and a bit length.
           */
          function binlMD5(x, len) {
            /* append padding */
            x[len >> 5] |= 0x80 << len % 32;
            x[(((len + 64) >>> 9) << 4) + 14] = len;

            var i;
            var olda;
            var oldb;
            var oldc;
            var oldd;
            var a = 1732584193;
            var b = -271733879;
            var c = -1732584194;
            var d = 271733878;

            for (i = 0; i < x.length; i += 16) {
              olda = a;
              oldb = b;
              oldc = c;
              oldd = d;

              a = md5ff(a, b, c, d, x[i], 7, -680876936);
              d = md5ff(d, a, b, c, x[i + 1], 12, -389564586);
              c = md5ff(c, d, a, b, x[i + 2], 17, 606105819);
              b = md5ff(b, c, d, a, x[i + 3], 22, -1044525330);
              a = md5ff(a, b, c, d, x[i + 4], 7, -176418897);
              d = md5ff(d, a, b, c, x[i + 5], 12, 1200080426);
              c = md5ff(c, d, a, b, x[i + 6], 17, -1473231341);
              b = md5ff(b, c, d, a, x[i + 7], 22, -45705983);
              a = md5ff(a, b, c, d, x[i + 8], 7, 1770035416);
              d = md5ff(d, a, b, c, x[i + 9], 12, -1958414417);
              c = md5ff(c, d, a, b, x[i + 10], 17, -42063);
              b = md5ff(b, c, d, a, x[i + 11], 22, -1990404162);
              a = md5ff(a, b, c, d, x[i + 12], 7, 1804603682);
              d = md5ff(d, a, b, c, x[i + 13], 12, -40341101);
              c = md5ff(c, d, a, b, x[i + 14], 17, -1502002290);
              b = md5ff(b, c, d, a, x[i + 15], 22, 1236535329);

              a = md5gg(a, b, c, d, x[i + 1], 5, -165796510);
              d = md5gg(d, a, b, c, x[i + 6], 9, -1069501632);
              c = md5gg(c, d, a, b, x[i + 11], 14, 643717713);
              b = md5gg(b, c, d, a, x[i], 20, -373897302);
              a = md5gg(a, b, c, d, x[i + 5], 5, -701558691);
              d = md5gg(d, a, b, c, x[i + 10], 9, 38016083);
              c = md5gg(c, d, a, b, x[i + 15], 14, -660478335);
              b = md5gg(b, c, d, a, x[i + 4], 20, -405537848);
              a = md5gg(a, b, c, d, x[i + 9], 5, 568446438);
              d = md5gg(d, a, b, c, x[i + 14], 9, -1019803690);
              c = md5gg(c, d, a, b, x[i + 3], 14, -187363961);
              b = md5gg(b, c, d, a, x[i + 8], 20, 1163531501);
              a = md5gg(a, b, c, d, x[i + 13], 5, -1444681467);
              d = md5gg(d, a, b, c, x[i + 2], 9, -51403784);
              c = md5gg(c, d, a, b, x[i + 7], 14, 1735328473);
              b = md5gg(b, c, d, a, x[i + 12], 20, -1926607734);

              a = md5hh(a, b, c, d, x[i + 5], 4, -378558);
              d = md5hh(d, a, b, c, x[i + 8], 11, -2022574463);
              c = md5hh(c, d, a, b, x[i + 11], 16, 1839030562);
              b = md5hh(b, c, d, a, x[i + 14], 23, -35309556);
              a = md5hh(a, b, c, d, x[i + 1], 4, -1530992060);
              d = md5hh(d, a, b, c, x[i + 4], 11, 1272893353);
              c = md5hh(c, d, a, b, x[i + 7], 16, -155497632);
              b = md5hh(b, c, d, a, x[i + 10], 23, -1094730640);
              a = md5hh(a, b, c, d, x[i + 13], 4, 681279174);
              d = md5hh(d, a, b, c, x[i], 11, -358537222);
              c = md5hh(c, d, a, b, x[i + 3], 16, -722521979);
              b = md5hh(b, c, d, a, x[i + 6], 23, 76029189);
              a = md5hh(a, b, c, d, x[i + 9], 4, -640364487);
              d = md5hh(d, a, b, c, x[i + 12], 11, -421815835);
              c = md5hh(c, d, a, b, x[i + 15], 16, 530742520);
              b = md5hh(b, c, d, a, x[i + 2], 23, -995338651);

              a = md5ii(a, b, c, d, x[i], 6, -198630844);
              d = md5ii(d, a, b, c, x[i + 7], 10, 1126891415);
              c = md5ii(c, d, a, b, x[i + 14], 15, -1416354905);
              b = md5ii(b, c, d, a, x[i + 5], 21, -57434055);
              a = md5ii(a, b, c, d, x[i + 12], 6, 1700485571);
              d = md5ii(d, a, b, c, x[i + 3], 10, -1894986606);
              c = md5ii(c, d, a, b, x[i + 10], 15, -1051523);
              b = md5ii(b, c, d, a, x[i + 1], 21, -2054922799);
              a = md5ii(a, b, c, d, x[i + 8], 6, 1873313359);
              d = md5ii(d, a, b, c, x[i + 15], 10, -30611744);
              c = md5ii(c, d, a, b, x[i + 6], 15, -1560198380);
              b = md5ii(b, c, d, a, x[i + 13], 21, 1309151649);
              a = md5ii(a, b, c, d, x[i + 4], 6, -145523070);
              d = md5ii(d, a, b, c, x[i + 11], 10, -1120210379);
              c = md5ii(c, d, a, b, x[i + 2], 15, 718787259);
              b = md5ii(b, c, d, a, x[i + 9], 21, -343485551);

              a = safeAdd(a, olda);
              b = safeAdd(b, oldb);
              c = safeAdd(c, oldc);
              d = safeAdd(d, oldd);
            }
            return [a, b, c, d];
          }

          /*
           * Convert an array of little-endian words to a string
           */
          function binl2rstr(input) {
            var i;
            var output = "";
            var length32 = input.length * 32;
            for (i = 0; i < length32; i += 8) {
              output += String.fromCharCode((input[i >> 5] >>> i % 32) & 0xff);
            }
            return output;
          }

          /*
           * Convert a raw string to an array of little-endian words
           * Characters >255 have their high-byte silently ignored.
           */
          function rstr2binl(input) {
            var i;
            var output = [];
            output[(input.length >> 2) - 1] = undefined;
            for (i = 0; i < output.length; i += 1) {
              output[i] = 0;
            }
            var length8 = input.length * 8;
            for (i = 0; i < length8; i += 8) {
              output[i >> 5] |= (input.charCodeAt(i / 8) & 0xff) << i % 32;
            }
            return output;
          }

          /*
           * Calculate the MD5 of a raw string
           */
          function rstrMD5(s) {
            return binl2rstr(binlMD5(rstr2binl(s), s.length * 8));
          }

          /*
           * Calculate the HMAC-MD5, of a key and some data (raw strings)
           */
          function rstrHMACMD5(key, data) {
            var i;
            var bkey = rstr2binl(key);
            var ipad = [];
            var opad = [];
            var hash;
            ipad[15] = opad[15] = undefined;
            if (bkey.length > 16) {
              bkey = binlMD5(bkey, key.length * 8);
            }
            for (i = 0; i < 16; i += 1) {
              ipad[i] = bkey[i] ^ 0x36363636;
              opad[i] = bkey[i] ^ 0x5c5c5c5c;
            }
            hash = binlMD5(ipad.concat(rstr2binl(data)), 512 + data.length * 8);
            return binl2rstr(binlMD5(opad.concat(hash), 512 + 128));
          }

          /*
           * Convert a raw string to a hex string
           */
          function rstr2hex(input) {
            var hexTab = "0123456789abcdef";
            var output = "";
            var x;
            var i;
            for (i = 0; i < input.length; i += 1) {
              x = input.charCodeAt(i);
              output +=
                hexTab.charAt((x >>> 4) & 0x0f) + hexTab.charAt(x & 0x0f);
            }
            return output;
          }

          /*
           * Encode a string as utf-8
           */
          function str2rstrUTF8(input) {
            return unescape(encodeURIComponent(input));
          }

          /*
           * Take string arguments and return either raw or hex encoded strings
           */
          function rawMD5(s) {
            return rstrMD5(str2rstrUTF8(s));
          }
          function hexMD5(s) {
            return rstr2hex(rawMD5(s));
          }
          function rawHMACMD5(k, d) {
            return rstrHMACMD5(str2rstrUTF8(k), str2rstrUTF8(d));
          }
          function hexHMACMD5(k, d) {
            return rstr2hex(rawHMACMD5(k, d));
          }

          function md5(string, key, raw) {
            if (!key) {
              if (!raw) {
                return hexMD5(string);
              }
              return rawMD5(string);
            }
            if (!raw) {
              return hexHMACMD5(key, string);
            }
            return rawHMACMD5(key, string);
          }

          module.exports = md5;
        },
        {},
      ],
    },
    {},
    [4],
  )(4);
});
