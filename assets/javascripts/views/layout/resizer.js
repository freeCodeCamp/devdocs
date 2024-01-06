// TODO: This file was created by bulk-decaffeinate.
// Sanity-check the conversion and remove this comment.
/*
 * decaffeinate suggestions:
 * DS002: Fix invalid constructor
 * DS102: Remove unnecessary code created because of implicit returns
 * DS206: Consider reworking classes to avoid initClass
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/main/docs/suggestions.md
 */
(function () {
  let MIN = undefined;
  let MAX = undefined;
  const Cls = (app.views.Resizer = class Resizer extends app.View {
    constructor(...args) {
      this.onDragStart = this.onDragStart.bind(this);
      this.onDrag = this.onDrag.bind(this);
      this.onDragEnd = this.onDragEnd.bind(this);
      super(...args);
    }

    static initClass() {
      this.className = "_resizer";

      this.events = {
        dragstart: "onDragStart",
        dragend: "onDragEnd",
      };

      MIN = 260;
      MAX = 600;
    }

    static isSupported() {
      return "ondragstart" in document.createElement("div") && !app.isMobile();
    }

    init() {
      this.el.setAttribute("draggable", "true");
      this.appendTo($("._app"));
    }

    resize(value, save) {
      value -= app.el.offsetLeft;
      if (!(value > 0)) {
        return;
      }
      value = Math.min(Math.max(Math.round(value), MIN), MAX);
      const newSize = `${value}px`;
      document.documentElement.style.setProperty("--sidebarWidth", newSize);
      if (save) {
        app.settings.setSize(value);
      }
    }

    onDragStart(event) {
      event.dataTransfer.effectAllowed = "link";
      event.dataTransfer.setData("Text", "");
      $.on(window, "dragover", this.onDrag);
    }

    onDrag(event) {
      const value = event.pageX;
      if (!(value > 0)) {
        return;
      }
      this.lastDragValue = value;
      if (this.lastDrag && this.lastDrag > Date.now() - 50) {
        return;
      }
      this.lastDrag = Date.now();
      this.resize(value, false);
    }

    onDragEnd(event) {
      $.off(window, "dragover", this.onDrag);
      let value = event.pageX || event.screenX - window.screenX;
      if (
        this.lastDragValue &&
        !(this.lastDragValue - 5 < value && value < this.lastDragValue + 5)
      ) {
        // https://github.com/freeCodeCamp/devdocs/issues/265
        value = this.lastDragValue;
      }
      this.resize(value, true);
    }
  });
  Cls.initClass();
  return Cls;
})();
