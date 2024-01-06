/*
 * decaffeinate suggestions:
 * DS101: Remove unnecessary use of Array.from
 * DS102: Remove unnecessary code created because of implicit returns
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/main/docs/suggestions.md
 */
app.templates.render = function(name, value, ...args) {
  const template = app.templates[name];

  if (Array.isArray(value)) {
    let result = '';
    for (var val of Array.from(value)) { result += template(val, ...Array.from(args)); }
    return result;
  } else if (typeof template === 'function') {
    return template(value, ...Array.from(args));
  } else {
    return template;
  }
};
