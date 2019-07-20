**Table of contents:**

* [Overview](#overview)
* [Configuration](#configuration)
  - [Attributes](#attributes)
  - [Filter stacks](#filter-stacks)
  - [Filter options](#filter-options)

## Overview

Starting from a root URL, scrapers recursively follow links that match a set of rules, passing each valid response through a chain of filters before writing the file on the local filesystem. They also create an index of the pages' metadata (determined by one filter), which is dumped into a JSON file at the end.

Scrapers rely on the following libraries:

* [Typhoeus](https://github.com/typhoeus/typhoeus) for making HTTP requests
* [HTML::Pipeline](https://github.com/jch/html-pipeline) for applying filters
* [Nokogiri](http://nokogiri.org/) for parsing HTML

There are currently two kinds of scrapers: [`UrlScraper`](https://github.com/Thibaut/devdocs/blob/master/lib/docs/core/scrapers/url_scraper.rb) which downloads files via HTTP and [`FileScraper`](https://github.com/Thibaut/devdocs/blob/master/lib/docs/core/scrapers/file_scraper.rb) which reads them from the local filesystem. They function almost identically (both use URLs), except that `FileScraper` substitutes the base URL with a local path before reading a file. `FileScraper` uses the placeholder `localhost` base URL by default and includes a filter to remove any URL pointing to it at the end.

To be processed, a response must meet the following requirements:

* 200 status code
* HTML content type
* effective URL (after redirection) contained in the base URL (explained below)

(`FileScraper` only checks if the file exists and is not empty.)

Each URL is requested only once (case-insensitive).

## Configuration

Configuration is done via class attributes and divided into three main categories:

* [Attributes](#attributes) — essential information such as name, version, URL, etc.
* [Filter stacks](#filter-stacks) — the list of filters that will be applied to each page.
* [Filter options](#filter-options) — the options passed to said filters.

**Note:** scrapers are located in the [`lib/docs/scrapers`](https://github.com/Thibaut/devdocs/tree/master/lib/docs/scrapers/) directory. The class's name must be the [CamelCase](http://api.rubyonrails.org/classes/String.html#method-i-camelize) equivalent of the filename.

### Attributes

* `name` [String]
  Must be unique.
  Defaults to the class's name.

* `slug` [String]
  Must be unique, lowercase, and not include dashes (underscores are ok).
  Defaults to `name` lowercased.

* `type` [String] **(required, inherited)**
  Defines the CSS class name (`_[type]`) and custom JavaScript class (`app.views.[Type]Page`) that will be added/loaded on each page. Documentations sharing a similar structure (e.g. generated with the same tool or originating from the same website) should use the same `type` to avoid duplicating the CSS and JS.
  Must include lowercase letters only.

* `release` [String] **(required)**
  The version of the software at the time the scraper was last run. This is only informational and doesn't affect the scraper's behavior.

* `base_url` [String] **(required in `UrlScraper`)**
  The documents' location. Only URLs _inside_ the `base_url` will be scraped. "inside" more or less means "starting with" except that `/docs` is outside `/doc` (but `/doc/` is inside).
   Defaults to `localhost` in `FileScraper`. _(Note: any iframe, image, or skipped link pointing to localhost will be removed by the `CleanLocalUrls` filter; the value should be overridden if the documents are available online.)_
  Unless `root_path` is set, the root/initial URL is equal to `base_url`.

* `root_path` [String] **(inherited)**
  The path from the `base_url` of the root URL.

* `initial_paths` [Array] **(inherited)**
  A list of paths (from the `base_url`) to add to the initial queue. Useful for scraping isolated documents.
  Defaults to `[]`. _(Note: the `root_path` is added to the array at runtime.)_

* `dir` [String] **(required, `FileScraper` only)**
  The absolute path where the files are located on the local filesystem.
  _Note: `FileScraper` works exactly like `UrlScraper` (manipulating the same kind of URLs) except that it substitutes `base_url` with `dir` in order to read files instead of making HTTP requests._

* `params` [Hash] **(inherited, `UrlScraper` only)**
  Query string parameters to append to every URL. (e.g. `{ format: 'raw' }` → `?format=raw`)
  Defaults to `{}`.

* `abstract` [Boolean]
  Make the scraper abstract / not runnable. Used for sharing behavior with other scraper classes (e.g. all MDN scrapers inherit from the abstract [`Mdn`](https://github.com/Thibaut/devdocs/blob/master/lib/docs/scrapers/mdn/mdn.rb) class).
  Defaults to `false`.

### Filter stacks

Each scraper has two [filter](https://github.com/Thibaut/devdocs/blob/master/lib/docs/core/filter.rb) [stacks](https://github.com/Thibaut/devdocs/blob/master/lib/docs/core/filter_stack.rb): `html_filters` and `text_filters`. They are combined into a pipeline (using the [HTML::Pipeline](https://github.com/jch/html-pipeline) library) which causes each filter to hand its output to the next filter's input.

HTML filters are executed first and manipulate a parsed version of the document (a [Nokogiri](http://nokogiri.org/Nokogiri/XML/Node.html) node object), whereas text filters manipulate the document as a string. This separation avoids parsing the document multiple times.

Filter stacks are like sorted sets. They can modified using the following methods:

```ruby
push(*names)                 # append one or more filters at the end
insert_before(index, *names) # insert one filter before another (index can be a name)
insert_after(index, *names)  # insert one filter after another (index can be a name)
replace(index, name)         # replace one filter with another (index can be a name)
```

"names" are `require` paths relative to `Docs` (e.g. `jquery/clean_html` → `Docs::Jquery::CleanHtml`).

Default `html_filters`:

* [`ContainerFilter`](https://github.com/Thibaut/devdocs/blob/master/lib/docs/filters/core/container.rb) — changes the root node of the document (remove everything outside)
* [`CleanHtmlFilter`](https://github.com/Thibaut/devdocs/blob/master/lib/docs/filters/core/clean_html.rb) — removes HTML comments, `<script>`, `<style>`, etc.
* [`NormalizeUrlsFilter`](https://github.com/Thibaut/devdocs/blob/master/lib/docs/filters/core/normalize_urls.rb) — replaces all URLs with their fully qualified counterpart
* [`InternalUrlsFilter`](https://github.com/Thibaut/devdocs/blob/master/lib/docs/filters/core/internal_urls.rb) — detects internal URLs (the ones to scrape) and replaces them with their unqualified, relative counterpart
* [`NormalizePathsFilter`](https://github.com/Thibaut/devdocs/blob/master/lib/docs/filters/core/normalize_paths.rb) — makes the internal paths consistent (e.g. always end with `.html`)
* [`CleanLocalUrlsFilter`](https://github.com/Thibaut/devdocs/blob/master/lib/docs/filters/core/clean_local_urls.rb) — removes links, iframes and images pointing to localhost (`FileScraper` only)

Default `text_filters`:

* [`InnerHtmlFilter`](https://github.com/Thibaut/devdocs/blob/master/lib/docs/filters/core/inner_html.rb) — converts the document to a string
* [`CleanTextFilter`](https://github.com/Thibaut/devdocs/blob/master/lib/docs/filters/core/clean_text.rb) — removes empty nodes
* [`AttributionFilter`](https://github.com/Thibaut/devdocs/blob/master/lib/docs/filters/core/attribution.rb) — appends the license info and link to the original document

Additionally:

* [`TitleFilter`](https://github.com/Thibaut/devdocs/blob/master/lib/docs/filters/core/title.rb) is a core HTML filter, disabled by default, which prepends the document with a title (`<h1>`).
* [`EntriesFilter`](https://github.com/Thibaut/devdocs/blob/master/lib/docs/filters/core/entries.rb) is an abstract HTML filter that each scraper must implement and responsible for extracting the page's metadata.

### Filter options

The filter options are stored in the `options` Hash. The Hash is inheritable (a recursive copy) and empty by default.

More information about how filters work is available on the [Filter Reference](./filter-reference.md) page.

* [`ContainerFilter`](https://github.com/Thibaut/devdocs/blob/master/lib/docs/filters/core/container.rb)

  - `:container` [String or Proc]
    A CSS selector of the container element. Everything outside of it will be removed and become unavailable to the other filters. If more than one element match the selector, the first one inside the DOM is used. If no elements match the selector, an error is raised.
    If the value is a Proc, it is called for each page with the filter instance as argument, and should return a selector or `nil`.
    The default container is the `<body>` element.
    _Note: links outside of the container element will not be followed by the scraper. To remove links that should be followed, use a [`CleanHtml`](./filter-reference.md#cleanhtmlfilter) filter later in the stack._

* [`NormalizeUrlsFilter`](https://github.com/Thibaut/devdocs/blob/master/lib/docs/filters/core/normalize_urls.rb)
  The following options are used to modify URLs in the pages. They are useful to remove duplicates (when the same page is accessible from multiple URLs) and fix websites that have a bunch of redirections in place (when URLs that should be scraped, aren't, because they are behind a redirection which is outside of the `base_url` — see the MDN scrapers for examples of this).

  - `:replace_urls` [Hash]
    Replaces all instances of a URL with another.
    Format: `{ 'original_url' => 'new_url' }`
  - `:replace_paths` [Hash]
    Replaces all instances of a sub-path (path from the `base_url`) with another.
    Format: `{ 'original_path' => 'new_path' }`
  - `:fix_urls` [Proc]
    Called with each URL. If the returned value is `nil`, the URL isn't modified. Otherwise the returned value is used as replacement.

  _Note: before these rules are applied, all URLs are converted to their fully qualified counterpart (http://...)._

* [`InternalUrlsFilter`](https://github.com/Thibaut/devdocs/blob/master/lib/docs/filters/core/internal_urls.rb)

  Internal URLs are the ones _inside_ the scraper's `base_url` ("inside" more or less means "starting with", except that `/docs` is outside `/doc`). They will be scraped unless excluded by one of the following rules. All internal URLs are converted to relative URLs inside the pages.

  - `:skip_links` [Boolean or Proc]
    If `false`, does not convert or follow any internal URL (creating a single-page documentation).
    If the value is a Proc, it is called for each page with the filter instance as argument.
  - `:follow_links` [Proc]
    Called for page with the filter instance as argument. If the returned value is `false`, does not add internal URLs to the queue.
  - `:trailing_slash` [Boolean]
    If `true`, adds a trailing slash to all internal URLs. If `false`, removes it.
    This is another option used to remove duplicate pages.
  - `:skip` [Array]
    Ignores internal URLs whose sub-paths (path from the `base_url`) are in the Array (case-insensitive).
  - `:skip_patterns` [Array]
    Ignores internal URLs whose sub-paths match any Regexp in the Array.
  - `:only` [Array]
    Ignores internal URLs whose sub-paths aren't in the Array (case-insensitive) and don't match any Regexp in `:only_patterns`.
  - `:only_patterns` [Array]
    Ignores internal URLs whose sub-paths don't match any Regexp in the Array and aren't in `:only`.

  If the scraper has a `root_path`, the empty and `/` paths are automatically skipped.
  If `:only` or `:only_patterns` is set, the root path is automatically added to `:only`.

  _Note: pages can be excluded from the index based on their content using the [`Entries`](./filter-reference.md#entriesfilter) filter. However, their URLs will still be converted to relative in the other pages and trying to open them will return a 404 error. Although not ideal, this is often better than having to maintain a long list of `:skip` URLs._

* [`AttributionFilter`](https://github.com/Thibaut/devdocs/blob/master/lib/docs/filters/core/attribution.rb)

  - `:attribution` [String] **(required)**
    An HTML string with the copyright and license information. See the other scrapers for examples.

* [`TitleFilter`](https://github.com/Thibaut/devdocs/blob/master/lib/docs/filters/core/title.rb)

  - `:title` [String or Boolean or Proc]
    Unless the value is `false`, adds a title to every page.
    If the value is `nil`, the title is the name of the page as determined by the [`Entries`](./filter-reference.md#entriesfilter) filter. Otherwise the title is the String or the value returned by the Proc (called for each page, with the filter instance as argument). If the Proc returns `nil` or `false`, no title is added.
  - `:root_title` [String or Boolean]
    Overrides the `:title` option for the root page only.

  _Note: this filter is disabled by default._

## Keeping scrapers up-to-date

In order to keep scrapers up-to-date the `get_latest_version(opts)` method should be overridden. If `self.release` is defined, this should return the latest version of the documentation. If `self.release` is not defined, it should return the Epoch time when the documentation was last modified. If the documentation will never change, simply return `1.0.0`. The result of this method is periodically reported in a "Documentation versions report" issue which helps maintainers keep track of outdated documentations.

To make life easier, there are a few utility methods that you can use in `get_latest_version`:
* `fetch(url, opts)`

  Makes a GET request to the url and returns the response body.

  Example: [lib/docs/scrapers/bash.rb](../lib/docs/scrapers/bash.rb)
* `fetch_doc(url, opts)`

  Makes a GET request to the url and returns the HTML body converted to a Nokogiri document.

  Example: [lib/docs/scrapers/git.rb](../lib/docs/scrapers/git.rb)
* `fetch_json(url, opts)`

  Makes a GET request to the url and returns the JSON body converted to a dictionary.

  Example: [lib/docs/scrapers/mdn/mdn.rb](../lib/docs/scrapers/mdn/mdn.rb)
* `get_npm_version(package, opts)`

  Returns the latest version of the given npm package.

  Example: [lib/docs/scrapers/bower.rb](../lib/docs/scrapers/bower.rb)
* `get_latest_github_release(owner, repo, opts)`

  Returns the tag name of the latest GitHub release of the given repository. If the tag name is preceded by a "v", the "v" will be removed.

  Example: [lib/docs/scrapers/jsdoc.rb](../lib/docs/scrapers/jsdoc.rb)
* `get_github_tags(owner, repo, opts)`

  Returns the list of tags on the given repository ([format](https://developer.github.com/v3/repos/#list-tags)).

  Example: [lib/docs/scrapers/liquid.rb](../lib/docs/scrapers/liquid.rb)
* `get_github_file_contents(owner, repo, path, opts)`

  Returns the contents of the requested file in the default branch of the given repository.

  Example: [lib/docs/scrapers/minitest.rb](../lib/docs/scrapers/minitest.rb)
