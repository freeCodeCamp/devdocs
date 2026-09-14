// @ts-check

/**
 * The handle between the sidebar and the content.
 *
 * Dragged with the HTML5 drag-and-drop API, which is why the width is only
 * saved on `dragend`; `dragover` fires far too often to write to storage, so
 * the live resize is throttled to one animation frame.
 */
class Resizer extends app.View {
  static className = "_resizer";

  static events = {
    dragstart: "onDragStart",
    dragend: "onDragEnd",
  };

  static MIN = 260;
  static MAX = 600;

  /** @returns {boolean} Whether the browser supports dragging and isn't a phone. */
  static isSupported() {
    return "ondragstart" in document.createElement("div") && !app.isMobile();
  }

  /** @inheritdoc */
  init() {
    this.el.setAttribute("draggable", "true");
    this.appendTo($("._app"));
  }

  /**
   * @param {number} value The sidebar's new width, as a page coordinate.
   *   Clamped between `MIN` and `MAX`.
   * @param {boolean} save Whether to remember the width.
   */
  resize(value, save) {
    value -= app.el.offsetLeft;
    if (!(value > 0)) {
      return;
    }
    value = Math.min(Math.max(Math.round(value), Resizer.MIN), Resizer.MAX);
    const newSize = `${value}px`;
    document.documentElement.style.setProperty("--sidebarWidth", newSize);
    if (save) {
      app.settings.setSize(value);
    }
  }

  /** @param {DragEvent} event */
  onDragStart(event) {
    event.dataTransfer.effectAllowed = "link";
    event.dataTransfer.setData("Text", "");
    this.onDrag = this.onDrag.bind(this);
    $.on(window, "dragover", this.onDrag);
  }

  /** @param {DragEvent} event */
  onDrag(event) {
    const value = event.pageX;
    if (!(value > 0)) {
      return;
    }
    this.lastDragValue = value;
    if (this.rafPending) {
      return;
    }
    this.rafPending = requestAnimationFrame(() => {
      this.rafPending = null;
      this.resize(this.lastDragValue, false);
    });
  }

  /** @param {DragEvent} event */
  onDragEnd(event) {
    if (this.rafPending) {
      cancelAnimationFrame(this.rafPending);
      this.rafPending = null;
    }
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
}

// Registered on `app` so that the rest of the code can reach it; declared at
// the top level so that it can be named in a type.
app.views.Resizer = Resizer;
