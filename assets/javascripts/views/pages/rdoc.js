//= require views/pages/base

app.views.RdocPage = class RdocPage extends app.views.BasePage {
  static events = { click: "onClick" };

  onClick(event) {
    if (!event.target.classList.contains("method-click-advice")) {
      return;
    }
    $.stopEvent(event);

    const source = $(
      ".method-source-code",
      event.target.closest(".method-detail"),
    );
    const isShown = source.style.display === "block";

    source.style.display = isShown ? "none" : "block";
    return (event.target.textContent = isShown ? "Show source" : "Hide source");
  }
};
