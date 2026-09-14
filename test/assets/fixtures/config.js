/**
 * Stands in for app/config.js, which is rendered from app/config.js.erb at
 * build time and so doesn't exist on disk for Node. The values ERB fills in
 * are neutral here; a test that depends on one sets it itself.
 *
 * @type {import("../../../assets/javascripts/app/config.js").AppConfig}
 */
export const config = {
  db_filename: "db.json",
  default_docs: [],
  docs_aliases: {},
  docs_origin: "",
  env: "test",
  history_cache_size: 10,
  index_filename: "index.json",
  max_results: 50,
  production_host: "devdocs.io",
  search_param: "q",
  sentry_dsn: "",
  version: 0,
  release: "",
  mathml_stylesheet: "/mathml.css",
  favicon_spritesheet: "",
  service_worker_path: "/service-worker.js",
  service_worker_enabled: false,
};
