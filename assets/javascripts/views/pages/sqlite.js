// @ts-check

//= require views/pages/base

/** The SQLite pages' show/hide toggles. */
class SqlitePage extends BasePage {
  static events = { click: "onClick" };

  /** @param {ViewMouseEvent} event */
  onClick(event) {
    const id = event.target.getAttribute("data-toggle");
    if (!id) {
      return;
    }
    const el = this.find(`#${id}`);
    if (!el) {
      return;
    }
    $.stopEvent(event);
    if (el.style.display === "none") {
      el.style.display = "block";
      event.target.textContent = "hide";
    } else {
      el.style.display = "none";
      event.target.textContent = "show";
    }
  }
}

// Registered on `app` so that the rest of the code can reach it; declared at
// the top level so that it can be named in a type.
app.views.SqlitePage = SqlitePage;
