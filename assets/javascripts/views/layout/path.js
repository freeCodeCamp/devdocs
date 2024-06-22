app.views.Path = class Path extends app.View {
  static className = "_path";
  static attributes = { role: "complementary" };

  static events = { click: "onClick" };

  static routes = { after: "afterRoute" };

  render(...args) {
    this.html(this.tmpl("path", ...args));
    this.show();
  }

  show() {
    if (!this.el.parentNode) {
      this.prependTo(app.el);
    }
  }

  hide() {
    if (this.el.parentNode) {
      $.remove(this.el);
    }
  }

  onClick(event) {
    let link;
    if ((link = $.closestLink(event.target, this.el))) {
      this.clicked = true;
    }
  }

  afterRoute(route, context) {
    if (context.type) {
      this.render(context.doc, context.type);
    } else if (context.entry) {
      if (context.entry.isIndex()) {
        this.render(context.doc);
      } else {
        this.render(context.doc, context.entry.getType(), context.entry);
      }
    } else {
      this.hide();
    }

    if (this.clicked) {
      this.clicked = null;
      app.document.sidebar.reset();
    }
  }
};
