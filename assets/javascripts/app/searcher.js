//
// Match functions
//

let fuzzyRegexp,
  i,
  index,
  lastIndex,
  match,
  matcher,
  matchIndex,
  matchLength,
  queryLength,
  score,
  separators,
  value,
  valueLength;
const SEPARATOR = ".";

let query =
  (queryLength =
  value =
  valueLength =
  matcher = // current match function
  fuzzyRegexp = // query fuzzy regexp
  index = // position of the query in the string being matched
  lastIndex = // last position of the query in the string being matched
  match = // regexp match data
  matchIndex =
  matchLength =
  score = // score for the current match
  separators = // counter
  i =
    null); // cursor

function exactMatch() {
  index = value.indexOf(query);
  if (!(index >= 0)) {
    return;
  }

  lastIndex = value.lastIndexOf(query);

  if (index !== lastIndex) {
    return Math.max(
      scoreExactMatch(),
      ((index = lastIndex) && scoreExactMatch()) || 0,
    );
  } else {
    return scoreExactMatch();
  }
}

function scoreExactMatch() {
  // Remove one point for each unmatched character.
  score = 100 - (valueLength - queryLength);

  if (index > 0) {
    // If the character preceding the query is a dot, assign the same score
    // as if the query was found at the beginning of the string, minus one.
    if (value.charAt(index - 1) === SEPARATOR) {
      score += index - 1;
      // Don't match a single-character query unless it's found at the beginning
      // of the string or is preceded by a dot.
    } else if (queryLength === 1) {
      return;
      // (1) Remove one point for each unmatched character up to the nearest
      //     preceding dot or the beginning of the string.
      // (2) Remove one point for each unmatched character following the query.
    } else {
      i = index - 2;
      while (i >= 0 && value.charAt(i) !== SEPARATOR) {
        i--;
      }
      score -=
        index -
        i + // (1)
        (valueLength - queryLength - index); // (2)
    }

    // Remove one point for each dot preceding the query, except for the one
    // immediately before the query.
    separators = 0;
    i = index - 2;
    while (i >= 0) {
      if (value.charAt(i) === SEPARATOR) {
        separators++;
      }
      i--;
    }
    score -= separators;
  }

  // Remove five points for each dot following the query.
  separators = 0;
  i = valueLength - queryLength - index - 1;
  while (i >= 0) {
    if (value.charAt(index + queryLength + i) === SEPARATOR) {
      separators++;
    }
    i--;
  }
  score -= separators * 5;

  return Math.max(1, score);
}

function fuzzyMatch() {
  if (valueLength <= queryLength || value.includes(query)) {
    return;
  }
  if (!(match = fuzzyRegexp.exec(value))) {
    return;
  }
  matchIndex = match.index;
  matchLength = match[0].length;
  score = scoreFuzzyMatch();
  if (
    (match = fuzzyRegexp.exec(
      value.slice((i = value.lastIndexOf(SEPARATOR) + 1)),
    ))
  ) {
    matchIndex = i + match.index;
    matchLength = match[0].length;
    return Math.max(score, scoreFuzzyMatch());
  } else {
    return score;
  }
}

function scoreFuzzyMatch() {
  // When the match is at the beginning of the string or preceded by a dot.
  if (matchIndex === 0 || value.charAt(matchIndex - 1) === SEPARATOR) {
    return Math.max(66, 100 - matchLength);
    // When the match is at the end of the string.
  } else if (matchIndex + matchLength === valueLength) {
    return Math.max(33, 67 - matchLength);
    // When the match is in the middle of the string.
  } else {
    return Math.max(1, 34 - matchLength);
  }
}

//
// Searchers
//

app.Searcher = class Searcher extends Events {
  static CHUNK_SIZE = 20000;

  static DEFAULTS = {
    max_results: app.config.max_results,
    fuzzy_min_length: 3,
  };

  static SEPARATORS_REGEXP =
    /#|::|:-|->|\$(?=\w)|\-(?=\w)|\:(?=\w)|\ [\/\-&]\ |:\ |\ /g;
  static EOS_SEPARATORS_REGEXP = /(\w)[\-:]$/;
  static INFO_PARANTHESES_REGEXP = /\ \(\w+?\)$/;
  static EMPTY_PARANTHESES_REGEXP = /\(\)/;
  static EVENT_REGEXP = /\ event$/;
  static DOT_REGEXP = /\.+/g;
  static WHITESPACE_REGEXP = /\s/g;

  static EMPTY_STRING = "";
  static ELLIPSIS = "...";
  static STRING = "string";

  static normalizeString(string) {
    return string
      .toLowerCase()
      .replace(Searcher.ELLIPSIS, Searcher.EMPTY_STRING)
      .replace(Searcher.EVENT_REGEXP, Searcher.EMPTY_STRING)
      .replace(Searcher.INFO_PARANTHESES_REGEXP, Searcher.EMPTY_STRING)
      .replace(Searcher.SEPARATORS_REGEXP, SEPARATOR)
      .replace(Searcher.DOT_REGEXP, SEPARATOR)
      .replace(Searcher.EMPTY_PARANTHESES_REGEXP, Searcher.EMPTY_STRING)
      .replace(Searcher.WHITESPACE_REGEXP, Searcher.EMPTY_STRING);
  }

  static normalizeQuery(string) {
    string = this.normalizeString(string);
    return string.replace(Searcher.EOS_SEPARATORS_REGEXP, "$1.");
  }

  constructor(options) {
    super();
    this.options = { ...Searcher.DEFAULTS, ...(options || {}) };
  }

  find(data, attr, q) {
    this.kill();

    this.data = data;
    this.attr = attr;
    this.query = q;
    this.setup();

    if (this.isValid()) {
      this.match();
    } else {
      this.end();
    }
  }

  setup() {
    query = this.query = this.constructor.normalizeQuery(this.query);
    queryLength = query.length;
    this.dataLength = this.data.length;
    this.matchers = [exactMatch];
    this.totalResults = 0;
    this.setupFuzzy();
  }

  setupFuzzy() {
    if (queryLength >= this.options.fuzzy_min_length) {
      fuzzyRegexp = this.queryToFuzzyRegexp(query);
      this.matchers.push(fuzzyMatch);
    } else {
      fuzzyRegexp = null;
    }
  }

  isValid() {
    return queryLength > 0 && query !== SEPARATOR;
  }

  end() {
    if (!this.totalResults) {
      this.triggerResults([]);
    }
    this.trigger("end");
    this.free();
  }

  kill() {
    if (this.timeout) {
      clearTimeout(this.timeout);
      this.free();
    }
  }

  free() {
    this.data = null;
    this.attr = null;
    this.dataLength = null;
    this.matchers = null;
    this.matcher = null;
    this.query = null;
    this.totalResults = null;
    this.scoreMap = null;
    this.cursor = null;
    this.timeout = null;
  }

  match() {
    if (!this.foundEnough() && (this.matcher = this.matchers.shift())) {
      this.setupMatcher();
      this.matchChunks();
    } else {
      this.end();
    }
  }

  setupMatcher() {
    this.cursor = 0;
    this.scoreMap = new Array(101);
  }

  matchChunks() {
    this.matchChunk();

    if (this.cursor === this.dataLength || this.scoredEnough()) {
      this.delay(() => this.match());
      this.sendResults();
    } else {
      this.delay(() => this.matchChunks());
    }
  }

  matchChunk() {
    ({ matcher } = this);
    for (let j = 0, end = this.chunkSize(); j < end; j++) {
      value = this.data[this.cursor][this.attr];
      if (value.split) {
        // string
        valueLength = value.length;
        if ((score = matcher())) {
          this.addResult(this.data[this.cursor], score);
        }
      } else {
        // array
        score = 0;
        for (value of Array.from(this.data[this.cursor][this.attr])) {
          valueLength = value.length;
          score = Math.max(score, matcher() || 0);
        }
        if (score > 0) {
          this.addResult(this.data[this.cursor], score);
        }
      }
      this.cursor++;
    }
  }

  chunkSize() {
    if (this.cursor + Searcher.CHUNK_SIZE > this.dataLength) {
      return this.dataLength % Searcher.CHUNK_SIZE;
    } else {
      return Searcher.CHUNK_SIZE;
    }
  }

  scoredEnough() {
    return this.scoreMap[100]?.length >= this.options.max_results;
  }

  foundEnough() {
    return this.totalResults >= this.options.max_results;
  }

  addResult(object, score) {
    let name;
    (
      this.scoreMap[(name = Math.round(score))] || (this.scoreMap[name] = [])
    ).push(object);
    this.totalResults++;
  }

  getResults() {
    const results = [];
    for (let j = this.scoreMap.length - 1; j >= 0; j--) {
      var objects = this.scoreMap[j];
      if (objects) {
        results.push(...objects);
      }
    }
    return results.slice(0, this.options.max_results);
  }

  sendResults() {
    const results = this.getResults();
    if (results.length) {
      this.triggerResults(results);
    }
  }

  triggerResults(results) {
    this.trigger("results", results);
  }

  delay(fn) {
    return (this.timeout = setTimeout(fn, 1));
  }

  queryToFuzzyRegexp(string) {
    const chars = string.split("");
    for (i = 0; i < chars.length; i++) {
      var char = chars[i];
      chars[i] = $.escapeRegexp(char);
    }
    return new RegExp(chars.join(".*?")); // abc -> /a.*?b.*?c.*?/
  }
};

app.SynchronousSearcher = class SynchronousSearcher extends app.Searcher {
  match() {
    if (this.matcher) {
      if (!this.allResults) {
        this.allResults = [];
      }
      this.allResults.push(...this.getResults());
    }
    return super.match(...arguments);
  }

  free() {
    this.allResults = null;
    return super.free(...arguments);
  }

  end() {
    this.sendResults(true);
    return super.end(...arguments);
  }

  sendResults(end) {
    if (end && this.allResults?.length) {
      return this.triggerResults(this.allResults);
    }
  }

  delay(fn) {
    return fn();
  }
};
