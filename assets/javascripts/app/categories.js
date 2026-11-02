// @ts-check

/**
 * The categories the docs are grouped in: in the sidebar, in the preferences'
 * doc list, and as a search scope (type a category's name, then Tab).
 *
 * The built-in docs are sorted here, by slug without its version. A doc from
 * a doc pack names its own category in its manifest. Anything else is "Other".
 */

/**
 * @typedef {object} Category
 * @property {string} id What a pack's manifest gives as `category`.
 * @property {string} name
 * @property {string[]} aliases Other names that scope the search to it.
 */

/** @type {Category[]} In the order they're shown. */
export const CATEGORIES = [
  { id: "languages", name: "Languages", aliases: ["language", "lang", "langs"] },
  { id: "web", name: "Web platform", aliases: ["web"] },
  { id: "frameworks", name: "Frameworks & platforms", aliases: ["framework", "platform", "platforms"] },
  { id: "libraries", name: "Libraries", aliases: ["library", "lib", "libs"] },
  { id: "testing", name: "Testing", aliases: ["test", "tests"] },
  { id: "tools", name: "Tools", aliases: ["tool"] },
  { id: "databases", name: "Databases", aliases: ["database", "db", "dbs"] },
  { id: "ai", name: "AI & data", aliases: ["ml", "data"] },
  { id: "services", name: "Servers & services", aliases: ["service", "server", "servers"] },
  { id: "other", name: "Other", aliases: [] },
];

export const DEFAULT_CATEGORY = "other";

/** The built-in docs of each category, by slug without the version. */
const BUILT_IN = {
  languages:
    "c clojure coffeescript coldfusion cpp crystal d dart elisp elixir erlang gnu_cobol gnu_fortran go " +
    "groovy haskell haxe javascript julia kotlin latex lua markdown nim ocaml octave odin openjdk perl " +
    "php pony python r ruby rust scala tcl_tk tcllib typescript typst zig",
  web: "browser_support_tables css dom html http less sass svg web_extensions xslt_xpath",
  frameworks:
    "angular angularjs astro backbone bootstrap bottle bun cakephp codeigniter cordova cyclejs deno " +
    "django django_rest_framework dojo drupal electron ember express falcon fastapi flask godot gtk hapi " +
    "jquerymobile koa laravel love marionette meteor nextjs node padrino phalcon phoenix qt rails " +
    "react react_native spring_boot svelte symfony tailwindcss vertx vue wagtail wordpress yii",
  libraries:
    "async axios bluebird click d3 date_fns eigen3 es_toolkit fluture handlebars htmx immutable jinja " +
    "joi jquery jqueryui knockout leaflet liquid lit lodash maplibre_gl modernizr moment moment_timezone " +
    "nokogiri opengl openlayers phaser point_cloud_library pug pygame q rack ramda reactivex " +
    "react_bootstrap react_router redux relay requests requirejs rxjs sanctuary sanctuary_def " +
    "sanctuary_type_classes socketio tanstack_query tanstack_router threejs tokio trio twig underscore " +
    "valibot vue_router vueuse vuex vulkan werkzeug celery",
  testing:
    "chai codeception codeceptjs cypress enzyme jasmine jest minitest mocha phpunit playwright " +
    "puppeteer pytest qunit sinon vitest",
  tools:
    "ansible babel bash bazel bower chef cmake composer docker esbuild eslint fish flow gcc git " +
    "gnu_make gnuplot graphviz grunt hammerspoon homebrew i3 jekyll jq jsdoc kubectl man nix npm " +
    "nushell opentofu powershell prettier saltstack terraform vagrant vite webpack yarn zsh",
  databases:
    "couchdb duckdb graphite influxdata mariadb mongoose opentsdb postgresql redis rethinkdb sequelize sqlite",
  ai: "apache_pig matplotlib numpy pandas polars pytorch scikit_image scikit_learn statsmodels tensorflow tensorflow_cpp",
  services: "apache_http_server haproxy kubernetes nginx nginx_lua_module rabbitmq varnish",
};

/** @type {Map<string, string>} Slug without version to category id. */
const CATEGORY_OF_SLUG = new Map(
  Object.entries(BUILT_IN).flatMap(([id, slugs]) =>
    slugs.split(" ").map((slug) => [slug, id]),
  ),
);

/** @type {Map<string, Category>} */
const BY_ID = new Map(CATEGORIES.map((category) => [category.id, category]));

/**
 * @param {unknown} id
 * @returns {id is string} Whether it names a category.
 */
export function isCategoryId(id) {
  return typeof id === "string" && BY_ID.has(id);
}

/**
 * @param {string} id
 * @returns {Category}
 */
export function getCategory(id) {
  return BY_ID.get(id) || /** @type {Category} */ (BY_ID.get(DEFAULT_CATEGORY));
}

/**
 * The category of a doc: its own for a pack doc, otherwise the built-in one.
 *
 * @param {{ slug: string, category?: unknown, pack?: unknown }} doc
 * @returns {string} A category id.
 */
export function categoryOf(doc) {
  if (isCategoryId(doc.category)) {
    return doc.category;
  }
  if (doc.pack) {
    return DEFAULT_CATEGORY;
  }
  return CATEGORY_OF_SLUG.get(doc.slug.split("~")[0]) || DEFAULT_CATEGORY;
}

/**
 * The category someone means by what they typed, e.g. "db" or "Databases".
 *
 * @param {string} query
 * @returns {Category | undefined}
 */
export function findCategory(query) {
  const text = query.trim().toLowerCase();
  if (!text) {
    return undefined;
  }
  return CATEGORIES.find(
    (category) =>
      category.id === text ||
      category.name.toLowerCase() === text ||
      category.aliases.includes(text),
  );
}

/**
 * Groups docs by category, in the categories' order, keeping the docs' order
 * within each and leaving out empty categories.
 *
 * @template {{ category: string }} D
 * @param {D[]} docs
 * @returns {{ category: Category, docs: D[] }[]}
 */
export function groupByCategory(docs) {
  return CATEGORIES.map((category) => ({
    category,
    docs: docs.filter((doc) => doc.category === category.id),
  })).filter((group) => group.docs.length > 0);
}
