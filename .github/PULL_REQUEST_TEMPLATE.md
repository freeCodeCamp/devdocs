<!-- Remove the sections that don't apply to your PR. -->

<!-- Replace the `[ ]` with a `[x]` in checklists once you’ve completed each step. -->
<!-- Please create a draft PR when you haven't completed all steps yet upon creation of the PR. -->

<!-- SECTION A - Adding a new scraper -->
<!-- See https://github.com/freeCodeCamp/devdocs/blob/master/.github/CONTRIBUTING.md#contributing-new-documentations -->

If you’re adding a new scraper, please ensure that you have:

- [ ] Tested the scraper on a local copy of DevDocs
- [ ] Ensured that the docs are styled similarly to other docs on DevDocs
<!-- If the docs don’t have an icon, delete the next four items: -->
- [ ] Added these files to the <code>public/icons/*your_scraper_name*/</code> directory:
  - [ ] `16.png`: a 16×16 pixel icon for the doc
  - [ ] `16@2x.png`: a 32×32 pixel icon for the doc
  - [ ] `SOURCE`: A text file containing the URL to the page the image can be found on or the URL of the original image itself

<!-- SECTION B - Updating an existing documentation to it's latest version -->
<!-- See https://github.com/freeCodeCamp/devdocs/blob/master/.github/CONTRIBUTING.md#updating-existing-documentations -->

If you're updating an existing documentation to it's latest version, please ensure that you have:

- [ ] Updated the versions and releases in the scraper file
- [ ] Ensured the license is up-to-date and that the documentation's entry in the array in `about_tmpl.coffee` matches it's data in `self.attribution`
- [ ] Ensured the icons and the `SOURCE` file in <code>public/icons/*your_scraper_name*/</code> are up-to-date if the documentation has a custom icon
- [ ] Ensured `self.links` contains up-to-date urls if `self.links` is defined
- [ ] Tested the changes locally to ensure:
  - The scraper still works without errors
  - The scraped documentation still looks consistent with the rest of DevDocs
  - The categorization of entries is still good
