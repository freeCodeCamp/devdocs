Adding a documentation may look like a daunting task but once you get the hang of it, it's actually quite simple. Don't hesitate to ask for help [in Gitter](https://gitter.im/FreeCodeCamp/DevDocs) if you ever get stuck.

**Note:** please read the [contributing guidelines](../.github/CONTRIBUTING.md) before submitting a new documentation.

1. Create a subclass of `Docs::UrlScraper` or `Docs::FileScraper` in the `lib/docs/scrapers/` directory. Its name should be the [PascalCase](http://api.rubyonrails.org/classes/String.html#method-i-camelize) equivalent of the filename (e.g. `my_doc` → `MyDoc`)
2. Add the appropriate class attributes and filter options (see the [Scraper Reference](./scraper-reference.md) page).
3. Check that the scraper is listed in `thor docs:list`.
4. Create filters specific to the scraper in the `lib/docs/filters/[my_doc]/` directory and add them to the class's [filter stacks](./scraper-reference.md#filter-stacks). You may create any number of filters but will need at least the following two:
   * A [`CleanHtml`](./filter-reference.md#cleanhtmlfilter) filter whose task is to clean the HTML markup (e.g. adding `id` attributes to headings) and remove everything superfluous and/or nonessential.
   * An [`Entries`](./filter-reference.md#entriesfilter) filter whose task is to determine the pages' metadata (the list of entries, each with a name, type and path).
   The [Filter Reference](./filter-reference.md) page has all the details about filters.
5. Using the `thor docs:page [my_doc] [path]` command, check that the scraper works properly. Files will appear in the `public/docs/[my_doc]/` directory (but not inside the app as the command doesn't touch the index). `path` in this case refers to either the remote path (if using `UrlScraper`) or the local path (if using `FileScraper`).
6. Generate the full documentation using the `thor docs:generate [my_doc] --force` command. Additionally, you can use the `--verbose` option to see which files are being created/updated/deleted (useful to see what changed since the last run), and the `--debug` option to see which URLs are being requested and added to the queue (useful to pin down which page adds unwanted URLs to the queue).
7. Start the server, open the app, enable the documentation, and see how everything plays out.
8. Tweak the scraper/filters and repeat 5) and 6) until the pages and metadata are ok.
9. To customize the pages' styling, create an SCSS file in the `assets/stylesheets/pages/` directory and import it in both `application.css.scss` AND `application-dark.css.scss`. Both the file and CSS class should be named `_[type]` where [type] is equal to the scraper's `type` attribute (documentations with the same type share the same custom CSS and JS). Setting the type to `simple` will apply the general styling rules in `assets/stylesheets/pages/_simple.scss`, which can be used for documentations where little to no CSS changes are needed.
10. To add syntax highlighting or execute custom JavaScript on the pages, create a file in the `assets/javascripts/views/pages/` directory (take a look at the other files to see how it works).
11. Add the documentation's icon in the `public/icons/docs/[my_doc]/` directory, in both 16x16 and 32x32-pixels formats. The icon spritesheet is automatically generated when you (re)start your local DevDocs instance.
12. Add the documentation's copyright details to the list in `assets/javascripts/templates/pages/about_tmpl.coffee`. This is the data shown in the table on the [about](https://devdocs.io/about) page, and is ordered alphabetically. Simply copying an existing item, placing it in the right slot and updating the values to match the new scraper will do the job.
13. Ensure `thor updates:check [my_doc]` shows the correct latest version.

If the documentation includes more than a few hundreds pages and is available for download, try to scrape it locally (e.g. using `FileScraper`). It'll make the development process much faster and avoids putting too much load on the source site. (It's not a problem if your scraper is coupled to your local setup, just explain how it works in your pull request.)

Finally, try to document your scraper and filters' behavior as much as possible using comments (e.g. why some URLs are ignored, HTML markup removed, metadata that way, etc.). It'll make updating the documentation much easier.
