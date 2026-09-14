// @ts-check

/** The types within one doc, e.g. "Methods" or "Guides". *
 * @extends {Collection<Type>}
 */
class Types extends Collection {
  static model = "Type";
  static GUIDES_RGX =
    /(^|\()(guides?|tutorials?|reference|book|getting\ started|manual|examples)($|[\):])/i;
  static APPENDIX_RGX = /appendix/i;

  /**
   * Splits the types into guides, regular types and appendices, in that
   * order, dropping any group that ends up empty.
   *
   * @returns {unknown[][]}
   */
  groups() {
    const result = [];
    for (var type of this.models) {
      const name = this._groupFor(type);
      result[name] ||= [];
      result[name].push(type);
    }
    return result.filter((e) => e.length > 0);
  }

  /**
   * @param {Type} type
   * @returns {number} The index of the group the type belongs in.
   */
  _groupFor(type) {
    if (Types.GUIDES_RGX.test(type.name)) {
      return 0;
    } else if (Types.APPENDIX_RGX.test(type.name)) {
      return 2;
    } else {
      return 1;
    }
  }
}

// Registered on `app` so that the rest of the code can reach it; declared at
// the top level so that it can be named in a type.
app.collections.Types = Types;
