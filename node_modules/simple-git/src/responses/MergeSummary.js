module.exports = MergeSummary;
module.exports.MergeConflict = MergeConflict;

var PullSummary = require('./PullSummary');

function MergeConflict (reason, file, meta) {
   this.reason = reason;
   this.file = file;
   if (meta) {
      this.meta = meta;
   }
}

MergeConflict.prototype.meta = null;

MergeConflict.prototype.toString = function () {
   return this.file + ':' + this.reason;
};

function MergeSummary () {
   PullSummary.call(this);

   this.conflicts = [];
   this.merges = [];
}

MergeSummary.prototype = Object.create(PullSummary.prototype);

MergeSummary.prototype.result = 'success';

MergeSummary.prototype.toString = function () {
   if (this.conflicts.length) {
      return 'CONFLICTS: ' + this.conflicts.join(', ');
   }
   return 'OK';
};

Object.defineProperty(MergeSummary.prototype, 'failed', {
   get: function () {
      return this.conflicts.length > 0;
   }
});

MergeSummary.parsers = [
   {
      test: /^Auto-merging\s+(.+)$/,
      handle: function (result, mergeSummary) {
         mergeSummary.merges.push(result[1]);
      }
   },
   {
      // Parser for standard merge conflicts
      test: /^CONFLICT\s+\((.+)\): Merge conflict in (.+)$/,
      handle: function (result, mergeSummary) {
         mergeSummary.conflicts.push(new MergeConflict(result[1], result[2]));
      }
   },
   {
      // Parser for modify/delete merge conflicts (modified by us/them, deleted by them/us)
      test: /^CONFLICT\s+\((.+\/delete)\): (.+) deleted in (.+) and/,
      handle: function (result, mergeSummary) {
         mergeSummary.conflicts.push(
            new MergeConflict(result[1], result[2], {deleteRef: result[3]})
         );
      }
   },
   {
      // Catch-all parser for unknown/unparsed conflicts
      test: /^CONFLICT\s+\((.+)\):/,
      handle: function (result, mergeSummary) {
         mergeSummary.conflicts.push(new MergeConflict(result[1], null));
      }
   },
   {
      test: /^Automatic merge failed;\s+(.+)$/,
      handle: function (result, mergeSummary) {
         mergeSummary.reason = mergeSummary.result = result[1];
      }
   }
];

MergeSummary.parse = function (output) {
   let mergeSummary = new MergeSummary();

   output.trim().split('\n').forEach(function (line) {
      for (var i = 0, iMax = MergeSummary.parsers.length; i < iMax; i++) {
         let parser = MergeSummary.parsers[i];

         var result = parser.test.exec(line);
         if (result) {
            parser.handle(result, mergeSummary);
            break;
         }
      }
   });

   let pullSummary = PullSummary.parse(output);
   if (pullSummary.summary.changes) {
      Object.assign(mergeSummary, pullSummary);
   }

   return mergeSummary;
};
