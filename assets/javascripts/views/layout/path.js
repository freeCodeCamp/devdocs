// @ts-check

/**
 * The breadcrumb above the content. Rebuilt on every route, and hidden on
 * pages that aren't part of a doc.
 */
class Path extends app.View {
  static className = "_path";
  static attributes = { role: "complementary" };

  static events = { click: "onClick" };

  static routes = { after: "afterRoute" };

  /** @param {...unknown} args The doc, then optionally the type and the entry. */
  render(...args) {
    this.html(this.tmpl("path", ...args));
    this.show();
  }

  /** Puts the breadcrumb above the content, if it isn't there already. */
  show() {
    if (!this.el.parentNode) {
      this.prependTo(app.el);
    }
  }

  /** Takes it off the page. */
  hide() {
    if (this.el.parentNode) {
      $.remove(this.el);
    }
  }

  /**
   * Notes that the next route came from the breadcrumb, so that the sidebar
   * can be reset to match.
   *
   * @param {ViewMouseEvent} event
   */
  onClick(event) {
    const link = $.closestLink(event.target, this.el);
    if (link) {
      this.clicked = true;
    }
  }

  /**
   * @param {string} route
   * @param {Context} context
   */
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
}

// Registered on `app` so that the rest of the code can reach it; declared at
// the top level so that it can be named in a type.
app.views.Path = Path;
