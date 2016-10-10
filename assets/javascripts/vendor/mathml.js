/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/.
 * Adapted from: https://github.com/fred-wang/mathml.css */

(function () {
  window.addEventListener("load", function() {
    var box, div, link, namespaceURI;
    // First check whether the page contains any <math> element.
    namespaceURI = "http://www.w3.org/1998/Math/MathML";
    // Create a div to test mspace, using Kuma's "offscreen" CSS
    document.body.insertAdjacentHTML("afterbegin", "<div style='border: 0; clip: rect(0 0 0 0); height: 1px; margin: -1px; overflow: hidden; padding: 0; position: absolute; width: 1px;'><math xmlns='" + namespaceURI + "'><mspace height='23px' width='77px'></mspace></math></div>");
    div = document.body.firstChild;
    box = div.firstChild.firstChild.getBoundingClientRect();
    document.body.removeChild(div);
    if (Math.abs(box.height - 23) > 1  || Math.abs(box.width - 77) > 1) {
      window.supportsMathML = false;
    }
  });
}());
