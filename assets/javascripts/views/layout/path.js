// TODO: This file was created by bulk-decaffeinate.
// Sanity-check the conversion and remove this comment.
/*
 * decaffeinate suggestions:
 * DS002: Fix invalid constructor
 * DS101: Remove unnecessary use of Array.from
 * DS206: Consider reworking classes to avoid initClass
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/main/docs/suggestions.md
 */
const Cls = (app.views.Path = class Path extends app.View {
  constructor(...args) {
    this.onClick = this.onClick.bind(this);
    this.afterRoute = this.afterRoute.bind(this);
    super(...args);
  }

  static initClass() {
    this.className = '_path';
    this.attributes =
      {role: 'complementary'};
  
    this.events =
      {click: 'onClick'};
  
    this.routes =
      {after: 'afterRoute'};
  }

  render(...args) {
    this.html(this.tmpl('path', ...Array.from(args)));
    this.show();
  }

  show() {
    if (!this.el.parentNode) { this.prependTo(app.el); }
  }

  hide() {
    if (this.el.parentNode) { $.remove(this.el); }
  }

  onClick(event) {
    let link;
    if (link = $.closestLink(event.target, this.el)) { this.clicked = true; }
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
});
Cls.initClass();
