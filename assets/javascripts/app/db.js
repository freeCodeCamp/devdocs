/*
 * decaffeinate suggestions:
 * DS101: Remove unnecessary use of Array.from
 * DS102: Remove unnecessary code created because of implicit returns
 * DS205: Consider reworking code to avoid use of IIFEs
 * DS206: Consider reworking classes to avoid initClass
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/main/docs/suggestions.md
 */
(function() {
  let NAME = undefined;
  let VERSION = undefined;
  const Cls = (app.DB = class DB {
    static initClass() {
      NAME = 'docs';
      VERSION = 15;
    }

    constructor() {
      this.onOpenSuccess = this.onOpenSuccess.bind(this);
      this.onOpenError = this.onOpenError.bind(this);
      this.checkForCorruptedDocs = this.checkForCorruptedDocs.bind(this);
      this.deleteCorruptedDocs = this.deleteCorruptedDocs.bind(this);
      this.versionMultipler = $.isIE() ? 1e5 : 1e9;
      this.useIndexedDB = this.useIndexedDB();
      this.callbacks = [];
    }

    db(fn) {
      if (!this.useIndexedDB) { return fn(); }
      if (fn) { this.callbacks.push(fn); }
      if (this.open) { return; }

      try {
        this.open = true;
        const req = indexedDB.open(NAME, (VERSION * this.versionMultipler) + this.userVersion());
        req.onsuccess = this.onOpenSuccess;
        req.onerror = this.onOpenError;
        req.onupgradeneeded = this.onUpgradeNeeded;
      } catch (error) {
        this.fail('exception', error);
      }
    }

    onOpenSuccess(event) {
      let error;
      const db = event.target.result;

      if (db.objectStoreNames.length === 0) {
        try { db.close(); } catch (error1) {}
        this.open = false;
        this.fail('empty');
      } else if (error = this.buggyIDB(db)) {
        try { db.close(); } catch (error2) {}
        this.open = false;
        this.fail('buggy', error);
      } else {
        this.runCallbacks(db);
        this.open = false;
        db.close();
      }
    }

    onOpenError(event) {
      event.preventDefault();
      this.open = false;
      const {
        error
      } = event.target;

      switch (error.name) {
        case 'QuotaExceededError':
          this.onQuotaExceededError();
          break;
        case 'VersionError':
          this.onVersionError();
          break;
        case 'InvalidStateError':
          this.fail('private_mode');
          break;
        default:
          this.fail('cant_open', error);
      }
    }

    fail(reason, error) {
      this.cachedDocs = null;
      this.useIndexedDB = false;
      if (!this.reason) { this.reason = reason; }
      if (!this.error) { this.error = error; }
      if (error) { if (typeof console.error === 'function') {
        console.error('IDB error', error);
      } }
      this.runCallbacks();
      if (error && (reason === 'cant_open')) {
        Raven.captureMessage(`${error.name}: ${error.message}`, {level: 'warning', fingerprint: [error.name]});
      }
    }

    onQuotaExceededError() {
      this.reset();
      this.db();
      app.onQuotaExceeded();
      Raven.captureMessage('QuotaExceededError', {level: 'warning'});
    }

    onVersionError() {
      const req = indexedDB.open(NAME);
      req.onsuccess = event => {
        return this.handleVersionMismatch(event.target.result.version);
      };
      req.onerror = function(event) {
        event.preventDefault();
        return this.fail('cant_open', error);
      };
    }

    handleVersionMismatch(actualVersion) {
      if (Math.floor(actualVersion / this.versionMultipler) !== VERSION) {
        this.fail('version');
      } else {
        this.setUserVersion(actualVersion - (VERSION * this.versionMultipler));
        this.db();
      }
    }

    buggyIDB(db) {
      if (this.checkedBuggyIDB) { return; }
      this.checkedBuggyIDB = true;
      try {
        this.idbTransaction(db, {stores: $.makeArray(db.objectStoreNames).slice(0, 2), mode: 'readwrite'}).abort(); // https://bugs.webkit.org/show_bug.cgi?id=136937
        return;
      } catch (error) {
        return error;
      }
    }

    runCallbacks(db) {
      let fn;
      while ((fn = this.callbacks.shift())) { fn(db); }
    }

    onUpgradeNeeded(event) {
      let db;
      if (!(db = event.target.result)) { return; }

      const objectStoreNames = $.makeArray(db.objectStoreNames);

      if (!$.arrayDelete(objectStoreNames, 'docs')) {
        try { db.createObjectStore('docs'); } catch (error) {}
      }

      for (var doc of Array.from(app.docs.all())) {
        if (!$.arrayDelete(objectStoreNames, doc.slug)) {
          try { db.createObjectStore(doc.slug); } catch (error1) {}
        }
      }

      for (var name of Array.from(objectStoreNames)) {
        try { db.deleteObjectStore(name); } catch (error2) {}
      }
    }

    store(doc, data, onSuccess, onError, _retry) {
      if (_retry == null) { _retry = true; }
      this.db(db => {
        if (!db) {
          onError();
          return;
        }

        const txn = this.idbTransaction(db, {stores: ['docs', doc.slug], mode: 'readwrite', ignoreError: false});
        txn.oncomplete = () => {
          if (this.cachedDocs != null) {
            this.cachedDocs[doc.slug] = doc.mtime;
          }
          onSuccess();
        };
        txn.onerror = event => {
          event.preventDefault();
          if (((txn.error != null ? txn.error.name : undefined) === 'NotFoundError') && _retry) {
            this.migrate();
            setTimeout(() => {
              return this.store(doc, data, onSuccess, onError, false);
            }
            , 0);
          } else {
            onError(event);
          }
        };

        let store = txn.objectStore(doc.slug);
        store.clear();
        for (var path in data) { var content = data[path]; store.add(content, path); }

        store = txn.objectStore('docs');
        store.put(doc.mtime, doc.slug);
      });
    }

    unstore(doc, onSuccess, onError, _retry) {
      if (_retry == null) { _retry = true; }
      this.db(db => {
        if (!db) {
          onError();
          return;
        }

        const txn = this.idbTransaction(db, {stores: ['docs', doc.slug], mode: 'readwrite', ignoreError: false});
        txn.oncomplete = () => {
          if (this.cachedDocs != null) {
            delete this.cachedDocs[doc.slug];
          }
          onSuccess();
        };
        txn.onerror = function(event) {
          event.preventDefault();
          if (((txn.error != null ? txn.error.name : undefined) === 'NotFoundError') && _retry) {
            this.migrate();
            setTimeout(() => {
              return this.unstore(doc, onSuccess, onError, false);
            }
            , 0);
          } else {
            onError(event);
          }
        };

        let store = txn.objectStore('docs');
        store.delete(doc.slug);

        store = txn.objectStore(doc.slug);
        store.clear();
      });
    }

    version(doc, fn) {
      let version;
      if ((version = this.cachedVersion(doc)) != null) {
        fn(version);
        return;
      }

      this.db(db => {
        if (!db) {
          fn(false);
          return;
        }

        const txn = this.idbTransaction(db, {stores: ['docs'], mode: 'readonly'});
        const store = txn.objectStore('docs');

        const req = store.get(doc.slug);
        req.onsuccess = function() {
          fn(req.result);
        };
        req.onerror = function(event) {
          event.preventDefault();
          fn(false);
        };
      });
    }

    cachedVersion(doc) {
      if (!this.cachedDocs) { return; }
      return this.cachedDocs[doc.slug] || false;
    }

    versions(docs, fn) {
      let versions;
      if (versions = this.cachedVersions(docs)) {
        fn(versions);
        return;
      }

      return this.db(db => {
        if (!db) {
          fn(false);
          return;
        }

        const txn = this.idbTransaction(db, {stores: ['docs'], mode: 'readonly'});
        txn.oncomplete = function() {
          fn(result);
        };
        const store = txn.objectStore('docs');
        var result = {};

        docs.forEach(function(doc) {
          const req = store.get(doc.slug);
          req.onsuccess = function() {
            result[doc.slug] = req.result;
          };
          req.onerror = function(event) {
            event.preventDefault();
            result[doc.slug] = false;
          };
        });
      });
    }

    cachedVersions(docs) {
      if (!this.cachedDocs) { return; }
      const result = {};
      for (var doc of Array.from(docs)) { result[doc.slug] = this.cachedVersion(doc); }
      return result;
    }

    load(entry, onSuccess, onError) {
      if (this.shouldLoadWithIDB(entry)) {
        onError = this.loadWithXHR.bind(this, entry, onSuccess, onError);
        return this.loadWithIDB(entry, onSuccess, onError);
      } else {
        return this.loadWithXHR(entry, onSuccess, onError);
      }
    }

    loadWithXHR(entry, onSuccess, onError) {
      return ajax({
        url: entry.fileUrl(),
        dataType: 'html',
        success: onSuccess,
        error: onError
      });
    }

    loadWithIDB(entry, onSuccess, onError) {
      return this.db(db => {
        if (!db) {
          onError();
          return;
        }

        if (!db.objectStoreNames.contains(entry.doc.slug)) {
          onError();
          this.loadDocsCache(db);
          return;
        }

        const txn = this.idbTransaction(db, {stores: [entry.doc.slug], mode: 'readonly'});
        const store = txn.objectStore(entry.doc.slug);

        const req = store.get(entry.dbPath());
        req.onsuccess = function() {
          if (req.result) { onSuccess(req.result); } else { onError(); }
        };
        req.onerror = function(event) {
          event.preventDefault();
          onError();
        };
        this.loadDocsCache(db);
      });
    }

    loadDocsCache(db) {
      if (this.cachedDocs) { return; }
      this.cachedDocs = {};

      const txn = this.idbTransaction(db, {stores: ['docs'], mode: 'readonly'});
      txn.oncomplete = () => {
        setTimeout(this.checkForCorruptedDocs, 50);
      };

      const req = txn.objectStore('docs').openCursor();
      req.onsuccess = event => {
        let cursor;
        if (!(cursor = event.target.result)) { return; }
        this.cachedDocs[cursor.key] = cursor.value;
        cursor.continue();
      };
      req.onerror = function(event) {
        event.preventDefault();
      };
    }

    checkForCorruptedDocs() {
      this.db(db => {
        let slug;
        this.corruptedDocs = [];
        const docs = ((() => {
          const result = [];
          for (var key in this.cachedDocs) {
            var value = this.cachedDocs[key];
            if (value) {
              result.push(key);
            }
          }
          return result;
        })());
        if (docs.length === 0) { return; }

        for (slug of Array.from(docs)) {
          if (!app.docs.findBy('slug', slug)) {
            this.corruptedDocs.push(slug);
          }
        }

        for (slug of Array.from(this.corruptedDocs)) {
          $.arrayDelete(docs, slug);
        }

        if (docs.length === 0) {
          setTimeout(this.deleteCorruptedDocs, 0);
          return;
        }

        const txn = this.idbTransaction(db, {stores: docs, mode: 'readonly', ignoreError: false});
        txn.oncomplete = () => {
          if (this.corruptedDocs.length > 0) { setTimeout(this.deleteCorruptedDocs, 0); }
        };

        for (var doc of Array.from(docs)) {
          txn.objectStore(doc).get('index').onsuccess = event => {
            if (!event.target.result) { this.corruptedDocs.push(event.target.source.name); }
          };
        }
      });
    }

    deleteCorruptedDocs() {
      this.db(db => {
        let doc;
        const txn = this.idbTransaction(db, {stores: ['docs'], mode: 'readwrite', ignoreError: false});
        const store = txn.objectStore('docs');
        while ((doc = this.corruptedDocs.pop())) {
          this.cachedDocs[doc] = false;
          store.delete(doc);
        }
      });
      Raven.captureMessage('corruptedDocs', {level: 'info', extra: { docs: this.corruptedDocs.join(',') }});
    }

    shouldLoadWithIDB(entry) {
      return this.useIndexedDB && (!this.cachedDocs || this.cachedDocs[entry.doc.slug]);
    }

    idbTransaction(db, options) {
      app.lastIDBTransaction = [options.stores, options.mode];
      const txn = db.transaction(options.stores, options.mode);
      if (options.ignoreError !== false) {
        txn.onerror = function(event) {
          event.preventDefault();
        };
      }
      if (options.ignoreAbort !== false) {
        txn.onabort = function(event) {
          event.preventDefault();
        };
      }
      return txn;
    }

    reset() {
      try { if (typeof indexedDB !== 'undefined' && indexedDB !== null) {
        indexedDB.deleteDatabase(NAME);
      } } catch (error) {}
    }

    useIndexedDB() {
      try {
        if (!app.isSingleDoc() && window.indexedDB) {
          return true;
        } else {
          this.reason = 'not_supported';
          return false;
        }
      } catch (error) {
        return false;
      }
    }

    migrate() {
      app.settings.set('schema', this.userVersion() + 1);
    }

    setUserVersion(version) {
      app.settings.set('schema', version);
    }

    userVersion() {
      return app.settings.get('schema');
    }
  });
  Cls.initClass();
  return Cls;
})();
