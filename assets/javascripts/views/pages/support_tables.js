// @ts-check

//= require views/pages/base

/** The support tables' "show all" buttons, which expand a table in place. */
app.views.SupportTablesPage = class SupportTablesPage extends (
  app.views.BasePage
) {
  static events = { click: "onClick" };

  /** @param {ViewMouseEvent} event */
  onClick(event) {
    if (!event.target.classList.contains("show-all")) {
      return;
    }
    $.stopEvent(event);

    let el = event.target;
    while (el.tagName !== "TABLE") {
      el = el.parentNode;
    }
    el.classList.add("show-all");
  }
};
