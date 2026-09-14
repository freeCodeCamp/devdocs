// @ts-check

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

/**
 * @typedef {object} SearcherOptions
 * @property {number} [max_results]
 * @property {number} [fuzzy_min_length] Shortest query that is also matched fuzzily.
 */

/**
 * Scores every candidate against a query and emits the best matches.
 *
 * The work is spread over chunks with a timeout between them so that typing
 * stays responsive, and results are emitted as they are found: `results` may
 * fire several times before `end`. The match functions above run against
 * module-level state rather than arguments, which is what keeps the inner
 * loop cheap.
 */
class Searcher extends Events {
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

  /**
   * Reduces a string to the form matches are made against: lowercased, with
   * separators collapsed to dots and decoration stripped.
   *
   * @param {string} string
   * @returns {string}
   */
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

  /**
   * Like `normalizeString`, but keeps a trailing separator meaningful.
   *
   * @param {string} string
   * @returns {string}
   */
  static normalizeQuery(string) {
    string = this.normalizeString(string);
    return string.replace(Searcher.EOS_SEPARATORS_REGEXP, "$1.");
  }

  /** @param {SearcherOptions} [options] */
  constructor(options) {
    super();
    this.options = { ...Searcher.DEFAULTS, ...(options || {}) };
  }

  /**
   * Starts a search, abandoning whatever was running.
   *
   * @param {Model[]} data The models to search. They flow back out through
   *   the `results` event unchanged.
   * @param {string} attr The attribute to match against; a string or an array of them.
   * @param {string} q
   */
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

  /** Prepares the module-level state the match functions read. */
  setup() {
    query = this.query = Searcher.normalizeQuery(this.query);
    queryLength = query.length;
    this.dataLength = this.data.length;
    this.matchers = [exactMatch];
    this.totalResults = 0;
    this.setupFuzzy();
  }

  /** Adds the fuzzy matcher, for queries long enough to warrant it. */
  setupFuzzy() {
    if (queryLength >= this.options.fuzzy_min_length) {
      fuzzyRegexp = this.queryToFuzzyRegexp(query);
      this.matchers.push(fuzzyMatch);
    } else {
      fuzzyRegexp = null;
    }
  }

  /** @returns {boolean} Whether the query is worth running. */
  isValid() {
    return queryLength > 0 && query !== SEPARATOR;
  }

  /** Emits a final empty result set if nothing matched, then `end`. */
  end() {
    if (!this.totalResults) {
      this.triggerResults([]);
    }
    this.trigger("end");
    this.free();
  }

  /** Abandons a search in progress. */
  kill() {
    if (this.timeout) {
      clearTimeout(this.timeout);
      this.free();
    }
  }

  /** Drops the references the search held, so the data can be collected. */
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

  /** Runs the next matcher over the data, or ends the search. */
  match() {
    if (!this.foundEnough() && (this.matcher = this.matchers.shift())) {
      this.setupMatcher();
      this.matchChunks();
    } else {
      this.end();
    }
  }

  /** Resets the per-matcher state: the cursor and the score buckets. */
  setupMatcher() {
    this.cursor = 0;
    this.scoreMap = new Array(101);
  }

  /** Runs one chunk, then either schedules the next or moves to the next matcher. */
  matchChunks() {
    this.matchChunk();

    if (this.cursor === this.dataLength || this.scoredEnough()) {
      this.delay(() => this.match());
      this.sendResults();
    } else {
      this.delay(() => this.matchChunks());
    }
  }

  /** Scores `chunkSize()` candidates, advancing the cursor. */
  matchChunk() {
    ({ matcher } = this);
    for (let j = 0, end = this.chunkSize(); j < end; j++) {
      const model = this.data[this.cursor];
      // The attribute is named at run time, and holds either the model's
      // searchable string or every spelling of it.
      const attribute = /** @type {string | string[]} */ (
        /** @type {Record<string, unknown>} */ (/** @type {unknown} */ (model))[
          this.attr
        ]
      );
      if (typeof attribute === "string") {
        value = attribute;
        valueLength = value.length;
        if ((score = matcher())) {
          this.addResult(model, score);
        }
      } else {
        score = 0;
        for (value of attribute) {
          valueLength = value.length;
          score = Math.max(score, matcher() || 0);
        }
        if (score > 0) {
          this.addResult(model, score);
        }
      }
      this.cursor++;
    }
  }

  /** @returns {number} How many candidates are left in this chunk. */
  chunkSize() {
    if (this.cursor + Searcher.CHUNK_SIZE > this.dataLength) {
      return this.dataLength % Searcher.CHUNK_SIZE;
    } else {
      return Searcher.CHUNK_SIZE;
    }
  }

  /** @returns {boolean} Whether enough perfect matches were found to stop early. */
  scoredEnough() {
    return this.scoreMap[100]?.length >= this.options.max_results;
  }

  /** @returns {boolean} Whether enough matches were found overall. */
  foundEnough() {
    return this.totalResults >= this.options.max_results;
  }

  /**
   * Files a match under its rounded score.
   *
   * @param {Model} object
   * @param {number} score
   */
  addResult(object, score) {
    let name;
    (
      this.scoreMap[(name = Math.round(score))] || (this.scoreMap[name] = [])
    ).push(object);
    this.totalResults++;
  }

  /** @returns {unknown[]} The best matches so far, highest score first. */
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

  /** Emits the matches found so far, if there are any. */
  sendResults() {
    const results = this.getResults();
    if (results.length) {
      this.triggerResults(results);
    }
  }

  /** @param {unknown[]} results */
  triggerResults(results) {
    this.trigger("results", results);
  }

  /**
   * Yields to the event loop between chunks.
   *
   * @param {() => void} fn
   * @returns {number | void} The timeout handle, when there is one.
   */
  delay(fn) {
    return (this.timeout = setTimeout(fn, 1));
  }

  /**
   * @param {string} string
   * @returns {RegExp} A regexp matching the characters in order, e.g. `abc` to `/a.*?b.*?c/`.
   */
  queryToFuzzyRegexp(string) {
    const chars = string.split("");
    for (i = 0; i < chars.length; i++) {
      var char = chars[i];
      chars[i] = $.escapeRegexp(char);
    }
    return new RegExp(chars.join(".*?")); // abc -> /a.*?b.*?c.*?/
  }
}

// Registered on `app` so that the rest of the code can reach it; declared at
// the top level so that it can be named in a type.
app.Searcher = Searcher;

/**
 * A searcher that runs to completion without yielding, and emits its results
 * once at the end. Used where the caller needs an answer before continuing.
 */
class SynchronousSearcher extends app.Searcher {
  /** Collects each matcher's results, instead of emitting them as it goes. */
  match() {
    if (this.matcher) {
      if (!this.allResults) {
        this.allResults = [];
      }
      this.allResults.push(...this.getResults());
    }
    return super.match();
  }

  /** @inheritdoc */
  free() {
    this.allResults = null;
    return super.free();
  }

  /** Emits every result collected, then ends. */
  end() {
    this.sendResults(true);
    return super.end();
  }

  /** @param {boolean} [end] Results are only emitted once, at the end. */
  sendResults(end) {
    if (end && this.allResults?.length) {
      return this.triggerResults(this.allResults);
    }
  }

  /**
   * Runs `fn` straight away, so the search never yields.
   *
   * @param {() => void} fn
   */
  delay(fn) {
    return fn();
  }
}

// Registered on `app` so that the rest of the code can reach it; declared at
// the top level so that it can be named in a type.
app.SynchronousSearcher = SynchronousSearcher;
