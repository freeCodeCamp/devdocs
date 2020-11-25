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

Or run the following commands in your terminal:

```sh
curl https://storage.googleapis.com/dart-archive/channels/stable/release/$RELEASE/api-docs/dartdocs-gen-api-zip > dartApi.zip; \
unzip dartApi.zip; mv gen-dartdocs docs/dart~$VERSION
```
## Django

Go to https://docs.djangoproject.com/, select the version from the
bubble in the bottom-right corner, then download the HTML version from the sidebar.

```sh
mkdir --parent docs/django\~$VERSION/; \
curl https://media.djangoproject.com/docs/django-docs-$VERSION-en.zip | \
bsdtar --extract --file - --directory=docs/django\~$VERSION/
```

## Erlang

Go to https://www.erlang.org/downloads and download the HTML documentation file.

## Gnu

### GCC
Go to https://gcc.gnu.org/onlinedocs/ and download the HTML tarball of GCC Manual and GCC CPP manual or run the following commands to download the tarballs:

```sh
# GCC manual
mkdir docs/gcc~${VERSION}; \
curl https://gcc.gnu.org/onlinedocs/gcc-$RELEASE/gcc-html.tar.gz | \
tar --extract --gzip --strip-components=1 --directory=docs/gcc~${VERSION}

# GCC CPP manual
mkdir docs/gcc~${VERSION}_cpp; \
curl https://gcc.gnu.org/onlinedocs/gcc-$RELEASE/cpp-html.tar.gz | \
tar --extract --gzip --strip-components=1 --directory=docs/gcc~${VERSION}_cpp
```

### GNU Fortran
Go to https://gcc.gnu.org/onlinedocs/ and download the HTML tarball of Fortran manual or run the following commands to download the tarball:

```sh
mkdir docs/gnu_fortran~$VERSION; \
curl https://gcc.gnu.org/onlinedocs/gcc-$RELEASE/gfortran-html.tar.gz | \
tar --extract --gzip --strip-components=1 --directory=docs/gnu_fortran~$VERSION
```

## Gnuplot

The most recent release can be found near the bottom of
https://sourceforge.net/p/gnuplot/gnuplot-main/ref/master/tags/

```sh
DEVDOCS_ROOT=/path/to/devdocs
mkdir gnuplot-src $DEVDOCS_ROOT/docs/gnuplot
git clone -b $RELEASE --depth 1 https://git.code.sf.net/p/gnuplot/gnuplot-main ./gnuplot-src
cd gnuplot-src/
./prepare
./configure
cd docs/
make nofigures.tex
latex2html -html 5.0,math -split 4 -link 8 -long_titles 5 -dir $DEVDOCS_ROOT/docs/gnuplot -ascii_mode -no_auto_link nofigures.tex
```

To install `latex2html` on macOS: `brew install basictex latex2html`, then edit
`/usr/local/Cellar/latex2html/2019.2/l2hconf.pm` to include the path to LaTeX:

<details>

On line 21 (approximately):

```
#  Give the paths to latex and dvips on your system:
#
$LATEX = '/Library/TeX/texbin/latex';	# LaTeX
$PDFLATEX = '/Library/TeX/texbin/pdflatex';	# pdfLaTeX
$LUALATEX = '/Library/TeX/texbin/lualatex';	# LuaLaTeX
$DVILUALATEX = '/Library/TeX/texbin/dvilualatex';	# dviLuaLaTeX
$DVIPS = '/Library/TeX/texbin/dvips';	# dvips
$DVIPNG = '';	# dvipng
$PDFTOCAIRO = '/usr/local/bin/pdf2svg';	# pdf to svg converter
$PDFCROP = '';	# pdfcrop
$GS = '/usr/local/opt/ghostscript/bin/gs';	# GhostScript
```
</details>

## NumPy

## OpenJDK

https://packages.debian.org/sid/openjdk-11-doc

```sh
mkdir docs/openjdk~11
curl --remote-name http://ftp.debian.org/debian/pool/main/o/openjdk-11/openjdk-11-doc_11.0.9.1+1-1_all.deb
bsdtar --extract --to-stdout --file openjdk-11-doc_11.0.9.1+1-1_all.deb data.tar.xz | \
bsdtar --extract --xz --file - --strip-components=6 --directory=docs/openjdk\~11/ ./usr/share/doc/openjdk-11-jre-headless/api/
```

https://packages.debian.org/sid/openjdk-8-doc

```sh
mkdir docs/openjdk~8
curl --remote-name http://ftp.debian.org/debian/pool/main/o/openjdk-8/openjdk-8-doc_8u272-b10-1_all.deb
bsdtar --extract --to-stdout --file openjdk-8-doc_8u272-b10-1_all.deb data.tar.xz | \
bsdtar --extract --xz --file - --strip-components=6 --directory=docs/openjdk\~8/ ./usr/share/doc/openjdk-8-jre-headless/api/
```

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
