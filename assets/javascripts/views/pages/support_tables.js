// @ts-check

//= require views/pages/base

/** The support tables' "show all" buttons, which expand a table in place. */
class SupportTablesPage extends BasePage {
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
}

// Registered on `app` so that the rest of the code can reach it; declared at
// the top level so that it can be named in a type.
app.views.SupportTablesPage = SupportTablesPage;
