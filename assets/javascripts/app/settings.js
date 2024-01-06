/*
 * decaffeinate suggestions:
 * DS101: Remove unnecessary use of Array.from
 * DS102: Remove unnecessary code created because of implicit returns
 * DS103: Rewrite code to no longer use __guard__, or convert again using --optional-chaining
 * DS104: Avoid inline assignments
 * DS206: Consider reworking classes to avoid initClass
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/main/docs/suggestions.md
 */
(function() {
  let PREFERENCE_KEYS = undefined;
  let INTERNAL_KEYS = undefined;
  const Cls = (app.Settings = class Settings {
    static initClass() {
      PREFERENCE_KEYS = [
        'hideDisabled',
        'hideIntro',
        'manualUpdate',
        'fastScroll',
        'arrowScroll',
        'analyticsConsent',
        'docs',
        'dark', // legacy
        'theme',
        'layout',
        'size',
        'tips',
        'noAutofocus',
        'autoInstall',
        'spaceScroll',
        'spaceTimeout'
      ];
  
      INTERNAL_KEYS = [
        'count',
        'schema',
        'version',
        'news'
      ];
  
      this.prototype.LAYOUTS = [
        '_max-width',
        '_sidebar-hidden',
        '_native-scrollbars',
        '_text-justify-hyphenate'
      ];
  
      this.defaults = {
        count: 0,
        hideDisabled: false,
        hideIntro: false,
        news: 0,
        manualUpdate: false,
        schema: 1,
        analyticsConsent: false,
        theme: 'auto',
        spaceScroll: 1,
        spaceTimeout: 0.5
      };
    }

    constructor() {
      this.store = new CookiesStore;
      this.cache = {};
      this.autoSupported = window.matchMedia('(prefers-color-scheme)').media !== 'not all';
      if (this.autoSupported) {
        this.darkModeQuery = window.matchMedia('(prefers-color-scheme: dark)');
        this.darkModeQuery.addListener(() => this.setTheme(this.get('theme')));
      }
    }


    get(key) {
      let left;
      if (this.cache.hasOwnProperty(key)) { return this.cache[key]; }
      this.cache[key] = (left = this.store.get(key)) != null ? left : this.constructor.defaults[key];
      if ((key === 'theme') && (this.cache[key] === 'auto') && !this.darkModeQuery) {
        return this.cache[key] = 'default';
      } else {
        return this.cache[key];
      }
    }

    set(key, value) {
      this.store.set(key, value);
      delete this.cache[key];
      if (key === 'theme') { this.setTheme(value); }
    }

    del(key) {
      this.store.del(key);
      delete this.cache[key];
    }

    hasDocs() {
      try { return !!this.store.get('docs'); } catch (error) {}
    }

    getDocs() {
      return __guard__(this.store.get('docs'), x => x.split('/')) || app.config.default_docs;
    }

    setDocs(docs) {
      this.set('docs', docs.join('/'));
    }

    getTips() {
      return __guard__(this.store.get('tips'), x => x.split('/')) || [];
    }

    setTips(tips) {
      this.set('tips', tips.join('/'));
    }

    setLayout(name, enable) {
      this.toggleLayout(name, enable);

      const layout = (this.store.get('layout') || '').split(' ');
      $.arrayDelete(layout, '');

      if (enable) {
        if (layout.indexOf(name) === -1) { layout.push(name); }
      } else {
        $.arrayDelete(layout, name);
      }

      if (layout.length > 0) {
        this.set('layout', layout.join(' '));
      } else {
        this.del('layout');
      }
    }

    hasLayout(name) {
      const layout = (this.store.get('layout') || '').split(' ');
      return layout.indexOf(name) !== -1;
    }

    setSize(value) {
      this.set('size', value);
    }

    dump() {
      return this.store.dump();
    }

    export() {
      const data = this.dump();
      for (var key of Array.from(INTERNAL_KEYS)) { delete data[key]; }
      return data;
    }

    import(data) {
      let key, value;
      const object = this.export();
      for (key in object) {
        value = object[key];
        if (!data.hasOwnProperty(key)) { this.del(key); }
      }
      for (key in data) {
        value = data[key];
        if (PREFERENCE_KEYS.indexOf(key) !== -1) { this.set(key, value); }
      }
    }

    reset() {
      this.store.reset();
      this.cache = {};
    }

    initLayout() {
      if (this.get('dark') === 1) {
        this.set('theme', 'dark');
        this.del('dark');
      }
      this.setTheme(this.get('theme'));
      for (var layout of Array.from(this.LAYOUTS)) { this.toggleLayout(layout, this.hasLayout(layout)); }
      this.initSidebarWidth();
    }

    setTheme(theme) {
      if (theme === 'auto') {
        theme = this.darkModeQuery.matches ? 'dark' : 'default';
      }
      const {
        classList
      } = document.documentElement;
      classList.remove('_theme-default', '_theme-dark');
      classList.add('_theme-' + theme);
      this.updateColorMeta();
    }

    updateColorMeta() {
      const color = getComputedStyle(document.documentElement).getPropertyValue('--headerBackground').trim();
      $('meta[name=theme-color]').setAttribute('content', color);
    }

    toggleLayout(layout, enable) {
      const {
        classList
      } = document.body;
      // sidebar is always shown for settings; its state is updated in app.views.Settings
      if ((layout !== '_sidebar-hidden') || !(app.router != null ? app.router.isSettings : undefined)) { classList.toggle(layout, enable); }
      classList.toggle('_overlay-scrollbars', $.overlayScrollbarsEnabled());
    }

    initSidebarWidth() {
      const size = this.get('size');
      if (size) { document.documentElement.style.setProperty('--sidebarWidth', size + 'px'); }
    }
  });
  Cls.initClass();
  return Cls;
})();

function __guard__(value, transform) {
  return (typeof value !== 'undefined' && value !== null) ? transform(value) : undefined;
}