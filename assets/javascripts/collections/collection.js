// @ts-check

/**
 * An ordered list of models.
 *
 * Subclasses name the model they hold with a static `model` property, which is
 * looked up in `app.models` so that the collection doesn't have to reference
 * the class directly.
 */
app.Collection = class Collection {
  /** @param {any[]} [objects] Models, attribute objects, or other collections. */
  constructor(objects) {
    if (objects == null) {
      objects = [];
    }
    this.reset(objects);
  }

  /**
   * The model class this collection holds.
   *
   * @returns {any}
   */
  model() {
    return app.models[/** @type {any} */ (this.constructor).model];
  }

  /**
   * Replaces the contents.
   *
   * @param {any[]} [objects]
   */
  reset(objects) {
    if (objects == null) {
      objects = [];
    }
    /** @type {any[]} */
    this.models = [];
    for (var object of objects) {
      this.add(object);
    }
  }

  /**
   * Appends a model, an array of them, another collection's models, or an
   * attribute object to build a model from.
   *
   * @param {any} object
   */
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

  /**
   * @param {any} model
   */
  remove(model) {
    this.models.splice(this.models.indexOf(model), 1);
  }

  /** @returns {number} */
  size() {
    return this.models.length;
  }

  /** @returns {boolean} */
  isEmpty() {
    return this.models.length === 0;
  }

  /**
   * @param {(model: any) => void} fn
   */
  each(fn) {
    for (var model of this.models) {
      fn(model);
    }
  }

  /**
   * The underlying array, not a copy.
   *
   * @returns {any[]}
   */
  all() {
    return this.models;
  }

  /**
   * @param {any} model
   * @returns {boolean}
   */
  contains(model) {
    return this.models.includes(model);
  }

  /**
   * @param {string} attr
   * @param {any} value
   * @returns {any} The first match, or `undefined`.
   */
  findBy(attr, value) {
    return this.models.find((model) => model[attr] === value);
  }

  /**
   * @param {string} attr
   * @param {any} value
   * @returns {any[]}
   */
  findAllBy(attr, value) {
    return this.models.filter((model) => model[attr] === value);
  }

  /**
   * @param {string} attr
   * @param {any} value
   * @returns {number}
   */
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
