// @ts-check

import * as errorTmpl from "./error_tmpl.js";
import * as noticeTmpl from "./notice_tmpl.js";
import * as notifTmpl from "./notif_tmpl.js";
import * as aboutTmpl from "./pages/about_tmpl.js";
import * as helpTmpl from "./pages/help_tmpl.js";
import * as newsTmpl from "./pages/news_tmpl.js";
import * as offlineTmpl from "./pages/offline_tmpl.js";
import * as rootTmpl from "./pages/root_tmpl.js";
import * as settingsTmpl from "./pages/settings_tmpl.js";
import * as typeTmpl from "./pages/type_tmpl.js";
import * as pathTmpl from "./path_tmpl.js";
import * as sidebarTmpl from "./sidebar_tmpl.js";
import * as tipTmpl from "./tip_tmpl.js";

/**
 * Every template, under the name it is rendered by.
 *
 * Views reach templates by name (`this.tmpl("notifError")`), so the lookup has
 * to stay dynamic even though the modules are imported statically. Spreading
 * each module keeps the map in step with what it exports, rather than
 * repeating every name here.
 *
 * @type {Record<string, ((...args: any[]) => string) | string>}
 */
const templates = {
  ...errorTmpl,
  ...noticeTmpl,
  ...notifTmpl,
  ...aboutTmpl,
  ...helpTmpl,
  ...newsTmpl,
  ...offlineTmpl,
  ...rootTmpl,
  ...settingsTmpl,
  ...typeTmpl,
  ...pathTmpl,
  ...sidebarTmpl,
  ...tipTmpl,
};

/**
 * Renders a template by name.
 *
 * Templates are either functions or plain strings. Passing an array renders
 * the template once per element and concatenates the results, which is how
 * lists are built.
 *
 * @param {string} name The template's key.
 * @param {unknown} [value] The template's first argument, or an array of them.
 * @param {...unknown} args Passed on after `value`.
 * @returns {string} The rendered HTML.
 */
export function render(name, value, ...args) {
  const template = templates[name];

  if (Array.isArray(value) && typeof template === "function") {
    let result = "";
    for (var val of value) {
      result += template(val, ...args);
    }
    return result;
  } else if (typeof template === "function") {
    return template(value, ...args);
  } else {
    return template;
  }
}
