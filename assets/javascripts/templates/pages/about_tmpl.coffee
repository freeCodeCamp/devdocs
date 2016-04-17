app.templates.aboutPage = -> """
  <div class="_toc">
    <h3 class="_toc-title">Table of Contents</h3>
    <ul class="_toc-list">
      <li><a href="#credits">Credits</a>
      <li><a href="#faq">FAQ</a>
      <li><a href="#copyright">Copyright</a>
      <li><a href="#plugins">Plugins</a>
      <li><a href="#privacy">Privacy Policy</a>
    </ul>
  </div>

  <h1 class="_lined-heading">API Documentation Browser</h1>
  <p>DevDocs combines multiple API documentations in a fast, organized, and searchable interface.
  <ul>
    <li>Created and maintained by <a href="http://thibaut.me">Thibaut Courouble</a>
    <li>Free and <a href="https://github.com/Thibaut/devdocs">open source</a>
        <iframe class="_github-btn" src="https://ghbtns.com/github-btn.html?user=Thibaut&repo=devdocs&type=watch&count=true" allowtransparency="true" frameborder="0" scrolling="0" width="100" height="20"></iframe>
  </ul>
  <p>To keep up-to-date with the latest news:
  <ul>
    <li>Follow <a href="https://twitter.com/DevDocs">@DevDocs</a> on Twitter
    <li>Watch the repository on <a href="https://github.com/Thibaut/devdocs/subscription">GitHub</a>
    <li>Join the <a href="https://groups.google.com/d/forum/devdocs">mailing list</a>
  </ul>
  <p class="_note _note-green">If you like DevDocs, please consider supporting my work on
    <a href="https://gratipay.com/devdocs/">Gratipay</a>. Thanks!<br>

  <h2 class="_lined-heading" id="credits">Credits</h2>

  <p><strong>Special thanks to:</strong>
  <ul>
    <li><a href="http://out.devdocs.io/s/maxcdn">MaxCDN</a> and <a href="http://get.gaug.es/?utm_source=devdocs&utm_medium=referral&utm_campaign=sponsorships" title="Real Time Web Analytics">Gauges</a> for offering a free account to DevDocs
    <li><a href="http://out.devdocs.io/s/maxcdn">MaxCDN</a>, <a href="http://out.devdocs.io/s/shopify">Shopify</a>, <a href="http://out.devdocs.io/s/jetbrains">JetBrains</a> and <a href="http://out.devdocs.io/s/code-school">Code School</a> for sponsoring DevDocs in the past
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
    <strong>Copyright 2013&ndash;2016 Thibaut Courouble and <a href="https://github.com/Thibaut/devdocs/graphs/contributors">other contributors</a></strong><br>
    This software is licensed under the terms of the Mozilla Public License v2.0.<br>
    You may obtain a copy of the source code at <a href="https://github.com/Thibaut/devdocs">github.com/Thibaut/devdocs</a>.<br>
    For more information, see the <a href="https://github.com/Thibaut/devdocs/blob/master/COPYRIGHT">COPYRIGHT</a>
    and <a href="https://github.com/Thibaut/devdocs/blob/master/LICENSE">LICENSE</a> files.

  <h2 class="_lined-heading" id="plugins">Plugins and Extensions</h2>
  <ul>
    <li><a href="https://chrome.google.com/webstore/detail/devdocs/mnfehgbmkapmjnhcnbodoamcioleeooe">Chrome web app</a>
    <li><a href="https://sublime.wbond.net/packages/DevDocs">Sublime Text plugin</a>
    <li><a href="https://atom.io/packages/devdocs">Atom plugin</a>
    <li><a href="https://github.com/gruehle/dev-docs-viewer">Brackets extension</a>
    <li><a href="https://github.com/xuchunyang/DevDocs.el">Emacs Package</a>
  </ul>
  <p>You can also use <a href="http://fluidapp.com">Fluid</a> to turn DevDocs into a real OS X app, or <a href="https://apps.ubuntu.com/cat/applications/fogger/">Fogger</a> on Ubuntu.

  <h2 class="_lined-heading" id="privacy">Privacy Policy</h2>
  <ul>
    <li><a href="http://devdocs.io">devdocs.io</a> ("App") is operated by Thibaut Courouble ("We").
    <li>We do not collect personal information.
    <li>We use Google Analytics, Gauges and Sentry to collect anonymous traffic information and improve the app.
    <li>The app uses cookies to store user preferences.
    <li>By using the app, you signify your acceptance of this policy. If you do not agree to this policy, please do not use the app.
    <li>If you have any questions regarding privacy, please email <a href="mailto:thibaut@devdocs.io">thibaut@devdocs.io</a>.
  </ul>
"""

credits = [
  [ 'Angular.js',
    '2010-2016 Google, Inc.',
    'CC BY',
    'https://creativecommons.org/licenses/by/4.0/'
  ], [
    'Ansible',
    '2012-2016 Michael DeHaan',
    'GPLv3',
    'https://raw.githubusercontent.com/ansible/ansible/devel/COPYING'
  ], [
    'Apache HTTP Server',
    '2016 The Apache Software Foundation',
    'Apache',
    'https://www.apache.org/licenses/LICENSE-2.0'
  ], [
    'Backbone.js',
    '2010-2016 Jeremy Ashkenas, DocumentCloud',
    'MIT',
    'https://raw.githubusercontent.com/jashkenas/backbone/master/LICENSE'
  ], [
    'Bower',
    '2016 Bower contributors',
    'MIT',
    'https://github.com/bower/bower.github.io/blob/1057905c18d899106f91372e6cca7ef54a91d60f/package.json#L20'
  ], [
    'C<br>C++',
    'cppreference.com',
    'CC BY-SA',
    'http://en.cppreference.com/w/Cppreference:Copyright/CC-BY-SA'
  ], [
    'CakePHP',
    '2005-2016 The Cake Software Foundation, Inc.',
    'MIT',
    'https://raw.githubusercontent.com/cakephp/cakephp/master/LICENSE.txt'
  ], [
    'Chai',
    '2011-2015 Jake Luer',
    'MIT',
    'https://github.com/chaijs/chai/blob/master/README.md#license'
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
    'CodeIgniter',
    '2014-2016 British Columbia Institute of Technology',
    'MIT',
    'https://raw.githubusercontent.com/bcit-ci/CodeIgniter/develop/license.txt'
  ], [
    'CoffeeScript',
    '2009-2015 Jeremy Ashkenas',
    'MIT',
    'https://raw.githubusercontent.com/jashkenas/coffee-script/master/LICENSE'
  ], [
    'Cordova',
    '2012-2016 The Apache Software Foundation',
    'Apache',
    'https://raw.githubusercontent.com/apache/cordova-docs/master/LICENSE'
  ], [
    'CSS<br>DOM<br>HTML<br>JavaScript<br>SVG<br>XPath',
    '2005-2016 Mozilla Developer Network and individual contributors',
    'CC BY-SA',
    'https://creativecommons.org/licenses/by-sa/2.5/'
  ], [
    'D3.js',
    '2010-2016 Michael Bostock',
    'BSD',
    'https://raw.githubusercontent.com/mbostock/d3/master/LICENSE'
  ], [
    'Django',
    'Django Software Foundation and individual contributors',
    'BSD',
    'https://raw.githubusercontent.com/django/django/master/LICENSE'
  ], [
    'Dojo',
    '2005-2015 The Dojo Foundation',
    'BSD + AFL',
    'http://dojotoolkit.org/license.html'
  ], [
    'Drupal',
    '2001-2015 by the original authors<br>Drupal is a registered trademark of Dries Buytaert.',
    'GPLv2',
    'https://api.drupal.org/api/drupal/LICENSE.txt'
  ], [
    'Ember.js',
    '2016 Yehuda Katz, Tom Dale and Ember.js contributors',
    'MIT',
    'https://raw.githubusercontent.com/emberjs/ember.js/master/LICENSE'
  ], [
    'Elixir',
    '2012-2016 Plataformatec',
    'Apache',
    'https://raw.githubusercontent.com/elixir-lang/elixir/master/LICENSE'
  ], [
    'Erlang',
    '1999-2016 Ericsson AB',
    'Apache',
    'https://raw.githubusercontent.com/erlang/otp/maint/LICENSE.txt'
  ], [
    'Express',
    '2009-2015 TJ Holowaychuk',
    'MIT',
    'https://raw.githubusercontent.com/visionmedia/express/master/LICENSE'
  ], [
    'GCC<br>GNU Fortran',
    'Free Software Foundation',
    'GFDL',
    'https://www.gnu.org/licenses/fdl-1.3.en.html'
  ], [
    'Git',
    '2005-2016 Linus Torvalds and others',
    'GPLv2',
    'https://raw.githubusercontent.com/git/git/master/COPYING'
  ], [
    'Go',
    'Google, Inc.',
    'CC BY',
    'https://creativecommons.org/licenses/by/3.0/'
  ], [
    'Grunt',
    'GruntJS Team',
    'MIT',
    'https://github.com/gruntjs/grunt-docs/blob/master/package.json#L10'
  ], [
    'Haskell',
    'The University of Glasgow',
    'BSD',
    'https://www.haskell.org/ghc/license'
  ], [
    'Haxe',
    '2005-2016 Haxe Foundation',
    'MIT',
    'http://haxe.org/foundation/open-source.html'
  ], [
    'InfluxData',
    '2015 InfluxData, Inc.',
    'MIT',
    'https://github.com/influxdata/docs.influxdata.com/blob/master/LICENSE'
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
    'Knockout.js',
    'Steven Sanderson, the Knockout.js team, and other contributors',
    'MIT',
    'https://raw.githubusercontent.com/knockout/knockout/master/LICENSE'
  ], [
    'Laravel',
    'Taylor Otwell',
    'MIT',
    'https://raw.githubusercontent.com/laravel/framework/master/LICENSE.txt'
  ], [
    'Less',
    '2009-2016 The Core Less Team',
    'CC BY',
    'https://creativecommons.org/licenses/by/3.0/'
  ], [
    'Lo-Dash',
    '2012-2016 The Dojo Foundation',
    'MIT',
    'https://raw.githubusercontent.com/lodash/lodash/master/LICENSE.txt'
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
    'https://daringfireball.net/projects/markdown/license'
  ], [
    'Meteor',
    '2011-2016 Meteor Development Group',
    'MIT',
    'https://raw.githubusercontent.com/meteor/meteor/master/LICENSE.txt'
  ], [
    'Minitest',
    'Ryan Davis, seattle.rb',
    'MIT',
    'https://github.com/seattlerb/minitest/blob/master/README.rdoc#license'
  ], [
    'Mocha',
    '2011-2016 TJ Holowaychuk',
    'MIT',
    'https://raw.githubusercontent.com/mochajs/mocha/master/LICENSE'
  ], [
    'Modernizr',
    '2009-2014 Modernizr',
    'MIT',
    'https://modernizr.com/license/'
  ], [
    'Moment.js',
    '2011-2016 Tim Wood, Iskren Chernev, Moment.js contributors',
    'MIT',
    'https://raw.githubusercontent.com/moment/moment/master/LICENSE'
  ], [
    'Mongoose',
    '2010 LearnBoost',
    'MIT',
    'https://github.com/LearnBoost/mongoose/blob/master/README.md#license'
  ], [
    'nginx',
    '2002-2016 Igor Sysoev<br>&copy; 2011-2016 Nginx, Inc.',
    'BSD',
    'http://nginx.org/LICENSE'
  ], [
    'nginx / Lua Module',
    '2009-2016 Xiaozhe Wang (chaoslawful)<br>&copy; 2009-2016 Yichun "agentzh" Zhang (章亦春), CloudFlare Inc.',
    'BSD',
    'https://github.com/openresty/lua-nginx-module#copyright-and-license'
  ], [
    'Node.js',
    'Joyent, Inc. and other Node contributors<br>Node.js is a trademark of Joyent, Inc.',
    'MIT',
    'https://raw.githubusercontent.com/nodejs/node/master/LICENSE'
  ], [
    'Nokogiri',
    '2008-2014 2014 Aaron Patterson, Mike Dalessio, Charles Nutter, Sergio Arbeo, Patrick Mahoney, Yoko Harada, Akinori Musha',
    'MIT',
    'https://raw.githubusercontent.com/sparklemotion/nokogiri/master/LICENSE.txt'
  ], [
    'npm',
    'npm, Inc. and Contributors<br>npm is a trademark of npm, Inc.',
    'npm',
    'https://raw.githubusercontent.com/npm/npm/master/LICENSE'
  ], [
    'OpenTSDB',
    '2010-2016 The OpenTSDB Authors',
    'LGPLv2.1',
    'https://raw.githubusercontent.com/OpenTSDB/opentsdb.net/gh-pages/COPYING.LESSER'
  ], [
    'Perl',
    '1993-2016 Larry Wall and others',
    'GPLv1',
    'http://perldoc.perl.org/index-licence.html'
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
    'Phoenix',
    '2014 Chris McCord',
    'MIT',
    'https://raw.githubusercontent.com/phoenixframework/phoenix/master/LICENSE.md'
  ], [
    'PHP',
    '1997-2016 The PHP Documentation Group',
    'CC BY',
    'https://creativecommons.org/licenses/by/3.0/'
  ], [
    'PHPUnit',
    '2005-2016 Sebastian Bergmann',
    'CC BY',
    'https://creativecommons.org/licenses/by/3.0/'
  ], [
    'PostgreSQL',
    '1996-2016 The PostgreSQL Global Development Group<br>&copy; 1994 The Regents of the University of California',
    'PostgreSQL',
    'http://www.postgresql.org/about/licence/'
  ], [
    'Python',
    '1990-2015 Python Software Foundation<br>Python is a trademark of the Python Software Foundation.',
    'PSFL',
    'https://docs.python.org/3/license.html'
  ], [
    'Q',
    '2009-2015 Kristopher Michael Kowal and contributors',
    'MIT',
    'https://raw.githubusercontent.com/kriskowal/q/v1/LICENSE'
  ], [
    'React, React Native, Flow, Relay',
    '2013-2016 Facebook Inc.',
    'CC BY',
    'https://raw.githubusercontent.com/facebook/react/master/LICENSE-docs'
  ], [
    'Redis',
    '2009-2016 Salvatore Sanfilippo',
    'CC BY-SA',
    'https://creativecommons.org/licenses/by-sa/4.0/'
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
    '1993-2016 Yukihiro Matsumoto',
    'Ruby',
    'https://www.ruby-lang.org/en/about/license.txt'
  ], [
    'Ruby on Rails',
    '2004-2016 David Heinemeier Hansson<br>Rails, Ruby on Rails, and the Rails logo are trademarks of David Heinemeier Hansson.',
    'MIT',
    'https://raw.githubusercontent.com/rails/rails/master/activerecord/MIT-LICENSE'
  ], [
    'Rust',
    '2016 The Rust Project Developers',
    'MIT',
    'https://raw.githubusercontent.com/rust-lang/rust/master/LICENSE-MIT'
  ], [
    'Sass',
    '2006-2016 Hampton Catlin, Nathan Weizenbaum, and Chris Eppstein',
    'MIT',
    'https://raw.githubusercontent.com/sass/sass/stable/MIT-LICENSE'
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
    '2004-2016 Fabien Potencier',
    'MIT',
    'https://symfony.com/doc/current/contributing/code/license.html'
  ], [
    'Tcl/Tk',
    'The Regents of the University of California, Sun Microsystems, Inc., Scriptics Corporation, and other parties',
    'Tcl/Tk',
    'http://tcl.tk/software/tcltk/license.html'
  ], [
    'TensorFlow',
    '2015 The TensorFlow Authors',
    'Apache',
    'https://raw.githubusercontent.com/tensorflow/tensorflow/master/LICENSE'
  ], [
    'TypeScript',
    'Microsoft and other contributors',
    'Apache',
    'https://raw.githubusercontent.com/Microsoft/TypeScript-Handbook/master/LICENSE'
  ], [
    'Underscore.js',
    '2009-2015 Jeremy Ashkenas, DocumentCloud and Investigative Reporters & Editors',
    'MIT',
    'https://raw.githubusercontent.com/jashkenas/underscore/master/LICENSE'
  ], [
    'Vagrant',
    '2010-2015 Mitchell Hashimoto',
    'MIT',
    'https://raw.githubusercontent.com/mitchellh/vagrant/master/LICENSE'
  ], [
    'Vue.js',
    '2013-2016 Evan You, Vue.js contributors',
    'MIT',
    'https://raw.githubusercontent.com/vuejs/vue/master/LICENSE'
  ], [
    'Webpack',
    '2012-2015 Tobias Koppers',
    'MIT',
    'https://raw.githubusercontent.com/webpack/webpack/master/LICENSE'
  ], [
    'Yii',
    '2008-2016 by Yii Software LLC',
    'BSD',
    'https://raw.githubusercontent.com/yiisoft/yii/master/LICENSE'
  ]
]
