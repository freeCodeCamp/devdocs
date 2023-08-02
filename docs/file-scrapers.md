# File Scraper Reference

This lists the docs that use `FileScraper` and instructions for building some of them.

If you open a PR to update one of these docs, please add/fix the instructions.

## Dart

Click the “API docs” link under the “Stable channel” header on
https://www.dartlang.org/tools/sdk/archive. Rename the expanded ZIP to `dart~2`
and put it in `docs/`

Or run the following commands in your terminal:

```sh
curl https://storage.googleapis.com/dart-archive/channels/stable/release/$RELEASE/api-docs/dartdocs-gen-api.zip > dartApi.zip; \
unzip dartApi.zip; mv gen-dartdocs docs/dart~$VERSION
```

## date-fns

```sh
git clone https://github.com/date-fns/date-fns docs/date_fns
cd docs/date_fns
git checkout v2.29.2
yarn install
node scripts/build/docs.js
ls tmp/docs.json
```

## Django

Go to https://docs.djangoproject.com/, select the version from the
bubble in the bottom-right corner, then download the HTML version from the sidebar.

```sh
mkdir --parent docs/django\~$VERSION/; \
curl https://media.djangoproject.com/docs/django-docs-$VERSION-en.zip | \
bsdtar --extract --file - --directory=docs/django\~$VERSION/
```

## Elisp

Go to https://www.gnu.org/software/emacs/manual/elisp.html, download the HTML tarball and extract its content in `docs/elisp` or run the following command:

```sh
mkdir docs/elisp \
&& curl curl https://www.gnu.org/software/emacs/manual/elisp.html_node.tar.gz | \
tar --extract --gzip --strip-components=1 --directory=docs/elisp
```

## Erlang

Go to https://www.erlang.org/downloads and download the HTML documentation file.

```ah
mkdir --parent docs/erlang\~$VERSION/; \
curl -L https://github.com/erlang/otp/releases/download/OTP-$RELEASE/otp_doc_html_$RELEASE.tar.gz | \
bsdtar --extract --file - --directory=docs/erlang\~$VERSION/
```

## Gnu

### Bash
Go to https://www.gnu.org/software/bash/manual/, download the HTML tar file (with one web page per node) and extract its content in `docs/bash` or run the following command:

```sh
mkdir docs/bash \
&& curl https://www.gnu.org/software/bash/manual/bash.html_node.tar.gz | \
tar --extract --gzip --directory=docs/bash
```

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

## GNU Make
Go to https://www.gnu.org/software/make/manual/, download the HTML tarball and extract its content in `docs/gnu_make` or run the following command:

```sh
mkdir docs/gnu_make \
&& curl https://www.gnu.org/software/make/manual/make.html_node.tar.gz | \
tar --extract --gzip --strip-components=1 --directory=docs/gnu_make
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

```sh
mkdir --parent docs/numpy~$VERSION/; \
curl https://numpy.org/doc/$VERSION/numpy-html.zip | \
bsdtar --extract --file=- --directory=docs/numpy~$VERSION/
```

## OCaml

Download from https://www.ocaml.org/docs/ the HTML reference:
https://v2.ocaml.org/releases/4.14/ocaml-4.14-refman-html.tar.gz
and extract it as `docs/ocaml`:

```sh
curl https://v2.ocaml.org/releases/$VERSION/ocaml-$VERSION-refman-html.tar.gz | \
tar xz --transform 's/htmlman/ocaml/' --directory docs/
```

## OpenJDK
Search 'Openjdk' in https://www.debian.org/distrib/packages, find the `openjdk-$VERSION-doc` package,
download it, extract it with `dpkg -x $PACKAGE ./` and move `./usr/share/doc/openjdk-16-jre-headless/api/`
to `path/to/devdocs/docs/openjdk~$VERSION`

```
curl http://ftp.at.debian.org/debian/pool/main/o/openjdk-19/openjdk-19-doc_19+36-2_all.deb &&
tar xf openjdk-19-doc_19+36-2_all.deb
tar xf data.tar.xz
mv ./usr/share/doc/openjdk-19-jre-headless/api/ path/to/devdocs/docs/openjdk~$VERSION
```

If you use or have access to a Debian-based GNU/Linux distribution you can run the following command:
```sh
apt download openjdk-$VERSION-doc
dpkg -x $PACKAGE ./
# previous command makes a directory called 'usr' in the current directory
mv ./usr/share/doc/openjdk-16-jre-headless/api/ path/to/devdocs/docs/openjdk~$VERSION
```

## Pandas

```sh
curl https://pandas.pydata.org/docs/pandas.zip | bsdtar --extract --file - --directory=docs/pandas~1
```

## PHP
Click the link under the "Many HTML files" column on https://www.php.net/download-docs.php, extract the tarball, change its name to `php` and put it in `docs/`.

Or run the following commands in your terminal:

```sh
curl https://www.php.net/distributions/manual/php_manual_en.tar.gz > php.tar; \
tar -xf php.tar; mv php-chunked-xhtml/ docs/php/
```
## Python 3.6+

```sh
mkdir docs/python~$VERSION
cd docs/python~$VERSION
curl -L https://docs.python.org/$VERSION/archives/python-$RELEASE-docs-html.tar.bz2 | \
tar xj --strip-components=1
```

## Python < 3.6

```sh
mkdir docs/python~$VERSION
cd docs/python~$VERSION
curl -L https://docs.python.org/ftp/python/doc/$RELEASE/python-$RELEASE-docs-html.tar.bz2 | \
tar xj --strip-components=1
```

## R
```bash
DEVDOCSROOT=docs/r
RLATEST=https://cran.r-project.org/src/base/R-latest.tar.gz # or /R-${VERSION::1}/R-$VERSION.tar.gz

RSOURCEDIR=${TMPDIR:-/tmp}/R/latest
RBUILDDIR=${TMPDIR:-/tmp}/R/build
mkdir -p "$RSOURCEDIR" "$RBUILDDIR" "$DEVDOCSROOT"

# Download, configure, and build with static HTML pages
curl "$RLATEST" | tar -C "$RSOURCEDIR" -xzf - --strip-components=1
(cd "$RBUILDDIR" && "$RSOURCEDIR/configure" --enable-prebuilt-html --with-recommended-packages --disable-byte-compiled-packages --disable-shared --disable-java)
make _R_HELP_LINKS_TO_TOPICS_=FALSE -C "$RBUILDDIR"

# Export all html documentation built − global, and per-package
cp -r "$RBUILDDIR/doc" "$DEVDOCSROOT/"
ls -d "$RBUILDDIR"/library/*/html | while read orig; do
    dest="$DEVDOCSROOT${orig#$RBUILDDIR}"
    mkdir -p "$dest" && cp -r "$orig"/* "$dest/"
done
```

## RDoc

### Nokogiri
### Ruby / Minitest
### Ruby on Rails
* Download a release at https://github.com/rails/rails/releases or clone https://github.com/rails/rails.git (checkout to the branch of the rails' version that is going to be scraped)
* Open "railties/lib/rails/api/task.rb" and comment out any code related to sdoc ("configure_sdoc")
* Run "bundle install --without db && bundle exec rake rdoc" (in the Rails directory)
* Run "cd guides && bundle exec rake guides:generate:html"
* Copy the "guides/output" directory to "html/guides"
* Copy the "html" directory to "docs/rails~[version]"

### Ruby
Download the tarball of Ruby from https://www.ruby-lang.org/en/downloads/, extract it, run
`./configure && make html` in your terminal (while your are in the ruby directory) and move
`.ext/html` to `path/to/devdocs/docs/ruby~$VERSION/`.

Or run the following commands in your terminal:
```sh
curl https://cache.ruby-lang.org/pub/ruby/$VERSION/ruby-$RELEASE.tar.gz > ruby.tar; \
tar -xf ruby.tar; cd ruby-$RELEASE; ./configure && make html; mv .ext/html path/to/devdocs/docs/ruby~$VERSION
```

To generate the htmls file you have to run `make` command but it does not install Ruby in your system, only generates html files so you have not
to worry about cleaning or removing a new Ruby installation.

## Scala

See `lib/docs/scrapers/scala.rb`

## SQLite

Download the docs from https://sqlite.org/download.html, unzip it, and rename
it to `docs/sqlite`

```sh
curl https://sqlite.org/2022/sqlite-doc-3400000.zip | bsdtar --extract --file - --directory=docs/sqlite/ --strip-components=1
```
