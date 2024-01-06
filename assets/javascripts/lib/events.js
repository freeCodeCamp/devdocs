class Events {
  on(event, callback) {
    if (event.includes(" ")) {
      for (var name of event.split(" ")) {
        this.on(name, callback);
      }
    } else {
      this._callbacks ||= {};
      this._callbacks[event] ||= [];
      this._callbacks[event].push(callback);
    }
    return this;
  }

  off(event, callback) {
    let callbacks, index;
    if (event.includes(" ")) {
      for (var name of event.split(" ")) {
        this.off(name, callback);
      }
    } else if (
      (callbacks = this._callbacks?.[event]) &&
      (index = callbacks.indexOf(callback)) >= 0
    ) {
      callbacks.splice(index, 1);
      if (!callbacks.length) {
        delete this._callbacks[event];
      }
    }
    return this;
  }

  trigger(event, ...args) {
    this.eventInProgress = { name: event, args };
    const callbacks = this._callbacks?.[event];
    if (callbacks) {
      for (const callback of callbacks.slice(0)) {
        if (typeof callback === "function") {
          callback(...args);
        }
      }
    }
    this.eventInProgress = null;
    if (event !== "all") {
      this.trigger("all", event, ...args);
    }
    return this;
  }

  removeEvent(event) {
    if (this._callbacks != null) {
      for (var name of event.split(" ")) {
        delete this._callbacks[name];
      }
    }
    return this;
  }
}
