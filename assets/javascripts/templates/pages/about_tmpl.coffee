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
    <li>Proudly sponsored by <a href="http://www.maxcdn.com">MaxCDN</a>&mdash;content delivery that developers love
    <li>Free and <a href="https://github.com/Thibaut/devdocs">open source</a>
        <iframe class="_github-btn" src="http://ghbtns.com/github-btn.html?user=Thibaut&repo=devdocs&type=watch&count=true" allowtransparency="true" frameborder="0" scrolling="0" width="100" height="20"></iframe>
  </ul>
  <p>To keep up-to-date with the latest development and community news:
  <ul>
    <li>Subscribe to the <a href="http://eepurl.com/HnLUz">newsletter</a>
    <li>Follow <a href="https://twitter.com/DevDocs">@DevDocs</a> on Twitter
    <li>Join the <a href="https://groups.google.com/d/forum/devdocs">mailing list</a>
  </ul>
  <p class="_note _note-green">If you like DevDocs, please consider funding the project on
    <a href="https://www.gittip.com/Thibaut/">Gittip</a>. Thanks!<br>

  <h2 class="_lined-heading" id="credits">Credits</h2>
  <table class="_credits">
    <tr>
      <th>Documentation
      <th>Copyright
      <th>License
    #{("<tr><td>#{c[0]}<td>&copy; #{c[1]}<td><a href=\"#{c[3]}\">#{c[2]}</a>" for c in credits).join('')}
  </table>

  <p><strong>With special thanks to:</strong>
  <ul>
    <li><a href="https://www.heroku.com">Heroku</a> and <a href="http://newrelic.com">New Relic</a> for providing awesome free service
    <li>Daniel Bruce for the <a href="http://www.entypo.com">Entypo</a> pictograms
  </ul>

  <h2 class="_lined-heading" id="faq">Questions & Answsers</h2>
  <dl>
    <dt>Does it work offline?
    <dd>Yes! DevDocs is open source. You can run <a href="https://github.com/Thibaut/devdocs">the code</a> locally on your computer.<br>
        An offline version that requires no setup is planned for the future.
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
    <strong>Copyright 2013&ndash;2014 Thibaut Courouble and <a href="https://github.com/Thibaut/devdocs/graphs/contributors">other contributors</a></strong><br>
    This software is licensed under the terms of the Mozilla Public License v2.0.<br>
    You may obtain a copy of the source code at <a href="https://github.com/Thibaut/devdocs">github.com/Thibaut/devdocs</a>.<br>
    For more information, see the <a href="https://github.com/Thibaut/devdocs/blob/master/COPYRIGHT">COPYRIGHT</a>
    and <a href="https://github.com/Thibaut/devdocs/blob/master/LICENSE">LICENSE</a> files.

  <h2 class="_lined-heading" id="plugins">Plugins and Extensions</h2>
  <ul>
    <li><a href="https://chrome.google.com/webstore/detail/devdocs/mnfehgbmkapmjnhcnbodoamcioleeooe">Chrome web app</a>
    <li><a href="https://marketplace.firefox.com/app/devdocs/">Firefox web app</a>
    <li><a href="https://sublime.wbond.net/packages/DevDocs">Sublime Text plugin</a>
    <li><a href="https://github.com/gruehle/dev-docs-viewer">Brackets extension</a>
  </ul>
  <p>You can also use <a href="http://fluidapp.com">Fluid</a> to turn DevDocs into a real OS X app.
"""

credits = [
  [ 'Angular.js',
    '2010-2014 Google, Inc.',
    'CC BY',
    'http://creativecommons.org/licenses/by/3.0/'
  ], [
    'Backbone.js',
    '2010-2014 Jeremy Ashkenas, DocumentCloud',
    'MIT',
    'https://raw.github.com/jashkenas/backbone/master/LICENSE'
  ], [
    'CoffeeScript',
    '2009-2014 Jeremy Ashkenas',
    'MIT',
    'https://raw.github.com/jashkenas/coffee-script/master/LICENSE'
  ], [
    'CSS<br>DOM<br>HTML<br>JavaScript',
    '2005-2013 Mozilla Developer Network and individual contributors',
    'CC BY-SA',
    'http://creativecommons.org/licenses/by-sa/2.5/'
  ], [
    'D3.js',
    '2014 Michael Bostock',
    'BSD',
    'https://raw.github.com/mbostock/d3/master/LICENSE'
  ], [
    'Ember.js',
    '2014 Yehuda Katz, Tom Dale and Ember.js contributors',
    'MIT',
    'https://raw.github.com/emberjs/ember.js/master/LICENSE'
  ], [
    'Git',
    '2005-2014 Linus Torvalds and others',
    'GPLv2',
    'https://raw.github.com/git/git/master/COPYING'
  ], [
    'HTTP',
    '1999 The Internet Society',
    'Custom',
    'http://www.w3.org/Protocols/rfc2616/rfc2616-sec21.html#sec21'
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
    'Less',
    '2009-2014 The Core Less Team',
    'CC BY',
    'http://creativecommons.org/licenses/by/3.0/'
  ], [
    'Lo-Dash',
    '2009-2013 The Dojo Foundation',
    'MIT',
    'https://raw.github.com/lodash/lodash/master/LICENSE.txt'
  ], [
    'Moment.js',
    '2011-2014 Tim Wood, Iskren Chernev, Moment.js contributors',
    'MIT',
    'https://raw.github.com/moment/moment/master/LICENSE'
  ], [
    'Node.js',
    'Joyent, Inc. and other Node contributors<br>Node.js is a trademark of Joyent, Inc.',
    'MIT',
    'https://raw.github.com/joyent/node/master/LICENSE'
  ], [
    'PHP',
    '1997-2014 The PHP Documentation Group',
    'CC BY',
    'http://creativecommons.org/licenses/by/3.0/'
  ], [
    'PostgreSQL',
    '1996-2013 The PostgreSQL Global Development Group<br>&copy; 1994 The Regents of the University of California',
    'PostgreSQL',
    'http://www.postgresql.org/about/licence/'
  ], [
    'Python',
    '1990-2013 Python Software Foundation<br>Python is a trademark of the Python Software Foundation.',
    'PSFL',
    'http://docs.python.org/3/license.html'
  ], [
    'Redis',
    '2006-2014 Salvatore Sanfilippo and others',
    'BSD',
    'https://raw.github.com/antirez/redis/unstable/COPYING'
  ], [
    'Ruby',
    '1993-2013 Yukihiro Matsumoto',
    'Ruby',
    'https://www.ruby-lang.org/en/about/license.txt'
  ], [
    'Ruby on Rails',
    '2004-2013 David Heinemeier Hansson<br>Rails, Ruby on Rails, and the Rails logo are trademarks of David Heinemeier Hansson.',
    'MIT',
    'https://raw.github.com/rails/rails/master/activerecord/MIT-LICENSE'
  ], [
    'Sass',
    '2006-2013 Hampton Catlin, Nathan Weizenbaum, and Chris Eppstein',
    'MIT',
    'https://raw.github.com/nex3/sass/master/MIT-LICENSE'
  ], [
    'Underscore.js',
    '2009-2014 Jeremy Ashkenas, DocumentCloud and Investigative Reporters & Editors',
    'MIT',
    'https://raw.github.com/jashkenas/underscore/master/LICENSE'
  ]
]
