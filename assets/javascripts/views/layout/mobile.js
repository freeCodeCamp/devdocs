// @ts-check

/**
 * The phone layout: one pane at a time, with a toggle between the sidebar and
 * the content, and tabs for the doc picker and the preferences.
 */
app.views.Mobile = class Mobile extends app.View {
  static className = "_mobile";

  static elements = {
    body: "body",
    content: "._container",
    sidebar: "._sidebar",
    docPicker: "._settings ._sidebar",
  };

  static shortcuts = { escape: "onEscape" };

  static routes = { after: "afterRoute" };

  /**
   * @returns {boolean} Whether to use the phone layout. The user agent is
   *   consulted as well as the viewport, because some devices report a
   *   desktop-sized width.
   */
  static detect() {
    if (Cookies.get("override-mobile-detect") != null) {
      return JSON.parse(Cookies.get("override-mobile-detect"));
    }
    try {
      return (
        window.matchMedia("(max-width: 480px)").matches ||
        window.matchMedia("(max-width: 767px)").matches ||
        window.matchMedia("(max-height: 767px) and (max-width: 1024px)")
          .matches ||
        // Need to sniff the user agent because some Android and Windows Phone devices don't take
        // resolution (dpi) into account when reporting device width/height.
        (navigator.userAgent.includes("Android") &&
          navigator.userAgent.includes("Mobile")) ||
        navigator.userAgent.includes("IEMobile")
      );
    } catch (error) {
      return false;
    }
  }

  /** @returns {boolean} Whether the app is running inside an Android webview. */
  static detectAndroidWebview() {
    try {
      return /(Android).*( Version\/.\.. ).*(Chrome)/.test(navigator.userAgent);
    } catch (error) {
      return false;
    }
  }

  constructor() {
    super(document.documentElement);
  }

  /** @inheritdoc */
  init() {
    $.on($("._search"), "touchend", () => this.onTapSearch());

    this.toggleSidebar = $("button[data-toggle-sidebar]");
    this.toggleSidebar.removeAttribute("hidden");
    $.on(this.toggleSidebar, "click", () => this.onClickToggleSidebar());

    this.back = $("button[data-back]");
    this.back.removeAttribute("hidden");
    $.on(this.back, "click", () => this.onClickBack());

    this.forward = $("button[data-forward]");
    this.forward.removeAttribute("hidden");
    $.on(this.forward, "click", () => this.onClickForward());

    this.docPickerTab = $('button[data-tab="doc-picker"]');
    this.docPickerTab.removeAttribute("hidden");
    $.on(this.docPickerTab, "click", (event) =>
      this.onClickDocPickerTab(event),
    );

    this.settingsTab = $('button[data-tab="settings"]');
    this.settingsTab.removeAttribute("hidden");
    $.on(this.settingsTab, "click", (event) => this.onClickSettingsTab(event));

    app.document.sidebar.search.on("searching", () => this.showSidebar());

    this.activate();
  }

  /** Brings the sidebar into view. */
  showSidebar() {
    if (this.isSidebarShown()) {
      window.scrollTo(0, 0);
      return;
    }

    this.contentTop = window.scrollY;
    this.content.style.display = "none";
    this.sidebar.style.display = "block";

    const selection = this.findByClass(app.views.ListSelect.activeClass);
    if (selection) {
      const scrollContainer =
        window.scrollY === this.body.scrollTop
          ? this.body
          : document.documentElement;
      $.scrollTo(selection, scrollContainer, "center");
    } else {
      window.scrollTo(
        0,
        (this.findByClass(app.views.ListFold.activeClass) && this.sidebarTop) ||
          0,
      );
    }
  }

  /** Puts the content back in view. */
  hideSidebar() {
    if (!this.isSidebarShown()) {
      return;
    }
    this.sidebarTop = window.scrollY;
    this.sidebar.style.display = "none";
    this.content.style.display = "block";
    window.scrollTo(0, this.contentTop || 0);
  }

  /** @returns {boolean} */
  isSidebarShown() {
    return this.sidebar.style.display !== "none";
  }

  /** Goes back, or up to the doc's index. */
  onClickBack() {
    return history.back();
  }

  /** Goes forward. */
  onClickForward() {
    return history.forward();
  }

  /** Swaps between the sidebar and the content. */
  onClickToggleSidebar() {
    if (this.isSidebarShown()) {
      this.hideSidebar();
    } else {
      this.showSidebar();
    }
  }

  /** @param {ViewMouseEvent} event */
  onClickDocPickerTab(event) {
    $.stopEvent(event);
    this.showDocPicker();
  }

  /** @param {ViewMouseEvent} event */
  onClickSettingsTab(event) {
    $.stopEvent(event);
    this.showSettings();
  }

  /** Switches the preferences panel to the doc picker. */
  showDocPicker() {
    window.scrollTo(0, 0);
    this.docPickerTab.classList.add("active");
    this.settingsTab.classList.remove("active");
    this.docPicker.style.display = "block";
    this.content.style.display = "none";
  }

  /** Switches the preferences panel to the settings. */
  showSettings() {
    window.scrollTo(0, 0);
    this.docPickerTab.classList.remove("active");
    this.settingsTab.classList.add("active");
    this.docPicker.style.display = "none";
    this.content.style.display = "block";
  }

  /** Reveals the sidebar when the search field is tapped. */
  onTapSearch() {
    return window.scrollTo(0, 0);
  }

  /** Leaves the sidebar. */
  onEscape() {
    return this.hideSidebar();
  }

  /** @param {string} route */
  afterRoute(route) {
    this.hideSidebar();

    if (route === "settings") {
      this.showDocPicker();
    } else {
      this.content.style.display = "block";
    }

    if (page.canGoBack()) {
      this.back.removeAttribute("disabled");
    } else {
      this.back.setAttribute("disabled", "disabled");
    }

    if (page.canGoForward()) {
      this.forward.removeAttribute("disabled");
    } else {
      this.forward.setAttribute("disabled", "disabled");
    }
  }
};
