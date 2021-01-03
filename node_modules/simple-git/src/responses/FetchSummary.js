'use strict';

function FetchSummary (raw) {
   this.raw = raw;

   this.remote = null;
   this.branches = [];
   this.tags = [];
}

FetchSummary.parsers = [
   [
      /From (.+)$/, function (fetchSummary, matches) {
         fetchSummary.remote = matches[0];
      }
   ],
   [
      /\* \[new branch\]\s+(\S+)\s*\-> (.+)$/, function (fetchSummary, matches) {
         fetchSummary.branches.push({
            name: matches[0],
            tracking: matches[1]
         });
      }
   ],
   [
      /\* \[new tag\]\s+(\S+)\s*\-> (.+)$/, function (fetchSummary, matches) {
         fetchSummary.tags.push({
            name: matches[0],
            tracking: matches[1]
         });
      }
   ]
];

FetchSummary.parse = function (data) {
   var fetchSummary = new FetchSummary(data);

   String(data)
      .trim()
      .split('\n')
      .forEach(function (line) {
         var original = line.trim();
         FetchSummary.parsers.some(function (parser) {
            var parsed = parser[0].exec(original);
            if (parsed) {
               parser[1](fetchSummary, parsed.slice(1));
               return true;
            }
         });
      });

   return fetchSummary;
};

module.exports = FetchSummary;
