# File Scraper Reference

This lists the docs that use `FileScraper` and instructions for building some of them.

If you open a PR to update one of these docs, please add/fix the instructions.

## C

Download the HTML book from https://en.cppreference.com/w/Cppreference:Archives
and copy `reference/en/c` from the ZIP file into `/path/to/devdocs/docs/c`.

## C++

Download the HTML book from https://en.cppreference.com/w/Cppreference:Archives
and copy `reference/en/cpp` from the ZIP file into `/path/to/devdocs/docs/cpp`.

## Dart

Click the “API docs” link under the “Stable channel” header on
https://www.dartlang.org/tools/sdk/archive. Rename the expanded ZIP to `dart~2`
and put it in `/path/to/devdocs/docs/`

## Django

Go to https://docs.djangoproject.com/, select the version from the
bubble in the bottom-right corner, then download the HTML version from the sidebar.

## Erlang

Go to https://www.erlang.org/downloads and download the HTML documentation file.

## Gnu

### GCC
### GNU Fortran

## NumPy

## OpenJDK

## Perl

## PHP

## Python

### Versions 3.6+

```sh
mkdir docs/python~$VERSION
cd docs/python~$VERSION
curl -L https://docs.python.org/$VERSION/archives/python-$RELEASE-docs-html.tar.bz2 | \
tar xj --strip-components=1
```

### < 3.6

```sh
mkdir docs/python~$VERSION
cd docs/python~$VERSION
curl -L https://docs.python.org/ftp/python/doc/$RELEASE/python-$RELEASE-docs-html.tar.bz2 | \
tar xj --strip-components=1
```

## RDoc

### Nokogiri
### Ruby / Minitest
### Ruby on Rails
### Ruby

## Salt Stack

Replace `2019.2` with the correct tag.

```sh
git clone https://github.com/saltstack/salt.git --branch 2019.2 --depth 1
cd salt/doc
pip install sphinx
make html
```

The generated html is in `salt/doc/_build/html`. Copy it to

## Scala

See `lib/docs/scrapers/scala.rb`

## SQLite

Download the docs from https://sqlite.org/download.html, unzip it, and rename
it to `/path/to/devdocs/docs/sqlite`
