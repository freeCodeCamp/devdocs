// @ts-check

/**
 * The base model: copies the attributes it is handed onto itself.
 *
 * Attributes vary by subclass and aren't known ahead of time, so subclasses
 * document the ones they rely on rather than declaring them as fields — a
 * field declaration would run after `super()` and blank the value out.
 */
class Model {
  /** @param {Record<string, any>} [attributes] */
  constructor(attributes) {
    for (var key in attributes) {
      var value = attributes[key];
      this[key] = value;
    }
  }
}

// Registered on `app` so that the rest of the code can reach it; declared at
// the top level so that subclasses extend a type rather than `any`.
app.Model = Model;
