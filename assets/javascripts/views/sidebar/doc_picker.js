// @ts-check

import { app } from "../../app/app.js";
import { $, $$ } from "../../lib/util.js";
import { ListFold } from "../list/list_fold.js";
import { View } from "../view.js";
/** @import { Doc } from "../../models/doc.js" */

/**
 * The checklist of every available doc, shown in the preferences.
 *
 * Docs that come in several versions are grouped under one expandable row.
 */
export class DocPicker extends View {
  static className = "_list _list-picker";

  static events = {
    mousedown: "onMouseDown",
    mouseup: "onMouseUp",
  };

  /** @inheritdoc */
  init() {
    this.addSubview((this.listFold = new ListFold(this.el)));
  }

  /** Also renders the list and starts tracking the focus. */
  activate() {
    if (super.activate()) {
      this.render();
      this.onDOMFocus = this.onDOMFocus.bind(this);
      $.on(this.el, "focus", this.onDOMFocus, true);
    }
  }

  /** Also empties the list and stops tracking the focus. */
  deactivate() {
    if (super.deactivate()) {
      this.empty();
      $.off(this.el, "focus", this.onDOMFocus, true);
      this.focusEl = null;
    }
  }

  /** Rebuilds the list and puts the focus on the first checkbox. */
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

  /**
   * @param {Doc[]} docs Every version of one doc.
   * @returns {string}
   */
  renderVersions(docs) {
    let html = "";
    for (var doc of docs) {
      html += this.tmpl("sidebarLabel", doc, {
        checked: app.docs.contains(doc),
      });
    }
    return html;
  }

  /**
   * Pulls the other versions of a doc out of the list, so that they can be
   * grouped under it.
   *
   * @param {Doc[]} originalDocs The docs still to be rendered.
   * @param {Doc} version The doc whose siblings to collect.
   * @returns {[Doc[], Doc[]]} What is left to render, and the versions found.
   */
  extractVersions(originalDocs, version) {
    const docs = [];
    const versions = [version];
    for (var doc of originalDocs) {
      (doc.name === version.name ? versions : docs).push(doc);
    }
    return [docs, versions];
  }

  /** Also collapses every expanded doc. */
  empty() {
    this.resetClass();
    super.empty();
  }

  /** @returns {string[]} The slugs the user has ticked. */
  getSelectedDocs() {
    return [
      .../** @type {HTMLCollectionOf<HTMLInputElement>} */ (
        this.findAllByTag("input")
      ),
    ]
      .filter((input) => input?.checked)
      .map((input) => input.name);
  }

  /** Notes that the pointer is driving, so the focus isn't stolen. */
  onMouseDown() {
    this.mouseDown = Date.now();
  }

  /** Clears the flag set by `onMouseDown`. */
  onMouseUp() {
    this.mouseUp = Date.now();
  }

  /** @param {ViewEvent} event */
  onDOMFocus(event) {
    const { target } = event;
    if (target.tagName === "INPUT") {
      if (
        (!this.mouseDown || !(Date.now() < this.mouseDown + 100)) &&
        (!this.mouseUp || !(Date.now() < this.mouseUp + 100))
      ) {
        $.scrollTo(target.parentElement, null, "continuous");
      }
    } else if (target.classList.contains(ListFold.targetClass)) {
      target.blur();
      if (!this.mouseDown || !(Date.now() < this.mouseDown + 100)) {
        if (this.focusEl === $("input", target.nextElementSibling)) {
          if (target.classList.contains(ListFold.activeClass)) {
            this.listFold.close(target);
          }
          let prev = target.previousElementSibling;
          while (
            prev.tagName !== "LABEL" &&
            !prev.classList.contains(ListFold.targetClass)
          ) {
            prev = prev.previousElementSibling;
          }
          if (prev.classList.contains(ListFold.activeClass)) {
            prev = $.makeArray($$("input", prev.nextElementSibling)).pop();
          }
          this.delay(() => /** @type {HTMLElement} */ (prev).focus());
        } else {
          if (!target.classList.contains(ListFold.activeClass)) {
            this.listFold.open(target);
          }
          this.delay(() => $("input", target.nextElementSibling).focus());
        }
      }
    }
    this.focusEl = target;
  }
}
