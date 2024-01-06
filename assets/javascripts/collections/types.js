// TODO: This file was created by bulk-decaffeinate.
// Sanity-check the conversion and remove this comment.
/*
 * decaffeinate suggestions:
 * DS101: Remove unnecessary use of Array.from
 * DS102: Remove unnecessary code created because of implicit returns
 * DS104: Avoid inline assignments
 * DS206: Consider reworking classes to avoid initClass
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/main/docs/suggestions.md
 */
(function() {
  let GUIDES_RGX = undefined;
  let APPENDIX_RGX = undefined;
  const Cls = (app.collections.Types = class Types extends app.Collection {
    static initClass() {
      this.model = 'Type';
  
      GUIDES_RGX = /(^|\()(guides?|tutorials?|reference|book|getting\ started|manual|examples)($|[\):])/i;
      APPENDIX_RGX = /appendix/i;
    }

    groups() {
      const result = [];
      for (var type of Array.from(this.models)) {
        var name;
        (result[name = this._groupFor(type)] || (result[name] = [])).push(type);
      }
      return result.filter(e => e.length > 0);
    }

    _groupFor(type) {
      if (GUIDES_RGX.test(type.name)) {
        return 0;
      } else if (APPENDIX_RGX.test(type.name)) {
        return 2;
      } else {
        return 1;
      }
    }
  });
  Cls.initClass();
  return Cls;
})();
