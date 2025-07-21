app.templates.aboutPage = function () {
  let doc;
  const all_docs = app.docs.all().concat(...(app.disabledDocs.all() || []));
  // de-duplicate docs by doc.name
  const docs = [];
  for (doc of all_docs) {
    if (!docs.find((d) => d.name === doc.name)) {
      docs.push(doc);
    }
  }
  return `\
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
  <li>Join the <a href="https://discord.gg/PRyKn3Vbay">Discord</a> chat room
</ul>

<h2 class="_block-heading" id="copyright">Copyright and License</h2>
<p class="_note">
  <strong>Copyright 2013&ndash;2025 Thibaut Courouble and <a href="https://github.com/freeCodeCamp/devdocs/graphs/contributors">other contributors</a></strong><br>
  This software is licensed under the terms of the Mozilla Public License v2.0.<br>
  You may obtain a copy of the source code at <a href="https://github.com/freeCodeCamp/devdocs">github.com/freeCodeCamp/devdocs</a>.<br>
  For more information, see the <a href="https://github.com/freeCodeCamp/devdocs/blob/main/COPYRIGHT">COPYRIGHT</a>
  and <a href="https://github.com/freeCodeCamp/devdocs/blob/main/LICENSE">LICENSE</a> files.

<h2 class="_block-heading" id="plugins">Plugins and Extensions</h2>
<ul>
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
      Otherwise, come talk to us in the <a href="https://discord.gg/PRyKn3Vbay">Discord</a> chat room.
  <dt>Where can I report bugs?
  <dd>In the <a href="https://github.com/freeCodeCamp/devdocs/issues">issue tracker</a>. Thanks!
</dl>

<h2 class="_block-heading" id="credits">Credits</h2>

<p><strong>Special thanks to:</strong>
<ul>
  <li><a href="https://sentry.io/">Sentry</a> and <a href="https://get.gaug.es/?utm_source=devdocs&utm_medium=referral&utm_campaign=sponsorships" title="Real Time Web Analytics">Gauges</a> for offering a free account to DevDocs
  <li><a href="https://out.devdocs.io/s/maxcdn">MaxCDN</a>, <a href="https://out.devdocs.io/s/shopify">Shopify</a>, <a href="https://out.devdocs.io/s/jetbrains">JetBrains</a> and <a href="https://out.devdocs.io/s/code-school">Code School</a> for sponsoring DevDocs in the past
  <li><a href="https://www.heroku.com">Heroku</a> and <a href="https://newrelic.com/">New Relic</a> for providing awesome free service
  <li><a href="https://www.jeremykratz.com/">Jeremy Kratz</a> for the C/C++ logo
</ul>

<div class="_table">
  <table class="_credits">
    <tr>
      <th>Documentation
      <th>Copyright/License
      <th>Source code
    ${docs
      .map(
        (doc) =>
          `<tr><td><a href="${doc.links?.home}">${doc.name}</a></td><td>${doc.attribution}</td><td><a href="${doc.links?.code}">Source code</a></td></tr>`,
      )
      .join("")}
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
</ul>\
`;
};
