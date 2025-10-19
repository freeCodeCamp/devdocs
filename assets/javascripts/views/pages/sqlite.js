//= require views/pages/base

app.views.SqlitePage = class SqlitePage extends app.views.BasePage {
  static events = { click: "onClick" };

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
};
