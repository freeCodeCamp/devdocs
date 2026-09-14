// @ts-check

/**
 * An ordered list of models.
 *
 * Subclasses name the model they hold with a static `model` property, which is
 * looked up in `app.models` so that the collection doesn't have to reference
 * the class directly, and declare which model that is with `@extends`.
 *
 * @template {Model} [T=Model]
 */
class Collection {
  /** @param {unknown[]} [objects] Models, attribute objects, or other collections. */
  constructor(objects) {
    if (objects == null) {
      objects = [];
    }
    this.reset(objects);
  }

  /**
   * The model class this collection holds.
   *
   * @returns {new (attributes?: Record<string, unknown>) => T}
   */
  model() {
    const { model } = /** @type {{ model: keyof App["models"] }} */ (
      /** @type {unknown} */ (this.constructor)
    );
    return /** @type {new (attributes?: Record<string, unknown>) => T} */ (
      /** @type {unknown} */ (app.models[model])
    );
  }

  /**
   * Replaces the contents.
   *
   * @param {unknown[]} [objects]
   */
  reset(objects) {
    if (objects == null) {
      objects = [];
    }
    /** @type {T[]} */
    this.models = [];
    for (var object of objects) {
      this.add(/** @type {T} */ (object));
    }
  }

  /**
   * Appends a model, an array of them, another collection's models, or an
   * attribute object to build a model from.
   *
   * @param {T | T[] | Collection<T> | Record<string, unknown>} object
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
   * @param {T} model
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
   * @param {(model: T) => void} fn
   */
  each(fn) {
    for (var model of this.models) {
      fn(model);
    }
  }

  /**
   * The underlying array, not a copy.
   *
   * @returns {T[]}
   */
  all() {
    return this.models;
  }

  /**
   * @param {T} model
   * @returns {boolean}
   */
  contains(model) {
    return this.models.includes(model);
  }

  /**
   * @param {string} attr
   * @param {unknown} value
   * @returns {T | undefined}
   */
  findBy(attr, value) {
    return this.models.find((model) => model[attr] === value);
  }

  /**
   * @param {string} attr
   * @param {unknown} value
   * @returns {T[]}
   */
  findAllBy(attr, value) {
    return this.models.filter((model) => model[attr] === value);
  }

  /**
   * @param {string} attr
   * @param {unknown} value
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
}

// Registered on `app` so that the rest of the code can reach it; declared at
// the top level so that subclasses extend a type rather than `any`.
app.Collection = Collection;
