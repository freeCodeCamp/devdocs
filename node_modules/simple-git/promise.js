
if (typeof Promise === 'undefined') {
   throw new ReferenceError("Promise wrappers must be enabled to use the promise API");
}

function isAsyncCall (fn) {
   return /^[^)]+then\s*\)/.test(fn) || /\._run\(/.test(fn);
}

module.exports = function (baseDir) {

   var Git = require('./src/git');
   var gitFactory = require('./src');
   var git;


   var chain = Promise.resolve();

   try {
      git = gitFactory(baseDir);
   }
   catch (e) {
      chain = Promise.reject(e);
   }

   return Object.keys(Git.prototype).reduce(function (promiseApi, fn) {
      if (/^_|then/.test(fn)) {
         return promiseApi;
      }

      if (isAsyncCall(Git.prototype[fn])) {
         promiseApi[fn] = git ? asyncWrapper(fn, git) : function () {
            return chain;
         };
      }

      else {
         promiseApi[fn] = git ? syncWrapper(fn, git, promiseApi) : function () {
            return promiseApi;
         };
      }

      return promiseApi;

   }, {});

   function asyncWrapper (fn, git) {
      return function () {
         var args = [].slice.call(arguments);

         if (typeof args[args.length] === 'function') {
            throw new TypeError(
               "Promise interface requires that handlers are not supplied inline, " +
               "trailing function not allowed in call to " + fn);
         }

         return chain.then(function () {
            return new Promise(function (resolve, reject) {
               args.push(function (err, result) {
                  if (err) {
                     return reject(toError(err));
                  }

                  resolve(result);
               });

               git[fn].apply(git, args);
            });
         });
      };
   }

   function syncWrapper (fn, git, api) {
      return function () {
         git[fn].apply(git, arguments);

         return api;
      };
   }

};

function toError (error) {

   if (error instanceof Error) {
      return error;
   }

   if (typeof error === 'string') {
      return new Error(error);
   }

   return Object.create(new Error(error), {
      git: { value: error },
   });
}
