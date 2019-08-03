try {
  if (app.config.env === 'production') {
    if (Cookies.get('analyticsConsent') === '1') {
      (function(i,s,o,g,r,a,m){i['GoogleAnalyticsObject']=r;i[r]=i[r]||function(){
        (i[r].q=i[r].q||[]).push(arguments)},i[r].l=1*new Date();a=s.createElement(o),
        m=s.getElementsByTagName(o)[0];a.async=1;a.src=g;m.parentNode.insertBefore(a,m)
      })(window,document,'script','https://www.google-analytics.com/analytics.js','ga');
      ga('create', 'UA-5544833-12', 'devdocs.io');
      page.track(function() {
        ga('send', 'pageview', {
          page: location.pathname + location.search + location.hash,
          dimension1: app.router.context && app.router.context.doc && app.router.context.doc.slug_without_version
        });
      });

      page.track(function() {
        if (window._gauges)
          _gauges.push(['track']);
        else
          (function() {
            var _gauges=_gauges||[];!function(){var a=document.createElement("script");
              a.type="text/javascript",a.async=!0,a.id="gauges-tracker",
                a.setAttribute("data-site-id","51c15f82613f5d7819000067"),
                a.src="https://secure.gaug.es/track.js";var b=document.getElementsByTagName("script")[0];
              b.parentNode.insertBefore(a,b)}();
          })();
      });
    } else {
      resetAnalytics();
    }
  }
} catch(e) { }
