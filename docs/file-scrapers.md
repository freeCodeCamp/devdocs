# File Scraper Reference

This lists the docs that use `FileScraper` and instructions for building some of them.

If you open a PR to update one of these docs, please add/fix the instructions.

## Dart

Nothing to do — the scraper downloads and extracts the API docs into
`docs/dart~$VERSION` automatically when they're missing.

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

Nothing to do — the scraper downloads and extracts the HTML archive into
`docs/django~$VERSION` automatically when it's missing.

## Elisp

Nothing to do — the scraper downloads and extracts the HTML tarball into
`docs/elisp` automatically when it's missing.

## Erlang

Nothing to do — the scraper downloads and extracts the HTML documentation into
`docs/erlang~$VERSION` automatically when it's missing.

## es-toolkit

Nothing to do — the scraper downloads and extracts the release tarball into
`docs/es_toolkit` automatically when it's missing.

## Gnu

### Bash

Nothing to do — the scraper downloads and extracts the HTML tarball into
`docs/bash` automatically when it's missing.

### GCC

Nothing to do — the scraper downloads and extracts the GCC and GCC CPP manuals
into `docs/gcc~$VERSION` and `docs/gcc~${VERSION}_cpp` automatically when
they're missing.

### GNU Fortran

Nothing to do — the scraper downloads and extracts the manual into
`docs/gnu_fortran~$VERSION` automatically when it's missing.

## GNU Make

Nothing to do — the scraper downloads and extracts the HTML tarball into
`docs/gnu_make` automatically when it's missing.

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

## Man

```sh
wget --recursive --no-parent https://man7.org/linux/man-pages/
mv man7.org/linux/man-pages/ docs/man/
```

## NumPy

Nothing to do — the scraper downloads and extracts the HTML archive into
`docs/numpy~$VERSION` automatically when it's missing.

## OpenGL

Nothing to do — the scraper downloads the reference pages into
`docs/opengl~$VERSION` automatically when they're missing.

## OpenJDK
Search 'Openjdk' in https://www.debian.org/distrib/packages, find the `openjdk-$VERSION-doc` package,
download it, extract it with `dpkg -x $PACKAGE ./` and move `./usr/share/doc/openjdk-16-jre-headless/api/`
to `path/to/devdocs/docs/openjdk~$VERSION`

```sh
curl -O http://ftp.at.debian.org/debian/pool/main/o/openjdk-25/openjdk-25-doc_25+36-1_all.deb
tar xf openjdk-25-doc_25+36-1_all.deb
tar xf data.tar.xz
mv ./usr/share/doc/openjdk-25-jre-headless/api/ docs/openjdk~25
```

If you use or have access to a Debian-based GNU/Linux distribution you can run the following command:
```sh
apt download openjdk-$VERSION-doc
dpkg -x $PACKAGE ./
# previous command makes a directory called 'usr' in the current directory
mv ./usr/share/doc/openjdk-16-jre-headless/api/ docs/openjdk~$VERSION
```

## Pandas

Nothing to do — the scraper downloads and extracts the HTML archive into
`docs/pandas~$VERSION` automatically when it's missing.


## PHP

Nothing to do — the scraper downloads and extracts the manual into `docs/php`
automatically when it's missing.

## Python

Nothing to do — the scraper downloads and extracts the HTML archive into
`docs/python~$VERSION` automatically when it's missing.

## R

```bash
sudo dnf install bzip2-devel
sudo dnf install gcc-gfortran
sudo dnf install libcurl-devel
sudo dnf install texinfo
sudo dnf install xz-devel

DEVDOCSROOT=docs/r
RLATEST=https://cran.r-project.org/src/base/R-latest.tar.gz # or /R-${VERSION::1}/R-$VERSION.tar.gz

RSOURCEDIR=${TMPDIR:-/tmp}/R/latest
RBUILDDIR=${TMPDIR:-/tmp}/R/build
mkdir -p "$RSOURCEDIR" "$RBUILDDIR" "$DEVDOCSROOT"

# Download, configure, and build with static HTML pages
curl "$RLATEST" | tar -C "$RSOURCEDIR" -xzf - --strip-components=1
(cd "$RBUILDDIR" && "$RSOURCEDIR/configure" --enable-prebuilt-html --with-recommended-packages --disable-byte-compiled-packages --disable-shared --disable-java --with-readline=no --with-x=no)
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

```sh
git clone https://github.com/minitest/minitest
cd minitest/
echo -e "source 'https://rubygems.org'\n\ngem 'hoe'\ngem 'rdoc', '< 7'" > Gemfile
bundle install
bundle exec rake docs
cp -r docs $DEVDOCS/docs/minitest
```

### Ruby / Rack

```sh
git clone https://github.com/rack/rack
cd rack/
sed -i 's/gem "rdoc"/gem "rdoc", "<7"/' Gemfile
bundle install
bundle exec rdoc
cp -r doc $DEVDOCS/docs/rack
```

### Ruby on Rails
* Run `git clone --branch v$RELEASE --depth 7 https://github.com/rails/rails.git && cd rails`
* Open `railties/lib/rails/api/task.rb` and comment out any code related to sdoc (`configure_sdoc`)
* Run `bundle config set --local without 'db job'` (in the Rails directory)
* Run `bundle install && bundle exec rake rdoc` (in the Rails directory)
* Run `cd guides && bundle exec rake guides:generate:html && cd ..`
* Run `cp -r guides/output html/guides`
* Run `cp -r html $DEVDOCS/docs/rails~$VERSION`

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

## Three.js
Download the docs from https://github.com/mrdoob/three.js/tree/dev/files or run the following commands in your terminal:
Make sure to set the version per the release tag (e.g. r160). Note that the r prefix is already included, only the version number is needed.

```sh
curl https://codeload.github.com/mrdoob/three.js/tar.gz/refs/tags/r${VERSION} > threejs.tar.gz
tar -xzf threejs.tar.gz
mkdir -p docs/threejs~${VERSION}
mv three.js-r${VERSION}/list.json tmp/list.json
mv three.js-r${VERSION}/docs/* docs/threejs~${VERSION}/

rm -rf three.js-r${VERSION}/
rm threejs.tar.gz
```

## PowerShell

Nothing to do — the scraper downloads and extracts the reference for the version
it needs into `docs/powershell` automatically when it's missing.
