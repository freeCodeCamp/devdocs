app.Model = class Model {
  constructor(attributes) {
    for (var key in attributes) {
      var value = attributes[key];
      this[key] = value;
    }
  }
};
