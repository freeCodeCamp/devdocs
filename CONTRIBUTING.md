# Contributing to DevDocs

Want to contribute? Great. Please review the following guidelines carefully and search for existing issues before opening a new one.

**Table of Contents:**

1. [Reporting bugs](#reporting-bugs)
2. [Requesting new features](#requesting-new-features)
3. [Requesting new documentations](#requesting-new-documentations)
4. [Contributing code and features](#contributing-code-and-features)
5. [Contributing new documentations](#contributing-new-documentations)
6. [Updating existing documentations](#updating-existing-documentations)
7. [Other contributions](#other-contributions)
8. [Coding conventions](#coding-conventions)
9. [Questions?](#questions)

## Reporting bugs

1. Update to the most recent master release; the bug may already be fixed.
2. Search for existing issues; it's possible someone has already encountered this bug.
3. Try to isolate the problem and include steps to reproduce it.
4. Share as much information as possible (e.g. browser/OS environment, log output, stack trace, screenshots, etc.).

## Requesting new features

1. Search for similar feature requests; someone may have already requested it.
2. Make sure your feature fits DevDocs's [vision](https://github.com/freeCodeCamp/devdocs/blob/master/README.md#vision).
3. Provide a clear and detailed explanation of the feature and why it's important to add it.

For general feedback and ideas, please use the [mailing list](https://groups.google.com/d/forum/devdocs).

## Requesting new documentations

Please don't open issues to request new documentations.  
Use the [Trello board](https://trello.com/b/6BmTulfx/devdocs-documentation) where everyone can vote.

## Contributing code and features

1. Search for existing issues; someone may already be working on a similar feature.
2. Before embarking on any significant pull request, please open an issue describing the changes you intend to make. Otherwise you risk spending a lot of time working on something I may not want to merge. This also tells other contributors that you're working on the feature.
3. Follow the [coding conventions](#coding-conventions).
4. If you're modifying the Ruby code, include tests and ensure they pass.
5. Try to keep your pull request small and simple.
6. When it makes sense, squash your commits into a single commit.
7. Describe all your changes in the commit message and/or pull request.

## Contributing new documentations

See the [wiki](https://github.com/freeCodeCamp/devdocs/wiki) to learn how to add new documentations.

**Important:** the documentation's license must permit alteration, redistribution and commercial use, and the documented software must be released under an open source license. Feel free to get in touch if you're not sure if a documentation meets those requirements.

In addition to the [guidelines for contributing code](#contributing-code-and-features), the following guidelines apply to pull requests that add a new documentation:

* Your documentation must come with an official icon, in both 1x and 2x resolutions (16x16 and 32x32 pixels). This is important because icons are the only thing differentiating search results in the UI.
* DevDocs favors quality over quantity. Your documentation should only include documents that most developers may want to read semi-regularly. By reducing the number of entries, we make it easier to find other, more relevant entries.
* Remove as much content and HTML markup as possible, particularly content not associated with any entry (e.g. introduction, changelog, etc.).
* Names must be as short as possible and unique across the documentation.
* The number of types (categories) should ideally be less than 100.
* Don't modify the icon sprite. I'll do it after your pull request is merged.

## Updating existing documentations

Please don't submit a pull request updating the version number of a documentation, unless a change is required in the scraper and you've verified that it works.

To ask that an existing documentation be updated, please use the [Trello board](https://trello.com/c/2B0hmW7M/52-request-updates-here).

## Other contributions

Besides new docs and features, here are other ways you can contribute:

* **Improve our copy.** English isn't my first language so if you notice grammatical or usage errors, feel free to submit a pull request — it'll be much appreciated.
* **Participate in the issue tracker.** Your opinion matters — feel free to add comments to existing issues. You're also welcome to participate to the [mailing list](https://groups.google.com/d/forum/devdocs).

## Coding conventions

* two spaces; no tabs
* no trailing whitespace; blank lines should have no spaces; new line at end-of-file
* use the same coding style as the rest of the codebase

## Questions?

If you have any questions, please feel free to ask on the [mailing list](https://groups.google.com/d/forum/devdocs).
