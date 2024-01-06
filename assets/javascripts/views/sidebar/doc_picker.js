app.views.DocPicker = class DocPicker extends app.View {
  static className = "_list _list-picker";

  static events = {
    mousedown: "onMouseDown",
    mouseup: "onMouseUp",
  };

  init() {
    this.addSubview((this.listFold = new app.views.ListFold(this.el)));
  }

  activate() {
    if (super.activate(...arguments)) {
      this.render();
      this.onDOMFocus = this.onDOMFocus.bind(this);
      $.on(this.el, "focus", this.onDOMFocus, true);
    }
  }

  deactivate() {
    if (super.deactivate(...arguments)) {
      this.empty();
      $.off(this.el, "focus", this.onDOMFocus, true);
      this.focusEl = null;
    }
  }

  render() {
    let doc;
    let html = this.tmpl("docPickerHeader");
    let docs = app.docs.all().concat(...(app.disabledDocs.all() || []));

    while ((doc = docs.shift())) {
      if (doc.version != null) {
        var versions;
        [docs, versions] = this.extractVersions(docs, doc);
        html += this.tmpl(
          "sidebarVersionedDoc",
          doc,
          this.renderVersions(versions),
          { open: app.docs.contains(doc) },
        );
      } else {
        html += this.tmpl("sidebarLabel", doc, {
          checked: app.docs.contains(doc),
        });
      }
    }

    this.html(html + this.tmpl("docPickerNote"));

    requestAnimationFrame(() => this.findByTag("input")?.focus());
  }

  renderVersions(docs) {
    let html = "";
    for (var doc of docs) {
      html += this.tmpl("sidebarLabel", doc, {
        checked: app.docs.contains(doc),
      });
    }
    return html;
  }

  extractVersions(originalDocs, version) {
    const docs = [];
    const versions = [version];
    for (var doc of originalDocs) {
      (doc.name === version.name ? versions : docs).push(doc);
    }
    return [docs, versions];
  }

  empty() {
    this.resetClass();
    super.empty(...arguments);
  }

  getSelectedDocs() {
    return [...this.findAllByTag("input")]
      .filter((input) => input?.checked)
      .map((input) => input.name);
  }

  onMouseDown() {
    this.mouseDown = Date.now();
  }

  onMouseUp() {
    this.mouseUp = Date.now();
  }

  onDOMFocus(event) {
    const { target } = event;
    if (target.tagName === "INPUT") {
      if (
        (!this.mouseDown || !(Date.now() < this.mouseDown + 100)) &&
        (!this.mouseUp || !(Date.now() < this.mouseUp + 100))
      ) {
        $.scrollTo(target.parentNode, null, "continuous");
      }
    } else if (target.classList.contains(app.views.ListFold.targetClass)) {
      target.blur();
      if (!this.mouseDown || !(Date.now() < this.mouseDown + 100)) {
        if (this.focusEl === $("input", target.nextElementSibling)) {
          if (target.classList.contains(app.views.ListFold.activeClass)) {
            this.listFold.close(target);
          }
          let prev = target.previousElementSibling;
          while (
            prev.tagName !== "LABEL" &&
            !prev.classList.contains(app.views.ListFold.targetClass)
          ) {
            prev = prev.previousElementSibling;
          }
          if (prev.classList.contains(app.views.ListFold.activeClass)) {
            prev = $.makeArray($$("input", prev.nextElementSibling)).pop();
          }
          this.delay(() => prev.focus());
        } else {
          if (!target.classList.contains(app.views.ListFold.activeClass)) {
            this.listFold.open(target);
          }
          this.delay(() => $("input", target.nextElementSibling).focus());
        }
      }
    }
    this.focusEl = target;
  }
};
