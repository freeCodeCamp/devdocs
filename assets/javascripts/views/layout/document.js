// @ts-check

import { app } from "../../app/app.js";
import { $ } from "../../lib/util.js";
import { Content } from "../content/content.js";
import { Menu } from "./menu.js";
import { Mobile } from "./mobile.js";
import { Path } from "./path.js";
import { Resizer } from "./resizer.js";
import { SettingsView } from "./settings.js";
import { Sidebar } from "../sidebar/sidebar.js";
import { View } from "../view.js";

/**
 * The root view, bound to the document itself.
 *
 * Owns the menu, the sidebar, the content and the preferences panel, and
 * handles the shortcuts and the `data-behavior` links that aren't tied to any
 * one of them.
 */
export class AppDocument extends View {
  static el = document;

  static events = { visibilitychange: "onVisibilityChange" };

  static shortcuts = {
    help: "onHelp",
    preferences: "onPreferences",
    escape: "onEscape",
    superLeft: "onBack",
    superRight: "onForward",
  };

  static routes = { after: "afterRoute" };

  /** @inheritdoc */
  init() {
    this.menu = new Menu();
    this.sidebar = new Sidebar();
    this.addSubview(this.sidebar);
    this.addSubview(this.menu);
    if (Resizer.isSupported()) {
      this.resizer = new Resizer();
      this.addSubview(this.resizer);
    }
    this.content = new Content();
    this.addSubview(this.content);
    if (!app.isSingleDoc() && !app.isMobile()) {
      this.path = new Path();
      this.addSubview(this.path);
    }
    if (!app.isSingleDoc()) {
      this.settings = new SettingsView();
    }

    $.on(document.body, "click", this.onClick);

    this.activate();
  }

  /** @param {string} [title] Prefixed to the app's name, or omitted for the app's name alone. */
  setTitle(title) {
    return (this.el.title = title
      ? `${title} — DevDocs`
      : "DevDocs API Documentation");
  }

  /** @param {string} route */
  afterRoute(route) {
    if (route === "settings") {
      if (this.settings != null) {
        this.settings.activate();
      }
    } else {
      if (this.settings != null) {
        this.settings.deactivate();
      }
    }
  }

  /**
   * Reloads when the viewport crossed the phone-layout threshold while the
   * tab was in the background, e.g. after the device was rotated.
   */
  onVisibilityChange() {
    if (document.visibilityState !== "visible") {
      return;
    }
    this.delay(() => {
      if (app.isMobile() !== Mobile.detect()) {
        location.reload();
      }
    }, 300);
  }

  /** Opens the keyboard shortcuts. */
  onHelp() {
    app.router.show("/help#shortcuts");
  }

  /** Opens the preferences. */
  onPreferences() {
    app.router.show("/settings");
  }

  /** Goes up to the doc's index, or to the app's index. */
  onEscape() {
    const path =
      !app.isSingleDoc() || location.pathname === app.doc.fullPath()
        ? "/"
        : app.doc.fullPath();

    app.router.show(path);
  }

  /** Goes back. */
  onBack() {
    history.back();
  }

  /** Goes forward. */
  onForward() {
    history.forward();
  }

  /**
   * Runs the `data-behavior` the click landed on, if any.
   *
   * @param {ViewMouseEvent} event
   */
  onClick(event) {
    const target = $.eventTarget(event);
    if (!target.hasAttribute("data-behavior")) {
      return;
    }
    $.stopEvent(event);
    switch (target.getAttribute("data-behavior")) {
      case "back":
        history.back();
        break;
      case "reload":
        window.location.reload();
        break;
      case "reboot":
        app.reboot();
        break;
      case "hard-reload":
        app.reload();
        break;
      case "reset":
        if (confirm("Are you sure you want to reset DevDocs?")) {
          app.reset();
        }
        break;
      case "accept-analytics":
        Cookies.set("analyticsConsent", "1", { expires: 1e8 }) && app.reboot();
        break;
      case "decline-analytics":
        Cookies.set("analyticsConsent", "0", { expires: 1e8 }) && app.reboot();
        break;
    }
  }
}
