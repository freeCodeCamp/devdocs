app.collections.Types = class Types extends app.Collection {
  static model = "Type";
  static GUIDES_RGX =
    /(^|\()(guides?|tutorials?|reference|book|getting\ started|manual|examples)($|[\):])/i;
  static APPENDIX_RGX = /appendix/i;

  groups() {
    const result = [];
    for (var type of this.models) {
      const name = this._groupFor(type);
      result[name] ||= [];
      result[name].push(type);
    }
    return result.filter((e) => e.length > 0);
  }

  _groupFor(type) {
    if (Types.GUIDES_RGX.test(type.name)) {
      return 0;
    } else if (Types.APPENDIX_RGX.test(type.name)) {
      return 2;
    } else {
      return 1;
    }
  }
};
