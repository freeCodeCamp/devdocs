
var Git = require('./git');

module.exports = function (baseDir) {

   var dependencies = require('./util/dependencies');

   if (baseDir && !dependencies.exists(baseDir, dependencies.exists.FOLDER)) {
       throw new Error("Cannot use simple-git on a directory that does not exist.");
    }

    return new Git(baseDir || process.cwd(), dependencies.childProcess(), dependencies.buffer());
};

