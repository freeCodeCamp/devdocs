// TODO: This file was created by bulk-decaffeinate.
// Sanity-check the conversion and remove this comment.
/*
 * decaffeinate suggestions:
 * DS002: Fix invalid constructor
 * DS102: Remove unnecessary code created because of implicit returns
 * DS206: Consider reworking classes to avoid initClass
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/main/docs/suggestions.md
 */
const Cls = (app.views.ListFold = class ListFold extends app.View {
  static initClass() {
    this.targetClass = '_list-dir';
    this.handleClass = '_list-arrow';
    this.activeClass = 'open';
  
    this.events =
      {click: 'onClick'};
  
    this.shortcuts = {
      left:   'onLeft',
      right:  'onRight'
    };
  }

  constructor(el) { this.onLeft = this.onLeft.bind(this);   this.onRight = this.onRight.bind(this);   this.onClick = this.onClick.bind(this);   this.el = el; super(...arguments); }

  open(el) {
    if (el && !el.classList.contains(this.constructor.activeClass)) {
      el.classList.add(this.constructor.activeClass);
      $.trigger(el, 'open');
    }
  }

  close(el) {
    if (el && el.classList.contains(this.constructor.activeClass)) {
      el.classList.remove(this.constructor.activeClass);
      $.trigger(el, 'close');
    }
  }

  toggle(el) {
    if (el.classList.contains(this.constructor.activeClass)) {
      this.close(el);
    } else {
      this.open(el);
    }
  }

  reset() {
    let el;
    while ((el = this.findByClass(this.constructor.activeClass))) {
      this.close(el);
    }
  }

  getCursor() {
    return this.findByClass(app.views.ListFocus.activeClass) || this.findByClass(app.views.ListSelect.activeClass);
  }

  onLeft() {
    const cursor = this.getCursor();
    if (cursor != null ? cursor.classList.contains(this.constructor.activeClass) : undefined) {
      this.close(cursor);
    }
  }

  onRight() {
    const cursor = this.getCursor();
    if (cursor != null ? cursor.classList.contains(this.constructor.targetClass) : undefined) {
      this.open(cursor);
    }
  }

  onClick(event) {
    if ((event.which !== 1) || event.metaKey || event.ctrlKey) { return; }
    if (!event.pageY) { return; } // ignore fabricated clicks
    let el = $.eventTarget(event);
    if (el.parentNode.tagName.toUpperCase() === 'SVG') { el = el.parentNode; }

    if (el.classList.contains(this.constructor.handleClass)) {
      $.stopEvent(event);
      this.toggle(el.parentNode);
    } else if (el.classList.contains(this.constructor.targetClass)) {
      if (el.hasAttribute('href')) {
        if (el.classList.contains(this.constructor.activeClass)) {
          if (el.classList.contains(app.views.ListSelect.activeClass)) { this.close(el); }
        } else {
          this.open(el);
        }
      } else {
        this.toggle(el);
      }
    }
  }
});
Cls.initClass();
