// @ts-check

//= require views/pages/base

/** The RDoc pages' "Show source" toggles. */
class RdocPage extends BasePage {
  static events = { click: "onClick" };

  /** @param {ViewMouseEvent} event */
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
}

// Registered on `app` so that the rest of the code can reach it; declared at
// the top level so that it can be named in a type.
app.views.RdocPage = RdocPage;
