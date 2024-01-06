// TODO: This file was created by bulk-decaffeinate.
// Sanity-check the conversion and remove this comment.
/*
 * decaffeinate suggestions:
 * DS002: Fix invalid constructor
 * DS206: Consider reworking classes to avoid initClass
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/main/docs/suggestions.md
 */
//= require views/pages/base

app.views.SqlitePage = class SqlitePage extends app.views.BasePage {
  constructor(...args) {
    this.onClick = this.onClick.bind(this);
    super(...args);
  }

  static initClass() {
    this.events = { click: "onClick" };
  }

  onClick(event) {
    let el, id;
    if (!(id = event.target.getAttribute("data-toggle"))) {
      return;
    }
    if (!(el = this.find(`#${id}`))) {
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
app.views.SqlitePage.initClass();
