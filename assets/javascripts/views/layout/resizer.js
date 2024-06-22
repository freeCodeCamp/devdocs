app.views.Resizer = class Resizer extends app.View {
  static className = "_resizer";

  static events = {
    dragstart: "onDragStart",
    dragend: "onDragEnd",
  };

  static MIN = 260;
  static MAX = 600;

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
    value = Math.min(Math.max(Math.round(value), Resizer.MIN), Resizer.MAX);
    const newSize = `${value}px`;
    document.documentElement.style.setProperty("--sidebarWidth", newSize);
    if (save) {
      app.settings.setSize(value);
    }
  }

  onDragStart(event) {
    event.dataTransfer.effectAllowed = "link";
    event.dataTransfer.setData("Text", "");
    this.onDrag = this.onDrag.bind(this);
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
};
