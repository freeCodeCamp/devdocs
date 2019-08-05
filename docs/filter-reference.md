**Table of contents:**

* [Overview](#overview)
* [Instance methods](#instance-methods)
* [Core filters](#core-filters)
* [Custom filters](#custom-filters)
  - [CleanHtmlFilter](#cleanhtmlfilter)
  - [EntriesFilter](#entriesfilter)

## Overview

Filters use the [HTML::Pipeline](https://github.com/jch/html-pipeline) library. They take an HTML string or [Nokogiri](http://nokogiri.org/) node as input, optionally perform modifications and/or extract information from it, and then outputs the result. Together they form a pipeline where each filter hands its output to the next filter's input. Every documentation page passes through this pipeline before being copied on the local filesystem.

Filters are subclasses of the [`Docs::Filter`](https://github.com/Thibaut/devdocs/blob/master/lib/docs/core/filter.rb) class and require a `call` method. A basic implementation looks like this:

```ruby
module Docs
  class CustomFilter < Filter
    def call
      doc
    end
  end
end
```

Filters which manipulate the Nokogiri node object (`doc` and related methods) are _HTML filters_ and must not manipulate the HTML string (`html`). Vice-versa, filters which manipulate the string representation of the document are _text filters_ and must not manipulate the Nokogiri node object. The two types are divided into two stacks within the scrapers. These stacks are then combined into a pipeline that calls the HTML filters before the text filters (more details [here](./scraper-reference.md#filter-stacks)). This is to avoid parsing the document multiple times.

The `call` method must return either `doc` or `html`, depending on the type of filter.

## Instance methods

* `doc` [Nokogiri::XML::Node]
  The Nokogiri representation of the container element.
  See [Nokogiri's API docs](http://www.rubydoc.info/github/sparklemotion/nokogiri/Nokogiri/XML/Node) for the list of available methods.

* `html` [String]
  The string representation of the container element.

* `context` [Hash] **(frozen)**
  The scraper's `options` along with a few additional keys: `:base_url`, `:root_url`, `:root_page` and `:url`.

* `result` [Hash]
  Used to store the page's metadata and pass back information to the scraper.
  Possible keys:

  - `:path` — the page's normalized path
  - `:store_path` — the path where the page will be stored (equal to `:path` with `.html` at the end)
  - `:internal_urls` — the list of distinct internal URLs found within the page
  - `:entries` — the [`Entry`](https://github.com/Thibaut/devdocs/blob/master/lib/docs/core/models/entry.rb) objects to add to the index

* `css`, `at_css`, `xpath`, `at_xpath`
  Shortcuts for `doc.css`, `doc.xpath`, etc.

* `base_url`, `current_url`, `root_url` [Docs::URL]
  Shortcuts for `context[:base_url]`, `context[:url]`, and `context[:root_url]` respectively.

* `root_path` [String]
  Shortcut for `context[:root_path]`.

* `subpath` [String]
  The sub-path from the base URL of the current URL.
  _Example: if `base_url` equals `example.com/docs` and `current_url` equals `example.com/docs/file?raw`, the returned value is `/file`._

* `slug` [String]
  The `subpath` removed of any leading slash or `.html` extension.
  _Example: if `subpath` equals `/dir/file.html`, the returned value is `dir/file`._

* `root_page?` [Boolean]
  Returns `true` if the current page is the root page.

* `initial_page?` [Boolean]
  Returns `true` if the current page is the root page or its subpath is one of the scraper's `initial_paths`.

## Core filters

* [`ContainerFilter`](https://github.com/Thibaut/devdocs/blob/master/lib/docs/filters/core/container.rb) — changes the root node of the document (remove everything outside)
* [`CleanHtmlFilter`](https://github.com/Thibaut/devdocs/blob/master/lib/docs/filters/core/clean_html.rb) — removes HTML comments, `<script>`, `<style>`, etc.
* [`NormalizeUrlsFilter`](https://github.com/Thibaut/devdocs/blob/master/lib/docs/filters/core/normalize_urls.rb) — replaces all URLs with their fully qualified counterpart
* [`InternalUrlsFilter`](https://github.com/Thibaut/devdocs/blob/master/lib/docs/filters/core/internal_urls.rb) — detects internal URLs (the ones to scrape) and replaces them with their unqualified, relative counterpart
* [`NormalizePathsFilter`](https://github.com/Thibaut/devdocs/blob/master/lib/docs/filters/core/normalize_paths.rb) — makes the internal paths consistent (e.g. always end with `.html`)
* [`CleanLocalUrlsFilter`](https://github.com/Thibaut/devdocs/blob/master/lib/docs/filters/core/clean_local_urls.rb) — removes links, iframes and images pointing to localhost (`FileScraper` only)
* [`InnerHtmlFilter`](https://github.com/Thibaut/devdocs/blob/master/lib/docs/filters/core/inner_html.rb) — converts the document to a string
* [`CleanTextFilter`](https://github.com/Thibaut/devdocs/blob/master/lib/docs/filters/core/clean_text.rb) — removes empty nodes
* [`AttributionFilter`](https://github.com/Thibaut/devdocs/blob/master/lib/docs/filters/core/attribution.rb) — appends the license info and link to the original document
* [`TitleFilter`](https://github.com/Thibaut/devdocs/blob/master/lib/docs/filters/core/title.rb) — prepends the document with a title (disabled by default)
* [`EntriesFilter`](https://github.com/Thibaut/devdocs/blob/master/lib/docs/filters/core/entries.rb) — abstract filter for extracting the page's metadata

## Custom filters

Scrapers can have any number of custom filters but require at least the two described below.

**Note:** filters are located in the [`lib/docs/filters`](https://github.com/Thibaut/devdocs/tree/master/lib/docs/filters/) directory. The class's name must be the [CamelCase](http://api.rubyonrails.org/classes/String.html#method-i-camelize) equivalent of the filename.

### `CleanHtmlFilter`

The `CleanHtml` filter is tasked with cleaning the HTML markup where necessary and removing anything superfluous or nonessential. Only the core documentation should remain at the end.

Nokogiri's many jQuery-like methods make it easy to search and modify elements — see the [API docs](http://www.rubydoc.info/github/sparklemotion/nokogiri/Nokogiri/XML/Node).

Here's an example implementation that covers the most common use-cases:

```ruby
module Docs
  class MyScraper
    class CleanHtmlFilter < Filter
      def call
        css('hr').remove
        css('#changelog').remove if root_page?

        # Set id attributes on <h3> instead of an empty <a>
        css('h3').each do |node|
          node['id'] = node.at_css('a')['id']
        end

        # Make proper table headers
        css('td.header').each do |node|
          node.name = 'th'
        end

        # Remove code highlighting
        css('pre').each do |node|
          node.content = node.content
        end

        doc
      end
    end
  end
end
```

**Notes:**

* Empty elements will be automatically removed by the core `CleanTextFilter` later in the pipeline's execution.
* Although the goal is to end up with a clean version of the page, try to keep the number of modifications to a minimum, so as to make the code easier to maintain. Custom CSS is the preferred way of normalizing the pages (except for hiding stuff which should always be done by removing the markup).
* Try to document your filter's behavior as much as possible, particularly modifications that apply only to a subset of pages. It'll make updating the documentation easier.

### `EntriesFilter`

The `Entries` filter is responsible for extracting the page's metadata, represented by a set of _entries_, each with a name, type and path.

The following two models are used under the hood to represent the metadata:

* [`Entry(name, type, path)`](https://github.com/Thibaut/devdocs/blob/master/lib/docs/core/models/entry.rb)
* [`Type(name, slug, count)`](https://github.com/Thibaut/devdocs/blob/master/lib/docs/core/models/type.rb)

Each scraper must implement its own `EntriesFilter` by subclassing the [`Docs::EntriesFilter`](https://github.com/Thibaut/devdocs/blob/master/lib/docs/filters/core/entries.rb) class. The base class already implements the `call` method and includes four methods which the subclasses can override:

* `get_name` [String]
  The name of the default entry (aka. the page's name).
  It is usually guessed from the `slug` (documented above) or by searching the HTML markup.
  **Default:** modified version of `slug` (underscores are replaced with spaces and forward slashes with dots)

* `get_type` [String]
  The type of the default entry (aka. the page's type).
  Entries without a type can be searched for but won't be listed in the app's sidebar (unless no other entries have a type).
  **Default:** `nil`

* `include_default_entry?` [Boolean]
  Whether to include the default entry.
  Used when a page consists of multiple entries (returned by `additional_entries`) but doesn't have a name/type of its own, or to remove a page from the index (if it has no additional entries), in which case it won't be copied on the local filesystem and any link to it in the other pages will be broken (as explained on the [Scraper Reference](./scraper-reference.md) page, this is used to keep the `:skip` / `:skip_patterns` options to a maintainable size, or if the page includes links that can't reached from anywhere else).
  **Default:** `true`

* `additional_entries` [Array]
  The list of additional entries.
  Each entry is represented by an Array of three attributes: its name, fragment identifier, and type. The fragment identifier refers to the `id` attribute of the HTML element (usually a heading) that the entry relates to. It is combined with the page's path to become the entry's path. If absent or `nil`, the page's path is used. If the type is absent or `nil`, the default `type` is used.
  Example: `[ ['One'], ['Two', 'id'], ['Three', nil, 'type'] ]` adds three additional entries, the first one named "One" with the default path and type, the second one named "Two" with the URL fragment "#id" and the default type, and the third one named "Three" with the default path and the type "type".
  The list is usually constructed by running through the markup. Exceptions can also be hard-coded for specific pages.
  **Default:** `[]`

The following accessors are also available, but must not be overridden:

* `name` [String]
  Memoized version of `get_name` (`nil` for the root page).

* `type` [String]
  Memoized version of `get_type` (`nil` for the root page).

**Notes:**

* Leading and trailing whitespace is automatically removed from names and types.
* Names must be unique across the documentation and as short as possible (ideally less than 30 characters). Whenever possible, methods should be differentiated from properties by appending `()`, and instance methods should be differentiated from class methods using the `Class#method` or `object.method` conventions.
* You can call `name` from `get_type` or `type` from `get_name` but doing both will cause a stack overflow (i.e. you can infer the name from the type or the type from the name, but you can't do both at the same time). Don't call `get_name` or `get_type` directly as their value isn't memoized.
* The root page has no name and no type (both are `nil`). `get_name` and `get_type` won't get called with the page (but `additional_entries` will).
* `Docs::EntriesFilter` is an _HTML filter_. It must be added to the scraper's `html_filters` stack.
* Try to document the code as much as possible, particularly the special cases. It'll make updating the documentation easier.

**Example:**

```ruby
module Docs
  class MyScraper
    class EntriesFilter < Docs::EntriesFilter
      def get_name
        node = at_css('h1')
        result = node.content.strip
        result << ' event' if type == 'Events'
        result << '()' if node['class'].try(:include?, 'function')
        result
      end

      def get_type
        object, method = *slug.split('/')
        method ? object : 'Miscellaneous'
      end

      def additional_entries
        return [] if root_page?

        css('h2').map do |node|
          [node.content, node['id']]
        end
      end

      def include_default_entry?
        !at_css('.obsolete')
      end
    end
  end
end
```


return [[Home]]
