app.views.TypeList = class TypeList extends app.View {
  static tagName = "div";
  static className = "_list _list-sub";

  static events = {
    open: "onOpen",
    close: "onClose",
  };

  constructor(doc) {
    super();
    this.doc = doc;
    this.init0(); // needs this.doc
    this.refreshElements();
  }

  init0() {
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
    for (var group of this.doc.types.groups()) {
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
      this.lists[model.getType().slug]?.paginateTo(model);
    }
  }
};
