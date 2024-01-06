/*
 * decaffeinate suggestions:
 * DS101: Remove unnecessary use of Array.from
 * DS102: Remove unnecessary code created because of implicit returns
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/main/docs/suggestions.md
 */
app.Collection = class Collection {
  constructor(objects) {
    if (objects == null) { objects = []; }
    this.reset(objects);
  }

  model() {
    return app.models[this.constructor.model];
  }

  reset(objects) {
    if (objects == null) { objects = []; }
    this.models = [];
    for (var object of Array.from(objects)) { this.add(object); }
  }

  add(object) {
    if (object instanceof app.Model) {
      this.models.push(object);
    } else if (object instanceof Array) {
      for (var obj of Array.from(object)) { this.add(obj); }
    } else if (object instanceof app.Collection) {
      this.models.push(...Array.from(object.all() || []));
    } else {
      this.models.push(new (this.model())(object));
    }
  }

  remove(model) {
    this.models.splice(this.models.indexOf(model), 1);
  }

  size() {
    return this.models.length;
  }

  isEmpty() {
    return this.models.length === 0;
  }

  each(fn) {
    for (var model of Array.from(this.models)) { fn(model); }
  }

  all() {
    return this.models;
  }

  contains(model) {
    return this.models.indexOf(model) >= 0;
  }

  findBy(attr, value) {
    for (var model of Array.from(this.models)) {
      if (model[attr] === value) { return model; }
    }
  }

  findAllBy(attr, value) {
    return Array.from(this.models).filter((model) => model[attr] === value);
  }

  countAllBy(attr, value) {
    let i = 0;
    for (var model of Array.from(this.models)) { if (model[attr] === value) { i += 1; } }
    return i;
  }
};
