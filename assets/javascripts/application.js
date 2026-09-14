// @ts-check

import { app } from "./app/app.js";
import "./tracking.js";

/*
 * Copyright 2013-2026 Thibaut Courouble and other contributors
 *
 * This source code is licensed under the terms of the Mozilla
 * Public License, v. 2.0, a copy of which may be obtained at:
 * http://mozilla.org/MPL/2.0/
 */

// The entry module. Everything else is reached through imports from here; the
// import map pins each module to its content-digested URL, so the whole graph
// is fetched from immutable, individually cacheable files.

// Module scripts are deferred, so the document has been parsed by the time
// this runs and `document.body` is always there.
app.init();
