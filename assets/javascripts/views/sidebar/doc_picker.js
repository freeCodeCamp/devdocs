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
 * The header filters the list by name, and its checkbox ticks or clears
 * every doc the filter shows.
 */
export class DocPicker extends View {
  static className = "_list _list-picker";

  static events = {
    change: "onChange",
    input: "onInput",
    keydown: "onKeydown",
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
    this.updateAllCheckbox();

    requestAnimationFrame(() => this.findByClass("_list-checkbox")?.focus());
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

  /** @returns {HTMLInputElement[]} The checkbox of every doc. */
  getCheckboxes() {
    return [
      .../** @type {HTMLCollectionOf<HTMLInputElement>} */ (
        this.findAllByClass("_list-checkbox")
      ),
    ];
  }

  /** @returns {HTMLInputElement[]} The checkbox of every doc the filter shows. */
  getShownCheckboxes() {
    return this.getCheckboxes().filter(
      (input) => !input.closest("[hidden]"),
    );
  }

  /**
   * Hides the docs whose name doesn't contain the query.
   *
   * @param {string} query
   */
  filter(query) {
    query = query.trim().toLowerCase();
    for (const el of /** @type {HTMLElement[]} */ ([...this.el.children])) {
      if (el.tagName === "LABEL" || el.classList.contains("_list-rdir")) {
        el.hidden = !el.textContent.toLowerCase().includes(query);
      } else if (el.classList.contains("_list-sub")) {
        el.hidden = /** @type {HTMLElement} */ (el.previousElementSibling).hidden;
      }
    }
    this.updateAllCheckbox();
  }

  /** @returns {string[]} The slugs the user has ticked. */
  getSelectedDocs() {
    return this.getCheckboxes()
      .filter((input) => input.checked)
      .map((input) => input.name);
  }

  /**
   * Ticks the header checkbox when every doc shown is, and half-ticks it when
   * some are.
   */
  updateAllCheckbox() {
    const all = /** @type {HTMLInputElement} */ (
      this.findByClass("_list-picker-all")
    );
    const shown = this.getShownCheckboxes();
    const checked = shown.filter((input) => input.checked);
    all.checked = shown.length > 0 && checked.length === shown.length;
    all.indeterminate = !all.checked && checked.length > 0;
  }

  /** @param {ViewInputEvent} event */
  onChange(event) {
    const input = event.target;
    if (input.classList.contains("_list-picker-filter")) {
      event.stopPropagation(); // filtering changes no preference
    } else if (input.classList.contains("_list-picker-all")) {
      for (const checkbox of this.getShownCheckboxes()) {
        checkbox.checked = input.checked;
      }
    } else {
      this.updateAllCheckbox();
    }
  }

  /** @param {ViewInputEvent} event */
  onInput(event) {
    if (event.target.classList.contains("_list-picker-filter")) {
      this.filter(event.target.value);
    }
  }

  /**
   * Keeps Enter in the filter from saving the preferences.
   *
   * @param {ViewKeyboardEvent} event
   */
  onKeydown(event) {
    if (
      event.key === "Enter" &&
      event.target.classList.contains("_list-picker-filter")
    ) {
      $.stopEvent(event);
    }
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
