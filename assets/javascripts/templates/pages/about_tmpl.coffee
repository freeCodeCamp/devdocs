app.templates.aboutPage = -> """
  <nav class="_toc" role="directory">
    <h3 class="_toc-title">Table of Contents</h3>
    <ul class="_toc-list">
      <li><a href="#copyright">Copyright</a>
      <li><a href="#plugins">Plugins</a>
      <li><a href="#faq">FAQ</a>
      <li><a href="#credits">Credits</a>
      <li><a href="#privacy">Privacy Policy</a>
    </ul>
  </nav>

  <h1 class="_lined-heading">DevDocs: API Documentation Browser</h1>
  <p>DevDocs combines multiple developer documentations in a clean and organized web UI with instant search, offline support, mobile version, dark theme, keyboard shortcuts, and more.
  <p>DevDocs is free and <a href="https://github.com/freeCodeCamp/devdocs">open source</a>. It was created by <a href="https://thibaut.me">Thibaut Courouble</a> and is operated by <a href="https://www.freecodecamp.org/">freeCodeCamp</a>.
  <p>To keep up-to-date with the latest news:
  <ul>
    <li>Follow <a href="https://twitter.com/DevDocs">@DevDocs</a> on Twitter
    <li>Watch the repository on <a href="https://github.com/freeCodeCamp/devdocs/subscription">GitHub</a> <iframe class="_github-btn" src="https://ghbtns.com/github-btn.html?user=freeCodeCamp&repo=devdocs&type=watch&count=true" allowtransparency="true" frameborder="0" scrolling="0" width="100" height="20" tabindex="-1"></iframe>
    <li>Join the <a href="https://gitter.im/FreeCodeCamp/DevDocs">Gitter</a> chat room
  </ul>

  <h2 class="_block-heading" id="copyright">Copyright and License</h2>
  <p class="_note">
    <strong>Copyright 2013&ndash;2021 Thibaut Courouble and <a href="https://github.com/freeCodeCamp/devdocs/graphs/contributors">other contributors</a></strong><br>
    This software is licensed under the terms of the Mozilla Public License v2.0.<br>
    You may obtain a copy of the source code at <a href="https://github.com/freeCodeCamp/devdocs">github.com/freeCodeCamp/devdocs</a>.<br>
    For more information, see the <a href="https://github.com/freeCodeCamp/devdocs/blob/master/COPYRIGHT">COPYRIGHT</a>
    and <a href="https://github.com/freeCodeCamp/devdocs/blob/master/LICENSE">LICENSE</a> files.

  <h2 class="_block-heading" id="plugins">Plugins and Extensions</h2>
  <ul>
    <li><a href="https://chrome.google.com/webstore/detail/devdocs/mnfehgbmkapmjnhcnbodoamcioleeooe">Chrome web app</a>
    <li><a href="https://github.com/egoist/devdocs-app">Desktop app</a>
    <li><a href="https://sublime.wbond.net/packages/DevDocs">Sublime Text package</a>
    <li><a href="https://atom.io/packages/devdocs">Atom package</a>
    <li><a href="https://marketplace.visualstudio.com/items?itemName=deibit.devdocs">Visual Studio Code extension</a>
    <li><a href="https://github.com/yannickglt/alfred-devdocs">Alfred workflow</a>
    <li><a href="https://github.com/search?q=topic%3Adevdocs&type=Repositories">More…</a>
  </ul>

  <h2 class="_block-heading" id="faq">Questions & Answers</h2>
  <dl>
    <dt>Where can I suggest new docs and features?
    <dd>You can suggest and vote for new docs on the <a href="https://trello.com/b/6BmTulfx/devdocs-documentation">Trello board</a>.<br>
        If you have a specific feature request, add it to the <a href="https://github.com/freeCodeCamp/devdocs/issues">issue tracker</a>.<br>
        Otherwise, come talk to us in the <a href="https://gitter.im/FreeCodeCamp/DevDocs">Gitter</a> chat room.
    <dt>Where can I report bugs?
    <dd>In the <a href="https://github.com/freeCodeCamp/devdocs/issues">issue tracker</a>. Thanks!
  </dl>

  <h2 class="_block-heading" id="credits">Credits</h2>

  <p><strong>Special thanks to:</strong>
  <ul>
    <li><a href="https://out.devdocs.io/s/maxcdn">MaxCDN</a>, <a href="https://sentry.io/">Sentry</a> and <a href="https://get.gaug.es/?utm_source=devdocs&utm_medium=referral&utm_campaign=sponsorships" title="Real Time Web Analytics">Gauges</a> for offering a free account to DevDocs
    <li><a href="https://out.devdocs.io/s/maxcdn">MaxCDN</a>, <a href="https://out.devdocs.io/s/shopify">Shopify</a>, <a href="https://out.devdocs.io/s/jetbrains">JetBrains</a> and <a href="https://out.devdocs.io/s/code-school">Code School</a> for sponsoring DevDocs in the past
    <li><a href="https://www.heroku.com">Heroku</a> and <a href="https://newrelic.com/">New Relic</a> for providing awesome free service
    <li><a href="https://www.jeremykratz.com/">Jeremy Kratz</a> for the C/C++ logo
  </ul>

  <div class="_table">
    <table class="_credits">
      <tr>
        <th>Documentation
        <th>Copyright
        <th>License
      #{("<tr><td>#{c[0]}<td>&copy; #{c[1]}<td><a href=\"#{c[3]}\">#{c[2]}</a>" for c in credits).join('')}
    </table>
  </div>

  <h2 class="_block-heading" id="privacy">Privacy Policy</h2>
  <ul>
    <li><a href="https://devdocs.io">devdocs.io</a> ("App") is operated by <a href="https://www.freecodecamp.org/">freeCodeCamp</a> ("We").
    <li>We do not collect personal information through the app.
    <li>We use Google Analytics and Gauges to collect anonymous traffic information if you have given consent to this. You can change your decision in the <a href="/settings">settings</a>.
    <li>We use Sentry to collect crash data and improve the app.
    <li>The app uses cookies to store user preferences.
    <li>By using the app, you signify your acceptance of this policy. If you do not agree to this policy, please do not use the app.
    <li>If you have any questions regarding privacy, please email <a href="mailto:privacy@freecodecamp.org">privacy@freecodecamp.org</a>.
  </ul>
"""

credits = [
  [ 'Angular.js',
    '2010-2020 Google, Inc.',
    'CC BY 3.0',
    'https://creativecommons.org/licenses/by/3.0/'
  ], [
    'Angular',
    '2010-2020 Google, Inc.',
    'CC BY',
    'https://creativecommons.org/licenses/by/4.0/'
  ], [
    'Ansible',
    '2012-2018 Michael DeHaan<br>&copy; 2018–2019 Red Hat, Inc.',
    'GPLv3',
    'https://raw.githubusercontent.com/ansible/ansible/devel/COPYING'
  ], [
    'Apache HTTP Server<br>Apache Pig',
    '2018 The Apache Software Foundation<br>Apache and the Apache feather logo are trademarks of The Apache Software Foundation.',
    'Apache',
    'https://www.apache.org/licenses/LICENSE-2.0'
  ], [
    'Async',
    '2010-2018 Caolan McMahon',
    'MIT',
    'https://raw.githubusercontent.com/caolan/async/master/LICENSE'
  ], [
    'Babel',
    '2018 Sebastian McKenzie',
    'MIT',
    'https://raw.githubusercontent.com/babel/website/master/LICENSE'
  ], [
    'Backbone.js',
    '2010-2019 Jeremy Ashkenas, DocumentCloud',
    'MIT',
    'https://raw.githubusercontent.com/jashkenas/backbone/master/LICENSE'
  ], [
    'Bash',
    '2000, 2001, 2002, 2007, 2008 Free Software Foundation, Inc.',
    'GFDL',
    'https://www.gnu.org/licenses/fdl-1.3.en.html'
  ], [
    'Bluebird',
    '2013-2018 Petka Antonov',
    'MIT',
    'https://raw.githubusercontent.com/petkaantonov/bluebird/master/LICENSE'
  ], [
    'Bootstrap',
    '2011-2020 Twitter, Inc.<br>2011-2020 The Bootstrap Authors',
    'CC BY',
    'https://creativecommons.org/licenses/by/3.0/'
  ], [
    'Bottle',
    '2009-2017 Marcel Hellkamp',
    'MIT',
    'https://raw.githubusercontent.com/bottlepy/bottle/master/LICENSE'
  ], [
    'Bower',
    '2018 Bower contributors',
    'MIT',
    'https://github.com/bower/bower.github.io/blob/1057905c18d899106f91372e6cca7ef54a91d60f/package.json#L20'
  ], [
    'C<br>C++',
    'cppreference.com',
    'CC BY-SA',
    'http://en.cppreference.com/w/Cppreference:Copyright/CC-BY-SA'
  ], [
    'CakePHP',
    '2005-present The Cake Software Foundation, Inc.',
    'MIT',
    'https://raw.githubusercontent.com/cakephp/cakephp/master/LICENSE'
  ], [
    'Chai',
    '2017 Chai.js Assertion Library',
    'MIT',
    'https://raw.githubusercontent.com/chaijs/chai/master/LICENSE'
  ], [
    'Chef&trade;',
    'Chef Software, Inc.',
    'CC BY',
    'https://raw.githubusercontent.com/chef/chef-web-docs-2016/master/LICENSE'
  ], [
    'Clojure',
    'Rich Hickey',
    'EPL',
    'https://github.com/clojure/clojure/blob/master/epl-v10.html'
  ], [
    'CMake',
    '2000-2019 Kitware, Inc. and Contributors',
    'BSD',
    'https://cmake.org/licensing/'
  ], [
    'Codeception',
    '2011 Michael Bodnarchuk and contributors',
    'MIT',
    'https://raw.githubusercontent.com/Codeception/Codeception/master/LICENSE'
  ], [
    'CodeceptJS',
    '2015 DavertMik',
    'MIT',
    'https://raw.githubusercontent.com/Codeception/CodeceptJS/master/LICENSE'
  ], [
    'CodeIgniter',
    '2014-2020 British Columbia Institute of Technology',
    'MIT',
    'https://raw.githubusercontent.com/bcit-ci/CodeIgniter/develop/license.txt'
  ], [
    'CoffeeScript',
    '2009-2020 Jeremy Ashkenas',
    'MIT',
    'https://raw.githubusercontent.com/jashkenas/coffeescript/master/LICENSE'
  ], [
    'Composer',
    'Nils Adermann, Jordi Boggiano',
    'MIT',
    'https://raw.githubusercontent.com/composer/composer/master/LICENSE'
  ], [
    'Cordova',
    '2012, 2013, 2015 The Apache Software Foundation',
    'Apache',
    'https://raw.githubusercontent.com/apache/cordova-docs/master/LICENSE'
  ], [
    'CSS<br>DOM<br>HTTP<br>HTML<br>JavaScript<br>SVG<br>XPath',
    '2005-2020 Mozilla and individual contributors',
    'CC BY-SA',
    'https://creativecommons.org/licenses/by-sa/2.5/'
  ], [
    'Crystal',
    '2012-2020 Manas Technology Solutions',
    'Apache',
    'https://raw.githubusercontent.com/crystal-lang/crystal/master/LICENSE'
  ], [
    'Cypress',
    '2017 Cypress.io',
    'MIT',
    'https://raw.githubusercontent.com/cypress-io/cypress-documentation/develop/LICENSE.md'
  ], [
    'D',
    '1999-2021 The D Language Foundation',
    'Boost',
    'https://raw.githubusercontent.com/dlang/phobos/master/LICENSE_1_0.txt'
  ], [
    'D3.js',
    '2010-2020 Michael Bostock',
    'BSD',
    'https://raw.githubusercontent.com/d3/d3/master/LICENSE'
  ], [
    'Dart',
    '2012 the Dart project authors',
    'CC BY-SA',
    'https://creativecommons.org/licenses/by-sa/4.0/'
  ], [
    'Django',
    'Django Software Foundation and individual contributors',
    'BSD',
    'https://raw.githubusercontent.com/django/django/master/LICENSE'
  ], [
    'Django REST Framework',
    '2011-present Encode OSS Ltd.',
    'BSD',
    'https://raw.githubusercontent.com/encode/django-rest-framework/master/LICENSE.md'
  ], [
    'Docker',
    '2019 Docker, Inc.<br>Docker and the Docker logo are trademarks of Docker, Inc.',
    'Apache',
    'https://raw.githubusercontent.com/docker/docker.github.io/master/LICENSE'
  ], [
    'Dojo',
    '2005-2017 JS Foundation',
    'BSD + AFL',
    'http://dojotoolkit.org/license.html'
  ], [
    'Drupal',
    '2001-2015 by the original authors<br>Drupal is a registered trademark of Dries Buytaert.',
    'GPLv2',
    'https://api.drupal.org/api/drupal/LICENSE.txt'
  ], [
    'Electron',
    'GitHub Inc.',
    'MIT',
    'https://raw.githubusercontent.com/electron/electron/master/LICENSE'
  ], [
    'Elixir',
    '2012 Plataformatec',
    'Apache',
    'https://raw.githubusercontent.com/elixir-lang/elixir/master/LICENSE'
  ], [
    'Elisp',
    '1990-1996, 1998-2019 Free Software Foundation, Inc.',
    'GPLv3',
    'https://www.gnu.org/licenses/gpl-3.0.html'
  ], [
    'Ember.js',
    '2020 Yehuda Katz, Tom Dale and Ember.js contributors',
    'MIT',
    'https://raw.githubusercontent.com/emberjs/ember.js/master/LICENSE'
  ], [
    'Enzyme',
    '2015 Airbnb, Inc.',
    'MIT',
    'https://raw.githubusercontent.com/airbnb/enzyme/master/LICENSE.md'
  ], [
    'Erlang',
    '2010-2020 Ericsson AB',
    'Apache',
    'https://raw.githubusercontent.com/erlang/otp/maint/LICENSE.txt'
  ], [
    'ESLint',
    'JS Foundation and other contributors',
    'MIT',
    'https://raw.githubusercontent.com/eslint/eslint/master/LICENSE'
  ], [
    'Express',
    '2017 StrongLoop, IBM, and other expressjs.com contributors.',
    'CC BY-SA',
    'https://raw.githubusercontent.com/expressjs/expressjs.com/gh-pages/LICENSE.md'
  ], [
    'Falcon',
    '2019 by Falcon contributors',
    'Apache',
    'https://raw.githubusercontent.com/falconry/falcon/master/LICENSE'
  ], [
    'Fish',
    '2005-2009 Axel Liljencrantz, 2009-2020 fish-shell contributors',
    'GPLv2',
    'https://fishshell.com/docs/current/license.html'
  ], [
    'Flask',
    '2007-2020 Pallets',
    'BSD',
    'https://github.com/pallets/flask/blob/master/LICENSE.rst'
  ], [
    'GCC<br>GNU Fortran',
    'Free Software Foundation',
    'GFDL',
    'https://www.gnu.org/licenses/fdl-1.3.en.html'
  ], [
    'Git',
    '2012-2018 Scott Chacon and others',
    'MIT',
    'https://raw.githubusercontent.com/git/git-scm.com/master/MIT-LICENSE.txt'
  ], [
    'GnuCOBOL',
    'Free Software Foundation',
    'GFDL',
    'https://www.gnu.org/licenses/fdl-1.3.en.html'
  ], [
    'Gnuplot',
    'Copyright 1986 - 1993, 1998, 2004 Thomas Williams, Colin Kelley',
    'gnuplot license',
    'https://sourceforge.net/p/gnuplot/gnuplot-main/ci/master/tree/Copyright'
  ], [
    'Go',
    'Google, Inc.',
    'CC BY',
    'https://creativecommons.org/licenses/by/3.0/'
  ], [
    'Godot',
    '2014-2020 Juan Linietsky, Ariel Manzur, Godot Engine contributors',
    'MIT',
    'https://raw.githubusercontent.com/godotengine/godot/master/LICENSE.txt'
  ], [
    'Graphite',
    '2008-2012 Chris Davis<br>&copy; 2011-2016 The Graphite Project',
    'Apache',
    'https://raw.githubusercontent.com/graphite-project/graphite-web/master/LICENSE'
  ], [
    'Groovy',
    '2003-2020 The Apache Software Foundation',
    'Apache',
    'https://github.com/apache/groovy-website/blob/asf-site/LICENSE'
  ], [
    'Grunt',
    'GruntJS Team',
    'MIT',
    'https://github.com/gruntjs/grunt-docs/blob/master/package.json#L10'
  ], [
    'GTK',
    'The GNOME Project',
    'LGPLv2.1+',
    'https://gitlab.gnome.org/GNOME/gtk/-/blob/master/COPYING'
  ], [
    'Handlebars',
    '2011-2017 Yehuda Katz',
    'MIT',
    'https://raw.githubusercontent.com/wycats/handlebars.js/master/LICENSE'
  ], [
    'HAProxy',
    '2020 Willy Tarreau, HAProxy contributors',
    'GPLv2',
    'https://raw.githubusercontent.com/haproxy/haproxy/master/LICENSE'
  ], [
    'Haskell',
    'The University of Glasgow',
    'BSD',
    'https://www.haskell.org/ghc/license'
  ], [
    'Haxe',
    '2005-2018 Haxe Foundation',
    'MIT',
    'https://haxe.org/foundation/open-source.html'
  ], [
    'Homebrew',
    '2009-present Homebrew contributors',
    'BSD',
    'https://raw.githubusercontent.com/Homebrew/brew/master/LICENSE.txt'
  ], [
    'Immutable.js',
    '2014-2016 Facebook, Inc.',
    'BSD',
    'https://raw.githubusercontent.com/facebook/immutable-js/master/LICENSE'
  ], [
    'InfluxData',
    '2015 InfluxData, Inc.',
    'MIT',
    'https://github.com/influxdata/docs.influxdata.com/blob/master/LICENSE'
  ], [
    'Jasmine',
    '2008-2019 Pivotal Labs',
    'MIT',
    'https://raw.githubusercontent.com/jasmine/jasmine/master/MIT.LICENSE'
  ], [
    'Jekyll',
    '2020 Jekyll Core Team and contributors',
    'MIT',
    'https://raw.githubusercontent.com/jekyll/jekyll/master/LICENSE'
  ], [
    'Jest',
    '2020 Facebook, Inc.',
    'MIT',
    'https://raw.githubusercontent.com/facebook/jest/master/LICENSE'
  ], [
    'Jinja',
    '2007-2020 Pallets',
    'BSD',
    'https://github.com/pallets/jinja/blob/master/LICENSE.rst'
  ], [
    'jQuery',
    'Packt Publishing<br>&copy; jQuery Foundation and other contributors',
    'MIT',
    'https://raw.githubusercontent.com/jquery/api.jquery.com/master/LICENSE.txt'
  ], [
    'jQuery Mobile',
    'jQuery Foundation and other contributors',
    'MIT',
    'https://raw.githubusercontent.com/jquery/api.jquerymobile.com/master/LICENSE.txt'
  ], [
    'jQuery UI',
    'jQuery Foundation and other contributors',
    'MIT',
    'https://raw.githubusercontent.com/jquery/api.jqueryui.com/master/LICENSE.txt'
  ], [
    'Julia',
    '2009-2020 Jeff Bezanson, Stefan Karpinski, Viral B. Shah, and other contributors',
    'MIT',
    'https://raw.githubusercontent.com/JuliaLang/julia/master/LICENSE.md'
  ], [
    'JSDoc',
    '2011-2017 the contributors to the JSDoc 3 documentation project',
    'CC BY-SA',
    'https://raw.githubusercontent.com/jsdoc3/jsdoc3.github.com/master/LICENSE'
  ], [
    'Knockout.js',
    'Steven Sanderson, the Knockout.js team, and other contributors',
    'MIT',
    'https://raw.githubusercontent.com/knockout/knockout/master/LICENSE'
  ], [
    'Koa',
    '2020 Koa contributors',
    'MIT',
    'https://raw.githubusercontent.com/koajs/koa/master/LICENSE'
  ], [
    'Kotlin',
    '2010-2020 JetBrains s.r.o. and Kotlin Programming Language contributors',
    'Apache',
    'https://raw.githubusercontent.com/JetBrains/kotlin/master/license/LICENSE.txt'
  ], [
    'Laravel',
    'Taylor Otwell',
    'MIT',
    'https://raw.githubusercontent.com/laravel/framework/master/LICENSE.txt'
  ], [
    'Leaflet',
    '2010-2019 Vladimir Agafonkin<br>&copy; 2010-2011, CloudMade<br>Maps &copy; OpenStreetMap contributors.',
    'BSD',
    'https://raw.githubusercontent.com/Leaflet/Leaflet/master/LICENSE'
  ], [
    'Less',
    '2009-2020 The Core Less Team',
    'CC BY',
    'https://creativecommons.org/licenses/by/3.0/'
  ], [
    'Liquid',
    '2005, 2006 Tobias Luetke',
    'MIT',
    'https://raw.githubusercontent.com/Shopify/liquid/master/LICENSE'
  ], [
    'Lo-Dash',
    'JS Foundation and other contributors',
    'MIT',
    'https://raw.githubusercontent.com/lodash/lodash/master/LICENSE'
  ], [
    'Lua',
    '1994–2020 Lua.org, PUC-Rio',
    'MIT',
    'http://www.lua.org/license.html'
  ], [
    'L&Ouml;VE',
    '2006-2020 L&Ouml;VE Development Team',
    'GFDL',
    'http://www.gnu.org/copyleft/fdl.html'
  ], [
    'MariaDB',
    '2019 MariaDB',
    'CC BY-SA & GFDL',
    'https://mariadb.com/kb/en/library/documentation/+license/'
  ], [
    'Marionette.js',
    '2017 Muted Solutions, LLC',
    'MIT',
    'https://mutedsolutions.mit-license.org/'
  ], [
    'Markdown',
    '2004 John Gruber',
    'BSD',
    'https://daringfireball.net/projects/markdown/license'
  ], [
    'Matplotlib',
    '2012-2020 Matplotlib Development Team. All rights reserved.',
    'Custom',
    'https://raw.githubusercontent.com/matplotlib/matplotlib/master/LICENSE/LICENSE'
  ], [
    'Meteor',
    '2011-2017 Meteor Development Group, Inc.',
    'MIT',
    'https://raw.githubusercontent.com/meteor/meteor/master/LICENSE'
  ], [
    'Minitest',
    'Ryan Davis, seattle.rb',
    'MIT',
    'https://github.com/seattlerb/minitest/blob/master/README.rdoc#license'
  ], [
    'Mocha',
    '2011-2018 JS Foundation and contributors',
    'CC BY',
    'https://creativecommons.org/licenses/by/4.0/'
  ], [
    'Modernizr',
    '2009-2020 The Modernizr team',
    'MIT',
    'https://modernizr.com/license/'
  ], [
    'Moment.js',
    'JS Foundation and other contributors',
    'MIT',
    'https://raw.githubusercontent.com/moment/moment/master/LICENSE'
  ], [
    'Mongoose',
    '2010 LearnBoost',
    'MIT',
    'https://github.com/LearnBoost/mongoose/blob/master/README.md#license'
  ], [
    'nginx',
    '2002-2020 Igor Sysoev<br>&copy; 2011-2020 Nginx, Inc.',
    'BSD',
    'http://nginx.org/LICENSE'
  ], [
    'nginx / Lua Module',
    '2009-2017 Xiaozhe Wang (chaoslawful)<br>&copy; 2009-2018 Yichun "agentzh" Zhang (章亦春), OpenResty Inc.',
    'BSD',
    'https://github.com/openresty/lua-nginx-module#copyright-and-license'
  ], [
    'Nim',
    '2006-2020 Andreas Rumpf',
    'MIT',
    'https://github.com/nim-lang/Nim#license'
  ], [
    'Node.js',
    'Joyent, Inc. and other Node contributors<br>Node.js is a trademark of Joyent, Inc.',
    'MIT',
    'https://raw.githubusercontent.com/nodejs/node/master/LICENSE'
  ], [
    'Nokogiri',
    '2008-2018 Aaron Patterson, Mike Dalessio, Charles Nutter, Sergio Arbeo, Patrick Mahoney, Yoko Harada, Akinori MUSHA, John Shahid, Lars Kanis',
    'MIT',
    'https://raw.githubusercontent.com/sparklemotion/nokogiri/master/LICENSE.md'
  ], [
    'npm',
    'npm, Inc. and Contributors<br>npm is a trademark of npm, Inc.',
    'npm',
    'https://raw.githubusercontent.com/npm/npm/master/LICENSE'
  ], [
    'NumPy',
    '2005-2021 NumPy Developers',
    'BSD',
    'https://raw.githubusercontent.com/numpy/numpy/master/LICENSE.txt'
  ], [
    'OCaml',
    '1995-2021 INRIA',
    'CC BY-SA',
    'https://ocaml.org/docs/'
  ], [
    'Octave',
    '1996-2018 John W. Eaton',
    'Octave',
    'https://octave.org/doc/interpreter/'
  ], [
    'OpenJDK',
    '1993, 2020, Oracle and/or its affiliates. All rights reserved.<br>Licensed under the GNU General Public License, version 2, with the Classpath Exception.<br>Various third party code in OpenJDK is licensed under different licenses.<br>Java and OpenJDK are trademarks or registered trademarks of Oracle and/or its affiliates.',
    'GPLv2',
    'http://openjdk.java.net/legal/gplv2+ce.html'
  ], [
    'OpenTSDB',
    '2010-2016 The OpenTSDB Authors',
    'LGPLv2.1',
    'https://raw.githubusercontent.com/OpenTSDB/opentsdb.net/gh-pages/COPYING.LESSER'
  ], [
    'Padrino',
    '2010-2020 Padrino',
    'MIT',
    'https://raw.githubusercontent.com/padrino/padrino-framework/master/padrino/LICENSE.txt'
  ], [
    'pandas',
    '2008-2020, AQR Capital Management, LLC, Lambda Foundry, Inc. and PyData Development Team',
    'BSD',
    'https://raw.githubusercontent.com/pydata/pandas/master/LICENSE'
  ], [
    'Perl',
    '1993-2020 Larry Wall and others',
    'GPLv1',
    'https://perldoc.perl.org/index-licence.html'
  ], [
    'Phalcon',
    '2011-2017 Phalcon Framework Team',
    'CC BY',
    'https://docs.phalconphp.com/en/latest/reference/license.html'
  ], [
    'Phaser',
    '2016 Richard Davey, Photon Storm Ltd.',
    'MIT',
    'https://raw.githubusercontent.com/photonstorm/phaser/master/license.txt'
  ], [
    'Phoenix',
    '2014 Chris McCord',
    'MIT',
    'https://raw.githubusercontent.com/phoenixframework/phoenix/master/LICENSE.md'
  ], [
    'PHP',
    '1997-2018 The PHP Documentation Group',
    'CC BY',
    'https://secure.php.net/manual/en/copyright.php'
  ], [
    'PHPUnit',
    '2005-2017 Sebastian Bergmann',
    'CC BY',
    'https://creativecommons.org/licenses/by/3.0/'
  ], [
    'Pony',
    '2016-2020, The Pony Developers & 2014-2015, Causality Ltd.',
    'BSD',
    'https://raw.githubusercontent.com/ponylang/ponyc/master/LICENSE'
  ], [
    'PostgreSQL',
    '1996-2020 The PostgreSQL Global Development Group<br>&copy; 1994 The Regents of the University of California',
    'PostgreSQL',
    'https://www.postgresql.org/about/licence/'
  ], [
    'Puppeteer',
    '2021 Google Inc',
    'Apache',
    'https://raw.githubusercontent.com/puppeteer/puppeteer/master/LICENSE'
  ], [
    'Pygame',
    'Pygame Developers',
    'LGPLv2.1',
    'https://raw.githubusercontent.com/pygame/pygame/master/LICENSE'
  ], [
    'Python',
    '2001-2020 Python Software Foundation<br>Python is a trademark of the Python Software Foundation.',
    'PSFL',
    'https://docs.python.org/3/license.html'
  ], [
    'PyTorch',
    '2019 Torch Contributors',
    'BSD',
    'https://raw.githubusercontent.com/pytorch/pytorch/master/LICENSE'
  ], [
    'Q',
    '2009-2017 Kristopher Michael Kowal',
    'MIT',
    'https://raw.githubusercontent.com/kriskowal/q/master/LICENSE'
  ], [
    'Qt',
    '2012-2018 The Qt Company Ltd',
    'GFDL',
    'https://doc.qt.io/qt-5/licensing.html'
  ], [
    'Ramda',
    '2013-2020 Scott Sauyet and Michael Hurley',
    'MIT',
    'https://raw.githubusercontent.com/ramda/ramda/master/LICENSE.txt'
  ], [
    'React, React Native, Flow, Relay',
    '2013-present Facebook Inc.',
    'MIT',
    'https://raw.githubusercontent.com/facebook/react/master/LICENSE'
  ], [
    'React Bootstrap',
    '2014-present Stephen J. Collings, Matthew Honnibal, Pieter Vanderwerff',
    'MIT',
    'https://raw.githubusercontent.com/react-bootstrap/react-bootstrap/master/LICENSE'
  ], [
    'ReactiveX',
    'ReactiveX contributors',
    'Apache',
    'https://raw.githubusercontent.com/ReactiveX/reactivex.github.io/develop/LICENSE'
  ], [
    'Redis',
    '2009-2020 Salvatore Sanfilippo',
    'CC BY-SA',
    'https://creativecommons.org/licenses/by-sa/4.0/'
  ], [
    'Redux',
    '2015-2020 Dan Abramov',
    'MIT',
    'https://raw.githubusercontent.com/reactjs/redux/master/LICENSE.md'
  ], [
    'RequireJS',
    'jQuery Foundation and other contributors',
    'MIT',
    'https://raw.githubusercontent.com/requirejs/requirejs/master/LICENSE'
  ], [
    'RethinkDB',
    'RethinkDB contributors',
    'CC BY-SA',
    'https://raw.githubusercontent.com/rethinkdb/docs/master/LICENSE'
  ], [
    'Ruby',
    '1993-2017 Yukihiro Matsumoto',
    'Ruby',
    'https://www.ruby-lang.org/en/about/license.txt'
  ], [
    'Ruby on Rails',
    '2004-2020 David Heinemeier Hansson<br>Rails, Ruby on Rails, and the Rails logo are trademarks of David Heinemeier Hansson.',
    'MIT',
    'https://raw.githubusercontent.com/rails/rails/master/activerecord/MIT-LICENSE'
  ], [
    'Rust',
    '2010 The Rust Project Developers',
    'MIT',
    'https://raw.githubusercontent.com/rust-lang/book/master/LICENSE-MIT'
  ], [
    'RxJS',
    '2015-2018 Google, Inc., Netflix, Inc., Microsoft Corp. and contributors',
    'Apache',
    'https://raw.githubusercontent.com/ReactiveX/rxjs/master/LICENSE.txt'
  ], [
    'Salt Stack',
    '2019 SaltStack',
    'Apache',
    'https://raw.githubusercontent.com/saltstack/salt/develop/LICENSE'
  ], [
    'Sass',
    '2006-2020 Hampton Catlin, Nathan Weizenbaum, and Chris Eppstein',
    'MIT',
    'https://raw.githubusercontent.com/sass/sass/stable/MIT-LICENSE'
  ], [
    'Scala',
    '2002-2019 EPFL, with contributions from Lightbend',
    'Apache',
    'https://raw.githubusercontent.com/scala/scala-lang/master/license.md'
  ], [
    'scikit-image',
    '2019 the scikit-image team',
    'BSD',
    'https://scikit-image.org/docs/dev/license.html'
  ], [
    'scikit-learn',
    '2007-2020 The scikit-learn developers',
    'BSD',
    'https://raw.githubusercontent.com/scikit-learn/scikit-learn/master/COPYING'
  ], [
    'Sinon',
    '2010-2018 Christian Johansen',
    'BSD',
    'https://raw.githubusercontent.com/sinonjs/sinon/master/LICENSE'
  ], [
    'Sequelize',
    '2014—present Sequelize contributors',
    'MIT',
    'https://raw.githubusercontent.com/sequelize/sequelize/master/LICENSE'
  ], [
    'Socket.io',
    '2014-2018 Automattic',
    'MIT',
    'https://raw.githubusercontent.com/Automattic/socket.io/master/LICENSE'
  ], [
    'SQLite',
    'n/a',
    'Public Domain',
    'https://sqlite.org/copyright.html'
  ], [
    'Statsmodels',
    '2009-2012 Statsmodels Developers<br>&copy; 2006-2008 Scipy Developers<br>&copy; 2006 Jonathan E. Taylor',
    'BSD',
    'https://raw.githubusercontent.com/statsmodels/statsmodels/master/LICENSE.txt'
  ], [
    'Symfony',
    '2004-2017 Fabien Potencier',
    'MIT',
    'https://symfony.com/doc/current/contributing/code/license.html'
  ], [
    'Tcl/Tk',
    'The Regents of the University of California, Sun Microsystems, Inc., Scriptics Corporation, and other parties',
    'Tcl/Tk',
    'http://tcl.tk/software/tcltk/license.html'
  ], [
    'TensorFlow',
    '2020 The TensorFlow Authors',
    'CC BY',
    'https://creativecommons.org/licenses/by/4.0/'
  ], [
    'Terraform',
    '2018 HashiCorp',
    'MPL',
    'https://raw.githubusercontent.com/hashicorp/terraform-website/master/LICENSE.md'
  ], [
    'Trio',
    '2017 Nathaniel J. Smith',
    'MIT',
    'https://raw.githubusercontent.com/python-trio/trio/master/LICENSE.MIT'
  ], [
    'Twig',
    '2009-2020 The Twig Team',
    'BSD',
    'https://twig.symfony.com/license'
  ], [
    'TypeScript',
    '2012-2021 Microsoft',
    'Apache',
    'https://raw.githubusercontent.com/Microsoft/TypeScript-Handbook/master/LICENSE'
  ], [
    'Underscore.js',
    '2009-2020 Jeremy Ashkenas, DocumentCloud and Investigative Reporters & Editors',
    'MIT',
    'https://raw.githubusercontent.com/jashkenas/underscore/master/LICENSE'
  ], [
    'Vagrant',
    '2010-2018 Mitchell Hashimoto',
    'MPL',
    'https://raw.githubusercontent.com/mitchellh/vagrant/master/website/LICENSE.md'
  ], [
    'Vue Router',
    '2013-present Evan You',
    'MIT',
    'https://raw.githubusercontent.com/vuejs/vue-router/dev/LICENSE'
  ], [
    'Vue.js',
    '2013-present Yuxi Evan You',
    'MIT',
    'https://raw.githubusercontent.com/vuejs/vuejs.org/master/LICENSE'
  ], [
    'Vuex',
    '2015-present Evan You',
    'MIT',
    'https://raw.githubusercontent.com/vuejs/vuex/dev/LICENSE'
  ], [
    'Vulkan',
    '2014-2017 Khronos Group Inc.<br>Vulkan and the Vulkan logo are registered trademarks of the Khronos Group Inc.',
    'CC BY',
    'https://creativecommons.org/licenses/by/4.0/'
  ], [
    'webpack',
    'JS Foundation and other contributors',
    'CC BY',
    'https://creativecommons.org/licenses/by/4.0/'
  ], [
    'Werkzeug',
    '2007-2020 Pallets',
    'BSD',
    'https://github.com/pallets/werkzeug/blob/master/LICENSE.rst'
  ], [
    'Wordpress',
    '2003-2021 WordPress Foundation',
    'GPLv2+',
    'https://wordpress.org/about/license/'
  ], [
    'Yarn',
    '2016-present Yarn Contributors',
    'BSD',
    'https://raw.githubusercontent.com/yarnpkg/yarn/master/LICENSE'
  ], [
    'Yii',
    '2008-2017 by Yii Software LLC',
    'BSD',
    'https://raw.githubusercontent.com/yiisoft/yii/master/LICENSE'
  ], [
    'Spring Boot',
    '2002-2020 Pivotal, Inc. All Rights Reserved.',
    'Apache License 2.0',
    'https://raw.githubusercontent.com/spring-projects/spring-boot/master/LICENSE.txt'
  ]
]
