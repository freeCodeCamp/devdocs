# coding: utf-8
module Docs
  class GnuMake < FileScraper
    self.name = 'GNU Make'
    self.type = 'gnu_make'
    self.slug = 'gnu_make'
    self.release = '4.4'
    self.base_url= 'https://www.gnu.org/software/make/manual/html_node/'
    self.root_path = 'index.html'
    self.links = {
      home:'https://www.gnu.org/software/make/manual/html_node/',
      code: 'http://git.savannah.gnu.org/cgit/make.git/'
    }

    html_filters.push 'gnu_make/entries', 'gnu_make/clean_html'

    options[:skip] = [
      'Concept-Index.html',
      'Name-Index.html',
      'GNU-Free-Documentation-License.html'
    ]

    options[:attribution]= <<-HTML
      Copyright © 1988, 1989, 1990, 1991, 1992, 1993, 1994, 1995, 1996, 1997, 1998, 1999, 2000, 2002, 2003, 2004, 2005, 2006, 2007, 2008, 2009, 2010, 2011, 2012, 2013, 2014, 2015, 2016, 2017, 2018, 2019, 2020, 2021, 2022 Free Software Foundation, Inc. <br>
      Licensed under the GNU Free Documentation License.
    HTML

    def get_latest_version(opts)
      body = fetch("https://www.gnu.org/software/make/manual/html_node/", opts)
      body.scan(/version \d*\.?\d*/)[0].sub('version', '')
    end

  end
end
