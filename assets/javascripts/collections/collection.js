app.Collection = class Collection {
  constructor(objects) {
    if (objects == null) {
      objects = [];
    }
    this.reset(objects);
  }

  model() {
    return app.models[this.constructor.model];
  }

  reset(objects) {
    if (objects == null) {
      objects = [];
    }
    this.models = [];
    for (var object of objects) {
      this.add(object);
    }
  }

  add(object) {
    if (object instanceof app.Model) {
      this.models.push(object);
    } else if (object instanceof Array) {
      for (var obj of object) {
        this.add(obj);
      }
    } else if (object instanceof app.Collection) {
      this.models.push(...(object.all() || []));
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
    for (var model of this.models) {
      fn(model);
    }
  }

  all() {
    return this.models;
  }

  contains(model) {
    return this.models.includes(model);
  }

  findBy(attr, value) {
    return this.models.find((model) => model[attr] === value);
  }

  findAllBy(attr, value) {
    return this.models.filter((model) => model[attr] === value);
  }

  countAllBy(attr, value) {
    let i = 0;
    for (var model of this.models) {
      if (model[attr] === value) {
        i += 1;
      }
    }
    return i;
  }
};
