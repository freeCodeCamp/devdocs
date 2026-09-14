// @ts-check

/**
 * Renders a template by name.
 *
 * Templates are either functions or plain strings. Passing an array renders
 * the template once per element and concatenates the results, which is how
 * lists are built.
 *
 * @param {string} name The key under `app.templates`.
 * @param {any} [value] The template's first argument, or an array of them.
 * @param {...any} args Passed on after `value`.
 * @returns {string} The rendered HTML.
 */
app.templates.render = function (name, value, ...args) {
  const template = app.templates[name];

  if (Array.isArray(value)) {
    let result = "";
    for (var val of value) {
      result += template(val, ...args);
    }
    return result;
  } else if (typeof template === "function") {
    return template(value, ...args);
  } else {
    return template;
  }
};
