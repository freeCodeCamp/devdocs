// TODO: This file was created by bulk-decaffeinate.
// Sanity-check the conversion and remove this comment.
/*
 * decaffeinate suggestions:
 * DS002: Fix invalid constructor
 * DS101: Remove unnecessary use of Array.from
 * DS102: Remove unnecessary code created because of implicit returns
 * DS103: Rewrite code to no longer use __guard__, or convert again using --optional-chaining
 * DS206: Consider reworking classes to avoid initClass
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/main/docs/suggestions.md
 */
const Cls = (app.views.DocPicker = class DocPicker extends app.View {
  constructor(...args) {
    this.onMouseDown = this.onMouseDown.bind(this);
    this.onMouseUp = this.onMouseUp.bind(this);
    this.onDOMFocus = this.onDOMFocus.bind(this);
    super(...args);
  }

  static initClass() {
    this.className = '_list _list-picker';
  
    this.events = {
      mousedown: 'onMouseDown',
      mouseup: 'onMouseUp'
    };
  }

  init() {
    this.addSubview(this.listFold = new app.views.ListFold(this.el));
  }

  activate() {
    if (super.activate(...arguments)) {
      this.render();
      $.on(this.el, 'focus', this.onDOMFocus, true);
    }
  }

  deactivate() {
    if (super.deactivate(...arguments)) {
      this.empty();
      $.off(this.el, 'focus', this.onDOMFocus, true);
      this.focusEl = null;
    }
  }

  render() {
    let doc;
    let html = this.tmpl('docPickerHeader');
    let docs = app.docs.all().concat(...Array.from(app.disabledDocs.all() || []));

    while ((doc = docs.shift())) {
      if (doc.version != null) {
        var versions;
        [docs, versions] = Array.from(this.extractVersions(docs, doc));
        html += this.tmpl('sidebarVersionedDoc', doc, this.renderVersions(versions), {open: app.docs.contains(doc)});
      } else {
        html += this.tmpl('sidebarLabel', doc, {checked: app.docs.contains(doc)});
      }
    }

    this.html(html + this.tmpl('docPickerNote'));

    $.requestAnimationFrame(() => __guard__(this.findByTag('input'), x => x.focus()));
  }

  renderVersions(docs) {
    let html = '';
    for (var doc of Array.from(docs)) { html += this.tmpl('sidebarLabel', doc, {checked: app.docs.contains(doc)}); }
    return html;
  }

  extractVersions(originalDocs, version) {
    const docs = [];
    const versions = [version];
    for (var doc of Array.from(originalDocs)) {
      (doc.name === version.name ? versions : docs).push(doc);
    }
    return [docs, versions];
  }

  empty() {
    this.resetClass();
    super.empty(...arguments);
  }

  getSelectedDocs() {
    return Array.from(this.findAllByTag('input')).filter((input) => (input != null ? input.checked : undefined)).map((input) =>
      input.name);
  }

  onMouseDown() {
    this.mouseDown = Date.now();
  }

  onMouseUp() {
    this.mouseUp = Date.now();
  }

  onDOMFocus(event) {
    const {
      target
    } = event;
    if (target.tagName === 'INPUT') {
      if ((!this.mouseDown || !(Date.now() < (this.mouseDown + 100))) && (!this.mouseUp || !(Date.now() < (this.mouseUp + 100)))) {
        $.scrollTo(target.parentNode, null, 'continuous');
      }
    } else if (target.classList.contains(app.views.ListFold.targetClass)) {
      target.blur();
      if (!this.mouseDown || !(Date.now() < (this.mouseDown + 100))) {
        if (this.focusEl === $('input', target.nextElementSibling)) {
          if (target.classList.contains(app.views.ListFold.activeClass)) { this.listFold.close(target); }
          let prev = target.previousElementSibling;
          while ((prev.tagName !== 'LABEL') && !prev.classList.contains(app.views.ListFold.targetClass)) { prev = prev.previousElementSibling; }
          if (prev.classList.contains(app.views.ListFold.activeClass)) { prev = $.makeArray($$('input', prev.nextElementSibling)).pop(); }
          this.delay(() => prev.focus());
        } else {
          if (!target.classList.contains(app.views.ListFold.activeClass)) { this.listFold.open(target); }
          this.delay(() => $('input', target.nextElementSibling).focus());
        }
      }
    }
    this.focusEl = target;
  }
});
Cls.initClass();

function __guard__(value, transform) {
  return (typeof value !== 'undefined' && value !== null) ? transform(value) : undefined;
}