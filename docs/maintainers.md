# Maintainer's Guide

This document is intended for [DevDocs maintainers](#list-of-maintainers).

## Merging pull requests

- Unless the change is trivial or in an area that you are familiar with, PRs should be approved by at least two maintainers before being merged.

- PRs that add or update documentations should always be merged locally, and the app deployed, before the merge is pushed to GitHub.

  This workflow is required because there is a dependency between the local and production environments. The `thor docs:download` command downloads documentations from production files uploaded by the `thor docs:upload` command. If a PR adding a new documentation is merged and pushed to GitHub before the files have been uploaded to production, the `thor docs:download` will fail for the new documentation and the docker container will not build properly until the new documentation is deployed to production.

## Updating docs

The process for updating docs is as follow:

- Make version/release changes in the scraper file.
- If needed, update the copyright notice of the documentation in the scraper file (`options[:attribution]`) and the about page (`about_tmpl.coffee`). The copyright notice must be the same as the one on the original documentation.
- Run `thor docs:generate`.
- Make sure the documentation still works well. The `thor docs:generate` command outputs a summary of the changes, which helps identifying issues (e.g. deleted files) and new pages to check out in the app. Verify locally that everything works, especially the files that were created (if any), and that the categorization of entries is still good. Often, updates will require code changes to tweak some new markup in the source website or categorize new entries.
- Commit the changes (protip: use the `thor docs:commit` command documented below).
- Optional: do more updates.
- Run `thor docs:upload` (documented below).
- [Deploy the app](#deploying-devdocs) and verify that everything works in production.
- Push to GitHub.
- Run `thor docs:clean` (documented below).

Note: changes to `public/docs/docs.json` should never be committed. This file reflects which documentations have been downloaded or generated locally, which is always none on a fresh `git clone`.

## Setup requirements

In order to deploy DevDocs, you must:

- be given access to Heroku, [configure the Heroku CLI](https://devcenter.heroku.com/articles/heroku-cli) on your computer, and familiarize yourself with Heroku's UI and CLI, as well as that of New Relic (accessible through [the Heroku dashboard](https://dashboard.heroku.com/apps/devdocs)).

- be given access to DevDocs's [Sentry instance](https://sentry.io/devdocs/devdocs-js/) (for JS error tracking) and familiarize yourself with its UI.

- be provided with DevDocs's S3 credentials, and install (`brew install awscli` on macOS) and [configure](https://docs.aws.amazon.com/cli/latest/reference/configure/) the AWS CLI on your computer. The configuration must add a named profile called "devdocs":
  ```
  aws configure --profile devdocs
  ```

- be provided with DevDocs's MaxCDN push zone credentials, and add them to your `.bash_profile` as such:
  ```
  export DEVDOCS_DL_USERNAME="username"
  export DEVDOCS_DL_PASSWORD="password"
  ```

## Thor commands

In addition to the [publicly-documented commands](https://github.com/freeCodeCamp/devdocs#available-commands), the following commands are aimed at DevDocs maintainers:

- `thor docs:package`

  Generates packages for one or more documentations. Those packages are intended to be uploaded to DevDocs's MaxCDN push zone by maintainers via the `thor docs:upload` command, and downloaded by users via the `thor docs:download` command.

  Versions can be specified as such: `thor docs:package rails@5.2 node@10\ LTS`.

  Packages can also be automatically generated during the scraping process by passing the `--package` option to `thor docs:generate`.

- `thor docs:upload`
  
  This command does two operations:
  
    1. sync the files for the specified documentations with S3 (used by the Heroku app);
    2. upload the documentations' packages to DevDocs's MaxCDN push zone (used by the `thor docs:download` command).
  
  For the command to work, you must have the AWS CLI and MaxCDN credentials configured as indicated above.
  
  **Important:** the app should always be deployed immediately after this command has finished running. Do not run this command unless you are able and ready to deploy DevDocs.
  
  To upload all documentations that are packaged on your computer, run `thor docs:upload --packaged`.
  To test your configuration and the effect of this command without uploading anything, pass the `--dryrun` option.

- `thor docs:commit`

  Shortcut command to create a Git commit for a given documentation once it has been updated. Scraper and `assets/` file changes will be committed. The commit message will include the most recent version that the documentation was updated to. If some files were missed by the commit, use `git commit --amend` to add them to the commit. The command may be run before `thor docs:upload` is run, but the commit should not be pushed to GitHub before the files have been uploaded and the app deployed.

- `thor docs:clean`

  Shortcut command to delete all package files (once uploaded via `thor docs:upload`, they are not needed anymore).

## Deploying DevDocs

Once docs have been uploaded via `thor docs:upload` (if applicable), deploying DevDocs is as simple as running `git push heroku master`. See [Heroku's documentation](https://devcenter.heroku.com/articles/git) for more information.

- If you're deploying documentation updates, verify that the documentations work properly once the deploy is done (you will need to reload [devdocs.io](https://devdocs.io/) a couple times for the application cache to update and the new version to load).
- If you're deploying frontend changes, monitor [Sentry](https://sentry.io/devdocs/devdocs-js/) for new JS errors once the deploy is done.
- If you're deploying server changes, monitor New Relic (accessible through [the Heroku dashboard](https://dashboard.heroku.com/apps/devdocs)) for Ruby exceptions and throughput or response time changes once the deploy is done.

If any issue arises, run `heroku rollback` to rollback to the previous of the app (this can also be done via Heroku's UI). Note that this will not revert changes made to documentation files that were uploaded via `thor docs:upload`.  Try and fix the issue as quickly as possible, then re-deploy the app. Reach out to other maintainers if you need help.

If this is your first deploy, make sure another maintainer is around to assist. 

## List of maintainers

- [Beau Carnes](https://github.com/beaucarnes)
- [Jed Fox](https://github.com/j-f1)
- [Jasper van Merle](https://github.com/jmerle)
- [Thibaut Courouble](https://github.com/thibaut)

Interested in helping maintain DevDocs? Come talk to us on [Gitter](https://gitter.im/FreeCodeCamp/DevDocs) :)
