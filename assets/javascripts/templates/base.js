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
