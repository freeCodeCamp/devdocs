# Maintainer's Guide

This document is intended for [DevDocs maintainers](#list-of-maintainers).

## Merging pull requests

- PRs should be approved by at least one maintainer before being merged.

- PRs that add or update documentations should always be built and tested locally, and the doc files uploaded by the `thor docs:upload` command, before the PR is merged on GitHub.

  This workflow is required because there is a dependency between the local and production environments. The `thor docs:download` command downloads documentations from production files uploaded by the `thor docs:upload` command. If a PR adding a new documentation is merged and pushed to GitHub before the files have been uploaded to production, the `thor docs:download` will fail for the new documentation and the docker container will not build properly until the new documentation is deployed to production.

## Updating docs

The process for updating docs is as follow:

- Follow the checklist in [CONTRIBUTING.md#updating-existing-documentations](../.github/CONTRIBUTING.md#updating-existing-documentations).
- Commit the changes (protip: use the `thor docs:commit` command documented below).
- Optional: do more updates.
- Run `thor docs:upload` (documented below).
- Push to GitHub to [deploy the app](#deploying-devdocs) and verify that everything works in production.
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

## Thor commands

In addition to the [publicly-documented commands](https://github.com/freeCodeCamp/devdocs#available-commands), the following commands are aimed at DevDocs maintainers:

- `thor docs:package`

  Generates packages for one or more documentations. Those packages are intended to be uploaded to DevDocs's S3 bundle zone by maintainers via the `thor docs:upload` command, and downloaded by users via the `thor docs:download` command.

  Versions can be specified as such: `thor docs:package rails@5.2 node@10\ LTS`.

  Packages can also be automatically generated during the scraping process by passing the `--package` option to `thor docs:generate`.

- `thor docs:upload`
  
  This command does two operations:
  
    1. sync the files for the specified documentations with S3 (used by the Heroku app);
    2. upload the documentations' packages to DevDocs's S3 bundle zone (used by the `thor docs:download` command).
  
  For the command to work, you must have the AWS CLI configured as indicated above.
  
  **Important:** the app should always be deployed immediately after this command has finished running. Do not run this command unless you are able and ready to deploy DevDocs.
  
  To upload all documentations that are packaged on your computer, run `thor docs:upload --packaged`.
  To test your configuration and the effect of this command without uploading anything, pass the `--dryrun` option.

- `thor docs:commit`

  Shortcut command to create a Git commit for a given documentation once it has been updated. Scraper and `assets/` file changes will be committed. The commit message will include the most recent version that the documentation was updated to. If some files were missed by the commit, use `git commit --amend` to add them to the commit. The command may be run before `thor docs:upload` is run, but the commit should not be pushed to GitHub before the files have been uploaded and the app deployed.

- `thor docs:clean`

  Shortcut command to delete all package files (once uploaded via `thor docs:upload`, they are not needed anymore).

## Deploying DevDocs

Once docs have been uploaded via `thor docs:upload` (if applicable), you can push to the DevDocs master branch (or merge the PR containing the updates). If the Travis build succeeds, the Heroku application will be deployed automatically.

- If you're deploying documentation updates, verify that the documentations work properly once the deploy is done. Keep in mind that you'll need to wait a few seconds for the service worker to finish caching the new assets. You should see a "DevDocs has been updated" notification appear when the caching is done, after which you need to refresh the page to see the changes.
- If you're deploying frontend changes, monitor [Sentry](https://sentry.io/devdocs/devdocs-js/) for new JS errors once the deploy is done.
- If you're deploying server changes, monitor New Relic (accessible through [the Heroku dashboard](https://dashboard.heroku.com/apps/devdocs)) for Ruby exceptions and throughput or response time changes once the deploy is done.

If any issue arises, run `heroku rollback` to rollback to the previous version of the app (this can also be done via Heroku's UI). Note that this will not revert changes made to documentation files that were uploaded via `thor docs:upload`.  Try and fix the issue as quickly as possible, then re-deploy the app. Reach out to other maintainers if you need help.

If this is your first deploy, make sure another maintainer is around to assist. 

## Infrastructure

The bundled documents are available at downloads.devdocs.io and the documents themselves at documents.devdocs.io.  Download and document requests are proxied to S3 buckets devdocs-downloads.s3.amazonaws.com and devdocs-documents.s3.amazonaws.com respectively.

If there's ever a need to create a new proxy VM (and the `devdocs-proxy` snapshot is not available) then the new vm should be provisioned as follows:

```bash
# we need at least nginx 1.19.x
wget https://nginx.org/keys/nginx_signing.key
apt-key add nginx_signing.key
echo 'deb https://nginx.org/packages/mainline/ubuntu/ focal nginx' >> /etc/apt/sources.list
echo 'deb-src https://nginx.org/packages/mainline/ubuntu/ focal nginx' >> /etc/apt/sources.list
apt-get -y remove nginx-common
apt-get -y update
apt-get -y install nginx

# the config is on github
rm -rf /etc/nginx/*
rm -rf /etc/nginx/.* 2> /dev/null
git clone https://github.com/freeCodeCamp/devdocs-nginx-config.git /etc/nginx

# at this point we need to add the certs from Cloudflare and test the config
nginx -t 

# if nginx is already running, just 
# ps aux | grep nginx 
# find the number and kill it

nginx
```

## List of maintainers in alphabetical order

The following people (used to) maintain DevDocs:

- [Ahmad Abdolsaheb](https://github.com/ahmadabdolsaheb)
- [Jasper van Merle](https://github.com/jmerle)
- [Jed Fox](https://github.com/j-f1)
- [Mrugesh Mohapatra](https://github.com/raisedadead)
- [Oliver Eyton-Williams](https://github.com/ojeytonwilliams)
- [Simon Legner](https://github.com/simon04)
- [Thibaut Courouble](https://github.com/thibaut)

To reach out, please ping [@freeCodeCamp/devdocs](https://github.com/orgs/freeCodeCamp/teams/devdocs).

Interested in helping maintain DevDocs? Come talk to us on [Gitter](https://gitter.im/FreeCodeCamp/DevDocs) :)

In addition, we appreciate the major contributions made by [these great people](https://github.com/freeCodeCamp/devdocs/graphs/contributors).
