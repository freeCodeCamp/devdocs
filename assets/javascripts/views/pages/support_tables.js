//= require views/pages/base

app.views.SupportTablesPage = class SupportTablesPage extends (
  app.views.BasePage
) {
  static events = { click: "onClick" };

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
