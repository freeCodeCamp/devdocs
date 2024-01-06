app.Shortcuts = class Shortcuts extends Events {
  constructor() {
    super();
    this.onKeydown = this.onKeydown.bind(this);
    this.onKeypress = this.onKeypress.bind(this);
    this.isMac = $.isMac();
    this.start();
  }

  start() {
    $.on(document, "keydown", this.onKeydown);
    $.on(document, "keypress", this.onKeypress);
  }

  stop() {
    $.off(document, "keydown", this.onKeydown);
    $.off(document, "keypress", this.onKeypress);
  }

  swapArrowKeysBehavior() {
    return app.settings.get("arrowScroll");
  }

  spaceScroll() {
    return app.settings.get("spaceScroll");
  }

  showTip() {
    app.showTip("KeyNav");
    return (this.showTip = null);
  }

  spaceTimeout() {
    return app.settings.get("spaceTimeout");
  }

  onKeydown(event) {
    if (this.buggyEvent(event)) {
      return;
    }
    const result = (() => {
      if (event.ctrlKey || event.metaKey) {
        if (!event.altKey && !event.shiftKey) {
          return this.handleKeydownSuperEvent(event);
        }
      } else if (event.shiftKey) {
        if (!event.altKey) {
          return this.handleKeydownShiftEvent(event);
        }
      } else if (event.altKey) {
        return this.handleKeydownAltEvent(event);
      } else {
        return this.handleKeydownEvent(event);
      }
    })();

    if (result === false) {
      event.preventDefault();
    }
  }

  onKeypress(event) {
    if (
      this.buggyEvent(event) ||
      (event.charCode === 63 && document.activeElement.tagName === "INPUT")
    ) {
      return;
    }
    if (!event.ctrlKey && !event.metaKey) {
      const result = this.handleKeypressEvent(event);
      if (result === false) {
        event.preventDefault();
      }
    }
  }

  handleKeydownEvent(event, _force) {
    if (
      !_force &&
      [37, 38, 39, 40].includes(event.which) &&
      this.swapArrowKeysBehavior()
    ) {
      return this.handleKeydownAltEvent(event, true);
    }

    if (
      !event.target.form &&
      ((48 <= event.which && event.which <= 57) ||
        (65 <= event.which && event.which <= 90))
    ) {
      this.trigger("typing");
      return;
    }

    switch (event.which) {
      case 8:
        if (!event.target.form) {
          return this.trigger("typing");
        }
        break;
      case 13:
        return this.trigger("enter");
      case 27:
        this.trigger("escape");
        return false;
      case 32:
        if (
          event.target.type === "search" &&
          this.spaceScroll() &&
          (!this.lastKeypress ||
            this.lastKeypress < Date.now() - this.spaceTimeout() * 1000)
        ) {
          this.trigger("pageDown");
          return false;
        }
        break;
      case 33:
        return this.trigger("pageUp");
      case 34:
        return this.trigger("pageDown");
      case 35:
        if (!event.target.form) {
          return this.trigger("pageBottom");
        }
        break;
      case 36:
        if (!event.target.form) {
          return this.trigger("pageTop");
        }
        break;
      case 37:
        if (!event.target.value) {
          return this.trigger("left");
        }
        break;
      case 38:
        this.trigger("up");
        if (typeof this.showTip === "function") {
          this.showTip();
        }
        return false;
      case 39:
        if (!event.target.value) {
          return this.trigger("right");
        }
        break;
      case 40:
        this.trigger("down");
        if (typeof this.showTip === "function") {
          this.showTip();
        }
        return false;
      case 191:
        if (!event.target.form) {
          this.trigger("typing");
          return false;
        }
        break;
    }
  }

  handleKeydownSuperEvent(event) {
    switch (event.which) {
      case 13:
        return this.trigger("superEnter");
      case 37:
        if (this.isMac) {
          this.trigger("superLeft");
          return false;
        }
        break;
      case 38:
        this.trigger("pageTop");
        return false;
      case 39:
        if (this.isMac) {
          this.trigger("superRight");
          return false;
        }
        break;
      case 40:
        this.trigger("pageBottom");
        return false;
      case 188:
        this.trigger("preferences");
        return false;
    }
  }

  handleKeydownShiftEvent(event, _force) {
    if (
      !_force &&
      [37, 38, 39, 40].includes(event.which) &&
      this.swapArrowKeysBehavior()
    ) {
      return this.handleKeydownEvent(event, true);
    }

    if (!event.target.form && 65 <= event.which && event.which <= 90) {
      this.trigger("typing");
      return;
    }

    switch (event.which) {
      case 32:
        this.trigger("pageUp");
        return false;
      case 38:
        if (!getSelection()?.toString()) {
          this.trigger("altUp");
          return false;
        }
        break;
      case 40:
        if (!getSelection()?.toString()) {
          this.trigger("altDown");
          return false;
        }
        break;
    }
  }

  handleKeydownAltEvent(event, _force) {
    if (
      !_force &&
      [37, 38, 39, 40].includes(event.which) &&
      this.swapArrowKeysBehavior()
    ) {
      return this.handleKeydownEvent(event, true);
    }

    switch (event.which) {
      case 9:
        return this.trigger("altRight", event);
      case 37:
        if (!this.isMac) {
          this.trigger("superLeft");
          return false;
        }
        break;
      case 38:
        this.trigger("altUp");
        return false;
      case 39:
        if (!this.isMac) {
          this.trigger("superRight");
          return false;
        }
        break;
      case 40:
        this.trigger("altDown");
        return false;
      case 67:
        this.trigger("altC");
        return false;
      case 68:
        this.trigger("altD");
        return false;
      case 70:
        return this.trigger("altF", event);
      case 71:
        this.trigger("altG");
        return false;
      case 79:
        this.trigger("altO");
        return false;
      case 82:
        this.trigger("altR");
        return false;
      case 83:
        this.trigger("altS");
        return false;
    }
  }

  handleKeypressEvent(event) {
    if (event.which === 63 && !event.target.value) {
      this.trigger("help");
      return false;
    } else {
      return (this.lastKeypress = Date.now());
    }
  }

  buggyEvent(event) {
    try {
      event.target;
      event.ctrlKey;
      event.which;
      return false;
    } catch (error) {
      return true;
    }
  }
};
