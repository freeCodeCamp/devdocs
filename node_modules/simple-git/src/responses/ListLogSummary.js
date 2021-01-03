
module.exports = ListLogSummary;

var DiffSummary = require('./DiffSummary');

/**
 * The ListLogSummary is returned as a response to getting `git().log()` or `git().stashList()`
 *
 * @constructor
 */
function ListLogSummary (all) {
   this.all = all;
   this.latest = all.length && all[0] || null;
   this.total = all.length;
}

/**
 * Detail for each of the log lines
 * @type {ListLogLine[]}
 */
ListLogSummary.prototype.all = null;

/**
 * Most recent entry in the log
 * @type {ListLogLine}
 */
ListLogSummary.prototype.latest = null;

/**
 * Number of items in the log
 * @type {number}
 */
ListLogSummary.prototype.total = 0;

function ListLogLine (line, fields) {
   for (var k = 0; k < fields.length; k++) {
      this[fields[k]] = line[k] || '';
   }
}

/**
 * When the log was generated with a summary, the `diff` property contains as much detail
 * as was provided in the log (whether generated with `--stat` or `--shortstat`.
 * @type {DiffSummary}
 */
ListLogLine.prototype.diff = null;

ListLogSummary.START_BOUNDARY = 'òòòòòò ';

ListLogSummary.COMMIT_BOUNDARY = ' òò';

ListLogSummary.SPLITTER = ' ò ';

ListLogSummary.parse = function (text, splitter, fields) {
   fields = fields || ['hash', 'date', 'message', 'refs', 'author_name', 'author_email'];
   return new ListLogSummary(
      text
         .trim()
         .split(ListLogSummary.START_BOUNDARY)
         .filter(function(item) { return !!item.trim(); })
         .map(function (item) {
            var lineDetail = item.trim().split(ListLogSummary.COMMIT_BOUNDARY);
            var listLogLine = new ListLogLine(lineDetail[0].trim().split(splitter), fields);

            if (lineDetail.length > 1 && !!lineDetail[1].trim()) {
               listLogLine.diff = DiffSummary.parse(lineDetail[1]);
            }

            return listLogLine;
         })
   );
};
