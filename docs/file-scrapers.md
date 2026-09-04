# File Scraper Reference

This lists the docs that use `FileScraper` and instructions for building some of them.

Most scrapers fetch their documents themselves — see `download_source` in
`lib/docs/core/scrapers/file_scraper.rb`. The sections below cover the ones that
still need the documents to be built or assembled by hand.

If you open a PR to update one of these docs, please add/fix the instructions.

## date-fns

```sh
git clone https://github.com/date-fns/date-fns docs/date_fns
cd docs/date_fns
git checkout v2.29.2
yarn install
node scripts/build/docs.js
ls tmp/docs.json
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

## Man

```sh
wget --recursive --no-parent https://man7.org/linux/man-pages/
mv man7.org/linux/man-pages/ docs/man/
```

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

For Scala 2 there is nothing to do — the scraper downloads and extracts the API
documentation into `docs/scala~$VERSION` automatically when it's missing.

Scala 3 has no official documentation download
(see https://contributors.scala-lang.org/t/5537) and has to be built by hand;
see the comment in `lib/docs/scrapers/scala.rb`.
