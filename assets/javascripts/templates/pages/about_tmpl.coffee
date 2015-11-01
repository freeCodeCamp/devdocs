app.templates.aboutPage = -> """
  <div class="_toc">
    <h3 class="_toc-title">Table of Contents</h3>
    <ul class="_toc-list">
      <li><a href="#credits">Credits</a>
      <li><a href="#faq">FAQ</a>
      <li><a href="#copyright">Copyright</a>
      <li><a href="#plugins">Plugins</a>
    </ul>
  </div>

  <h1 class="_lined-heading">API Documentation Browser</h1>
  <p>DevDocs combines multiple API documentations in a fast, organized, and searchable interface.
  <ul>
    <li>Created and maintained by <a href="http://thibaut.me">Thibaut Courouble</a>
    <li>Sponsored by <a href="http://out.devdocs.io/s/code-school">Code School</a>
    <li>Free and <a href="https://github.com/Thibaut/devdocs">open source</a>
        <iframe class="_github-btn" src="https://ghbtns.com/github-btn.html?user=Thibaut&repo=devdocs&type=watch&count=true" allowtransparency="true" frameborder="0" scrolling="0" width="100" height="20"></iframe>
  </ul>
  <p>To keep up-to-date with the latest development and community news:
  <ul>
    <li>Subscribe to the <a href="http://eepurl.com/HnLUz">newsletter</a>
    <li>Follow <a href="https://twitter.com/DevDocs">@DevDocs</a> on Twitter
    <li>Join the <a href="https://groups.google.com/d/forum/devdocs">mailing list</a>
  </ul>
  <p class="_note _note-green">If you like DevDocs, please consider supporting my work on
    <a href="https://gratipay.com/devdocs/">Gratipay</a>. Thanks!<br>

  <h2 class="_lined-heading" id="credits">Credits</h2>

  <p><strong>Special thanks to:</strong>
  <ul>
    <li><a href="http://out.devdocs.io/s/maxcdn">MaxCDN</a> and <a href="http://get.gaug.es/?utm_source=devdocs&utm_medium=referral&utm_campaign=sponsorships" title="Real Time Web Analytics">Gauges</a> for offering a free account to DevDocs
    <li><a href="http://out.devdocs.io/s/maxcdn">MaxCDN</a>, <a href="http://out.devdocs.io/s/shopify">Shopify</a> and <a href="http://out.devdocs.io/s/jetbrains">JetBrains</a> for sponsoring DevDocs in the past
    <li><a href="https://www.heroku.com">Heroku</a> and <a href="http://newrelic.com">New Relic</a> for providing awesome free service
    <li>Daniel Bruce for the <a href="http://www.entypo.com">Entypo</a> pictograms
    <li><a href="http://www.jeremykratz.com/">Jeremy Kratz</a> for the C/C++ logo
  </ul>

  <table class="_credits">
    <tr>
      <th>Documentation
      <th>Copyright
      <th>License
    #{("<tr><td>#{c[0]}<td>&copy; #{c[1]}<td><a href=\"#{c[3]}\">#{c[2]}</a>" for c in credits).join('')}
  </table>

  <h2 class="_lined-heading" id="faq">Questions & Answers</h2>
  <dl>
    <dt>Where can I suggest new docs and features?
    <dd>You can suggest and vote for new docs on the <a href="https://trello.com/b/6BmTulfx/devdocs-documentation">Trello board</a>.<br>
        If you have a specific feature request, add it to the <a href="https://github.com/Thibaut/devdocs/issues">issue tracker</a>.<br>
        Otherwise use the <a href="https://groups.google.com/d/forum/devdocs">mailing list</a>.
    <dt>Where can I report bugs?
    <dd>In the <a href="https://github.com/Thibaut/devdocs/issues">issue tracker</a>. Thanks!
  </dl>
  <p>For anything else, feel free to email me at <a href="mailto:thibaut@devdocs.io">thibaut@devdocs.io</a>.

  <h2 class="_lined-heading" id="copyright">Copyright and License</h2>
  <p class="_note">
    <strong>Copyright 2013&ndash;2015 Thibaut Courouble and <a href="https://github.com/Thibaut/devdocs/graphs/contributors">other contributors</a></strong><br>
    This software is licensed under the terms of the Mozilla Public License v2.0.<br>
    You may obtain a copy of the source code at <a href="https://github.com/Thibaut/devdocs">github.com/Thibaut/devdocs</a>.<br>
    For more information, see the <a href="https://github.com/Thibaut/devdocs/blob/master/COPYRIGHT">COPYRIGHT</a>
    and <a href="https://github.com/Thibaut/devdocs/blob/master/LICENSE">LICENSE</a> files.

  <h2 class="_lined-heading" id="plugins">Plugins and Extensions</h2>
  <ul>
    <li><a href="https://chrome.google.com/webstore/detail/devdocs/mnfehgbmkapmjnhcnbodoamcioleeooe">Chrome web app</a>
    <li><a href="https://marketplace.firefox.com/app/devdocs/">Firefox web app</a>
    <li><a href="https://sublime.wbond.net/packages/DevDocs">Sublime Text plugin</a>
    <li><a href="https://atom.io/packages/devdocs">Atom plugin</a>
    <li><a href="https://github.com/gruehle/dev-docs-viewer">Brackets extension</a>
  </ul>
  <p>You can also use <a href="http://fluidapp.com">Fluid</a> to turn DevDocs into a real OS X app, or <a href="https://apps.ubuntu.com/cat/applications/fogger/">Fogger</a> on Ubuntu.
"""

credits = [
  [ 'Angular.js',
    '2010-2015 Google, Inc.',
    'CC BY',
    'http://creativecommons.org/licenses/by/3.0/'
  ], [
    'Apache HTTP Server',
    'The Apache Software Foundation',
    'Apache',
    'http://www.apache.org/licenses/LICENSE-2.0'
  ], [
    'Backbone.js',
    '2010-2015 Jeremy Ashkenas, DocumentCloud',
    'MIT',
    'https://raw.github.com/jashkenas/backbone/master/LICENSE'
  ], [
    'Bower',
    '2015 Bower contributors',
    'CC BY',
    'https://github.com/bower/bower.github.io/blob/b7b94ad38b72e8fb5dafb20c8ce42835a49cc98f/package.json#L20'
  ], [
    'C<br>C++',
    'cppreference.com',
    'CC BY-SA',
    'http://en.cppreference.com/w/Cppreference:Copyright/CC-BY-SA'
  ], [
    'Chai',
    '2011-2015 Jake Luer',
    'MIT',
    'https://github.com/chaijs/chai/blob/master/README.md#license'
  ], [
    'Clojure',
    'Rich Hickey',
    'EPL',
    'https://github.com/clojure/clojure/blob/master/epl-v10.html'
  ], [
    'CoffeeScript',
    '2009-2015 Jeremy Ashkenas',
    'MIT',
    'https://raw.github.com/jashkenas/coffee-script/master/LICENSE'
  ], [
    'Cordova',
    '2012-2015 The Apache Software Foundation',
    'Apache',
    'https://raw.githubusercontent.com/apache/cordova-docs/master/LICENSE'
  ], [
    'CSS<br>DOM<br>HTML<br>JavaScript<br>SVG<br>XPath',
    '2005-2015 Mozilla Developer Network and individual contributors',
    'CC BY-SA',
    'http://creativecommons.org/licenses/by-sa/2.5/'
  ], [
    'D3.js',
    '2015 Michael Bostock',
    'BSD',
    'https://raw.github.com/mbostock/d3/master/LICENSE'
  ], [
    'Django',
    'Django Software Foundation and individual contributors',
    'BSD',
    'https://raw.githubusercontent.com/django/django/master/LICENSE'
  ], [
    'Drupal',
    '2001-2015 by the original authors<br>Drupal is a registered trademark of Dries Buytaert.',
    'GPLv2',
    'https://api.drupal.org/api/drupal/LICENSE.txt'
  ], [
    'Ember.js',
    '2015 Yehuda Katz, Tom Dale and Ember.js contributors',
    'MIT',
    'https://raw.github.com/emberjs/ember.js/master/LICENSE'
  ], [
    'Express',
    '2009-2015 TJ Holowaychuk',
    'MIT',
    'https://raw.githubusercontent.com/visionmedia/express/master/LICENSE'
  ], [
    'Git',
    '2005-2015 Linus Torvalds and others',
    'GPLv2',
    'https://raw.github.com/git/git/master/COPYING'
  ], [
    'Go',
    'Google, Inc.',
    'CC BY',
    'http://creativecommons.org/licenses/by/3.0/'
  ], [
    'Grunt',
    '2014 Grunt Team',
    'MIT',
    'https://raw.githubusercontent.com/gruntjs/gruntjs.com/master/LICENSE'
  ], [
    'Haskell',
    'The University of Glasgow',
    'BSD',
    'http://www.haskell.org/ghc/license'
  ], [
    'io.js',
    'io.js contributors',
    'MIT',
    'https://raw.githubusercontent.com/iojs/io.js/v1.x/LICENSE'
  ], [
    'jQuery',
    '2009 Packt Publishing<br>&copy; 2014 jQuery Foundation',
    'MIT',
    'https://raw.github.com/jquery/api.jquery.com/master/LICENSE-MIT.txt'
  ], [
    'jQuery Mobile',
    '2014 jQuery Foundation',
    'MIT',
    'https://raw.github.com/jquery/api.jquerymobile.com/master/LICENSE-MIT.txt'
  ], [
    'jQuery UI',
    '2014 jQuery Foundation',
    'MIT',
    'https://raw.github.com/jquery/api.jqueryui.com/master/LICENSE-MIT.txt'
  ], [
    'Knockout.js',
    'Steven Sanderson, the Knockout.js team, and other contributors',
    'MIT',
    'https://raw.github.com/knockout/knockout/master/LICENSE'
  ], [
    'Laravel',
    'Taylor Otwell',
    'MIT',
    'https://raw.githubusercontent.com/laravel/framework/master/LICENSE.txt'
  ], [
    'Less',
    '2009-2015 The Core Less Team',
    'CC BY',
    'http://creativecommons.org/licenses/by/3.0/'
  ], [
    'Lo-Dash',
    '2012-2015 The Dojo Foundation',
    'MIT',
    'https://raw.github.com/lodash/lodash/master/LICENSE.txt'
  ], [
    'Lua',
    '1994–2015 Lua.org, PUC-Rio',
    'MIT',
    'http://www.lua.org/license.html'
  ], [
    'Marionette.js',
    '2015 Muted Solutions, LLC',
    'MIT',
    'http://mutedsolutions.mit-license.org/'
  ], [
    'Markdown',
    '2004 John Gruber',
    'BSD',
    'http://daringfireball.net/projects/markdown/license'
  ], [
    'Meteor',
    '2011-2015 Meteor Development Group',
    'MIT',
    'https://raw.githubusercontent.com/meteor/meteor/master/LICENSE.txt'
  ], [
    'Minitest',
    'Ryan Davis, seattle.rb',
    'MIT',
    'https://raw.githubusercontent.com/seattlerb/minitest/master/README.txt'
  ], [
    'Mocha',
    '2011-2015 TJ Holowaychuk',
    'MIT',
    'https://raw.githubusercontent.com/mochajs/mocha/master/LICENSE'
  ], [
    'Modernizr',
    '2009-2014 Modernizr',
    'MIT',
    'http://modernizr.com/license/'
  ], [
    'Moment.js',
    '2011-2015 Tim Wood, Iskren Chernev, Moment.js contributors',
    'MIT',
    'https://raw.github.com/moment/moment/master/LICENSE'
  ], [
    'Mongoose',
    '2010 LearnBoost',
    'MIT',
    'https://github.com/LearnBoost/mongoose/blob/master/README.md#license'
  ], [
    'nginx',
    '2002-2015 Igor Sysoev<br>&copy; 2011-2015 Nginx, Inc.',
    'BSD',
    'http://nginx.org/LICENSE'
  ], [
    'Node.js',
    'Joyent, Inc. and other Node contributors<br>Node.js is a trademark of Joyent, Inc.',
    'MIT',
    'https://raw.githubusercontent.com/nodejs/node/master/LICENSE'
  ], [
    'Nokogiri',
    '2008-2014 2014 Aaron Patterson, Mike Dalessio, Charles Nutter, Sergio Arbeo, Patrick Mahoney, Yoko Harada, Akinori Musha',
    'MIT',
    'https://github.com/sparklemotion/nokogiri/blob/master/README.rdoc#license'
  ], [
    'npm',
    'npm, Inc. and Contributors<br>npm is a trademark of npm, Inc.',
    'npm',
    'https://raw.githubusercontent.com/npm/npm/master/LICENSE'
  ], [
    'OpenTSDB',
    '2010-2015 The OpenTSDB Authors',
    'LGPLv2.1',
    'https://raw.githubusercontent.com/OpenTSDB/opentsdb.net/gh-pages/COPYING.LESSER'
  ], [
    'Phalcon',
    '2011-2015 Phalcon Framework Team',
    'CC BY',
    'https://docs.phalconphp.com/en/latest/reference/license.html'
  ], [
    'Phaser',
    '2015 Richard Davey, Photon Storm Ltd.',
    'MIT',
    'https://raw.githubusercontent.com/photonstorm/phaser/master/license.txt'
  ], [
    'PHP',
    '1997-2015 The PHP Documentation Group',
    'CC BY',
    'http://creativecommons.org/licenses/by/3.0/'
  ], [
    'PHPUnit',
    '2005-2015 Sebastian Bergmann',
    'CC BY',
    'http://creativecommons.org/licenses/by/3.0/'
  ], [
    'PostgreSQL',
    '1996-2013 The PostgreSQL Global Development Group<br>&copy; 1994 The Regents of the University of California',
    'PostgreSQL',
    'http://www.postgresql.org/about/licence/'
  ], [
    'Python',
    '1990-2015 Python Software Foundation<br>Python is a trademark of the Python Software Foundation.',
    'PSFL',
    'http://docs.python.org/3/license.html'
  ], [
    'Q',
    '2009-2015 Kristopher Michael Kowal and contributors',
    'MIT',
    'https://raw.githubusercontent.com/kriskowal/q/v1/LICENSE'
  ], [
    'React, React Native',
    '2013-2015 Facebook Inc.',
    'CC BY',
    'https://raw.githubusercontent.com/facebook/react/master/LICENSE-docs'
  ], [
    'Redis',
    '2009-2015 Salvatore Sanfilippo',
    'CC BY-SA',
    'http://creativecommons.org/licenses/by-sa/4.0/'
  ], [
    'RequireJS',
    '2010-2014 The Dojo Foundation',
    'MIT',
    'https://raw.githubusercontent.com/jrburke/requirejs/master/LICENSE'
  ], [
    'RethinkDB',
    'RethinkDB contributors',
    'CC BY-SA',
    'https://raw.githubusercontent.com/rethinkdb/docs/master/LICENSE'
  ], [
    'Ruby',
    '1993-2015 Yukihiro Matsumoto',
    'Ruby',
    'https://www.ruby-lang.org/en/about/license.txt'
  ], [
    'Ruby on Rails',
    '2004-2015 David Heinemeier Hansson<br>Rails, Ruby on Rails, and the Rails logo are trademarks of David Heinemeier Hansson.',
    'MIT',
    'https://raw.github.com/rails/rails/master/activerecord/MIT-LICENSE'
  ], [
    'Rust',
    '2011-2015 The Rust Project Developers',
    'MIT',
    'https://raw.githubusercontent.com/rust-lang/rust/master/LICENSE-MIT'
  ], [
    'Sass',
    '2006-2015 Hampton Catlin, Nathan Weizenbaum, and Chris Eppstein',
    'MIT',
    'https://raw.github.com/nex3/sass/master/MIT-LICENSE'
  ], [
    'Sinon',
    '2010-2015 Christian Johansen',
    'BSD',
    'https://raw.githubusercontent.com/cjohansen/Sinon.JS/master/LICENSE'
  ], [
    'Socket.io',
    '2014-2015 Automattic',
    'MIT',
    'https://raw.githubusercontent.com/Automattic/socket.io/master/LICENSE'
  ], [
    'Symfony',
    '2004-2015 Fabien Potencier',
    'MIT',
    'http://symfony.com/doc/current/contributing/code/license.html'
  ], [
    'Underscore.js',
    '2009-2015 Jeremy Ashkenas, DocumentCloud and Investigative Reporters & Editors',
    'MIT',
    'https://raw.github.com/jashkenas/underscore/master/LICENSE'
  ], [
    'Vue.js',
    '2013-2015 Evan You, Vue.js contributors',
    'MIT',
    'https://raw.githubusercontent.com/yyx990803/vue/master/LICENSE'
  ], [
    'Webpack',
    '2012-2015 Tobias Koppers',
    'MIT',
    'https://raw.githubusercontent.com/webpack/webpack/master/LICENSE'
  ], [
    'Yii',
    '2008-2015 by Yii Software LLC',
    'BSD',
    'https://raw.github.com/yiisoft/yii/master/LICENSE'
  ]
]
