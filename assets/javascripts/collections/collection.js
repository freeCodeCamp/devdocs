// @ts-check

import { Model } from "../models/model.js";

/**
 * An ordered list of models.
 *
 * Subclasses return the model class they hold from `model()`, and declare
 * which model that is with `@extends`. It is a method rather than a field so
 * that a collection and its model can import each other.
 *
 * @template {Model} [T=Model]
 */
export class Collection {
  /** @param {unknown[]} [objects] Models, attribute objects, or other collections. */
  constructor(objects) {
    if (objects == null) {
      objects = [];
    }
    this.reset(objects);
  }

  /**
   * The model class this collection holds. Implemented by the subclass.
   *
   * @returns {new (attributes?: Record<string, unknown>) => T}
   */
  model() {
    throw new Error(`${this.constructor.name} doesn't declare a model`);
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
    if (object instanceof Model) {
      this.models.push(object);
    } else if (object instanceof Array) {
      for (var obj of object) {
        this.add(obj);
      }
    } else if (object instanceof Collection) {
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
