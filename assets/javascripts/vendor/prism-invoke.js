var HL = {
  'javascript': [
    '._coffeescript pre:last-child',
    '._angular .prettyprint',
    '._d3 .highlight > pre',
    '._underscore pre',
    '._node pre > code',
    '._jquery .syntaxhighlighter .javascript',
    '._ember pre .javascript',
    ['._knockout pre', 'data-bind="', false],
    '._mdn pre[class*="js"]'
  ],

  'c': [ '._ruby pre.c' ],
  'ruby': [ '._ruby pre.ruby' ],
  'coffeescript': [ '._coffeescript .code > pre:first-child' ],
  'python': [ '._sphinx pre.python' ],

  'markup': [
    ['._knockout pre', 'data-bind="', true],
    '._ember pre.html',
    '._mdn pre[class*="html"]'
  ]
};

function highlightAll(sels, language){
  for(var i = 0; i < sels.length; ++i){
    var sel = sels[i] instanceof Array ? sels[i] : [sels[i]];
    var nodes = document.querySelectorAll(sel[0]);

    for(var j = 0, c = nodes.length; j < c; ++j){
      if(!sel[1] || nodes[j].innerHTML.indexOf(sel[i][1]) != -1 == sel[2]){
        nodes[j].classList.add('language-' + language)
        Prism.highlightElement(nodes[j]);
      }
    }
  }
}

for(var lang in HL)
  if(HL.hasOwnProperty(lang))
    highlightAll(HL[lang], lang);
