# Doc packs

A doc pack is documentation that anyone can publish and anyone can add to their own DevDocs, without it being part of DevDocs' catalog. Packs are added under **Preferences → Doc packs** by pasting the pack's address. They're stored in that browser only.

## Adding a pack

Paste one of:

- a GitHub repository: `github.com/owner/repo` (the default branch), or `github.com/owner/repo/tree/<branch>/<folder>` for a branch or a folder in it;
- any other HTTPS address of a folder holding a `docs.json`, such as a GitHub Pages site. The site has to let other sites read its files (the `Access-Control-Allow-Origin` header); GitHub and GitHub Pages do.

The pack's docs then appear in the doc list on the left of the preferences, where they're enabled, installed for offline use and updated like any other doc. The list of docs is downloaded again once a day. **Remove** takes a pack out, with its docs and their offline copies.

## What's in a pack

The same files DevDocs serves for its own docs:

```
docs.json               the docs in the pack
<slug>/index.json       the doc's entries and types, for search and the sidebar
<slug>/db.json          every page, by path, for offline use
<slug>/<path>.html      each page, for reading without installing
```

So the `public/docs` folder that `thor docs:generate <doc>` followed by `thor docs:manifest` produces is a pack as it is: publish it in a repository and add that repository.

`docs.json` is either an array of docs, as `thor docs:manifest` writes it, or an object with a `name` for the pack and the `docs` array:

```json
{
  "name": "Team notes",
  "docs": [
    {
      "name": "Dev Notes",
      "slug": "notes",
      "version": "2",
      "release": "2.1",
      "mtime": 1793255840,
      "db_size": 1556,
      "links": { "home": "https://example.com", "code": "https://github.com/owner/repo" },
      "attribution": "&copy; Someone. Licensed under CC BY 4.0."
    }
  ]
}
```

- `name` and `slug` are required. A slug is lower-case letters, digits, `_` and `.`, with an optional version after a `~` (`notes~2`); it's also the doc's folder name.
- `mtime` is when the doc was built. DevDocs offers an update to offline copies when it changes, so change it whenever the pages change.
- `db_size` is the size of `db.json` in bytes, shown on the offline page.
- `category` is where DevDocs lists the doc, in the sidebar and the preferences: one of `languages`, `web`, `frameworks`, `libraries`, `testing`, `tools`, `databases`, `ai`, `services` or `other` (the default). Typing a category's name in the search box and pressing Tab searches only its docs.
- `type` picks one of DevDocs' page styles; `simple` suits hand-written pages (section headings with bars, quotes shown as notes).

A doc is shown under its own slug plus the pack's code (e.g. `/notes_mi5a07/`), so a pack can't replace a built-in doc or a doc from another pack.

## Sharing a pack

Push it to a public GitHub repository and give the repository the topic `devdocs-pack` (the gear next to *About* on its page), so that it's listed at [github.com/topics/devdocs-pack](https://github.com/topics/devdocs-pack), where the preferences send people looking for packs.

## From Markdown documentation

Much documentation is written in Markdown in a public GitHub repository (GitHub's own docs, for instance, which docs.github.com is built from). The [pack builder](https://github.com/buggypather/devdocs-pack-builder) turns such a folder into a pack: copy the template repository, name the repository and folder in its `pack.config.json`, and a GitHub Actions workflow builds the pack, publishes it to the copy's `pack` branch and rebuilds it every week. The address to add in DevDocs is then `github.com/<you>/<copy>/tree/pack`.

It understands GitHub's Markdown extensions and alerts, front matter (titles, intros and page order) and the Liquid tags of GitHub's docs and other Jekyll sites. Check that the documentation's licence allows sharing it, and credit its authors in `attribution`.

## Writing a pack by hand

The example pack, [devdocs-pack-example](https://github.com/buggypather/devdocs-pack-example), builds `docs.json`, `index.json` and `db.json` from plain HTML pages with a small Node script (`node build.mjs`), which is enough for notes and small references. Its page "Writing pages" (`src/notes/guide/writing-pages.html`) is a template to copy.

## Safety

A pack's content comes from whoever published it, so DevDocs checks it before showing it:

- names, versions and attributions lose any markup;
- links have to be `http` or `https`;
- entries whose path could break out of a link are dropped;
- pages go through [DOMPurify](https://github.com/cure53/DOMPurify), which removes scripts, event handlers, `javascript:` links, forms and inline styles.

Only add packs from people you trust all the same: a pack can still contain wrong or misleading documentation.
