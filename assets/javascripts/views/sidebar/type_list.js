// TODO: This file was created by bulk-decaffeinate.
// Sanity-check the conversion and remove this comment.
/*
 * decaffeinate suggestions:
 * DS002: Fix invalid constructor
 * DS101: Remove unnecessary use of Array.from
 * DS102: Remove unnecessary code created because of implicit returns
 * DS103: Rewrite code to no longer use __guard__, or convert again using --optional-chaining
 * DS206: Consider reworking classes to avoid initClass
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/main/docs/suggestions.md
 */
app.views.TypeList = class TypeList extends app.View {
  static initClass() {
    this.tagName = "div";
    this.className = "_list _list-sub";

    this.events = {
      open: "onOpen",
      close: "onClose",
    };
  }

  constructor(doc) {
    this.onOpen = this.onOpen.bind(this);
    this.onClose = this.onClose.bind(this);
    this.doc = doc;
    super(...arguments);
  }

  init() {
    this.lists = {};
    this.render();
    this.activate();
  }

  activate() {
    if (super.activate(...arguments)) {
      for (var slug in this.lists) {
        var list = this.lists[slug];
        list.activate();
      }
    }
  }

  deactivate() {
    if (super.deactivate(...arguments)) {
      for (var slug in this.lists) {
        var list = this.lists[slug];
        list.deactivate();
      }
    }
  }

  render() {
    let html = "";
    for (var group of Array.from(this.doc.types.groups())) {
      html += this.tmpl("sidebarType", group);
    }
    return this.html(html);
  }

  onOpen(event) {
    $.stopEvent(event);
    const type = this.doc.types.findBy(
      "slug",
      event.target.getAttribute("data-slug"),
    );

    if (type && !this.lists[type.slug]) {
      this.lists[type.slug] = new app.views.EntryList(type.entries());
      $.after(event.target, this.lists[type.slug].el);
    }
  }

  onClose(event) {
    $.stopEvent(event);
    const type = this.doc.types.findBy(
      "slug",
      event.target.getAttribute("data-slug"),
    );

    if (type && this.lists[type.slug]) {
      this.lists[type.slug].detach();
      delete this.lists[type.slug];
    }
  }

  paginateTo(model) {
    if (model.type) {
      __guard__(this.lists[model.getType().slug], (x) => x.paginateTo(model));
    }
  }
};
app.views.TypeList.initClass();

function __guard__(value, transform) {
  return typeof value !== "undefined" && value !== null
    ? transform(value)
    : undefined;
}
