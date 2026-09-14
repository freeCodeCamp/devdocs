/**
 * Stands in for docs.js, rendered from docs.js.erb at build time. Mirrors the
 * real module's side effect so a test that loads it sees the same shape: it is
 * a separate entry, not a dependency of the app, so it may touch `app`.
 */
import { app } from "../../../assets/javascripts/app/app.js";

app.DOCS = [];
