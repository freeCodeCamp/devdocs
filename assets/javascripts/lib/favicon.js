// @ts-check

/**
 * The favicon the page was served with, read the first time a doc sets one.
 *
 * @type {string | null}
 */
let defaultUrl = null;

/** The doc whose icon is currently shown. @type {string | null} */
let currentSlug = null;

/** Loaded spritesheet and default favicon images, by URL. @type {Record<string, HTMLImageElement>} */
const imageCache = {};

/** Generated favicon data URLs, by doc slug. @type {Record<string, string>} */
const urlCache = {};

/**
 * Runs `action` with the image at `url`, loading and caching it first if need be.
 *
 * @param {string} url
 * @param {(img: HTMLImageElement) => void} action
 */
const withImage = function (url, action) {
  if (imageCache[url]) {
    return action(imageCache[url]);
  } else {
    const img = new Image();
    img.crossOrigin = "anonymous";
    img.src = url;
    return (img.onload = () => {
      imageCache[url] = img;
      return action(img);
    });
  }
};

/**
 * Draws the doc's icon over the default favicon and swaps it in.
 *
 * Does nothing if the doc's icon is already shown, if the user turned
 * doc-specific icons off, or if the icon can't be found.
 *
 * @param {{ slug: string }} doc
 */
this.setFaviconForDoc = function (doc) {
  if (currentSlug === doc.slug || app.settings.get("noDocSpecificIcon")) {
    return;
  }

  const favicon = /** @type {HTMLLinkElement} */ ($('link[rel="icon"]'));

  if (defaultUrl === null) {
    defaultUrl = favicon.href;
  }

  if (urlCache[doc.slug]) {
    favicon.href = urlCache[doc.slug];
    currentSlug = doc.slug;
    return;
  }

  const iconEl = $(`._icon-${doc.slug.split("~")[0]}`);
  if (iconEl === null) {
    return;
  }

  const styles = window.getComputedStyle(iconEl, ":before");

  const backgroundPositionX = styles["background-position-x"];
  const backgroundPositionY = styles["background-position-y"];
  if (backgroundPositionX === undefined || backgroundPositionY === undefined) {
    return;
  }

  const bgUrl = app.config.favicon_spritesheet;
  const sourceSize = 16;
  const sourceX = Math.abs(parseInt(backgroundPositionX.slice(0, -2)));
  const sourceY = Math.abs(parseInt(backgroundPositionY.slice(0, -2)));

  return withImage(bgUrl, (docImg) =>
    withImage(defaultUrl, function (defaultImg) {
      const size = defaultImg.width;

      const canvas = document.createElement("canvas");
      const ctx = canvas.getContext("2d");

      canvas.width = size;
      canvas.height = size;
      ctx.drawImage(defaultImg, 0, 0);

      const docIconPercentage = 65;
      const destinationCoords = (size / 100) * (100 - docIconPercentage);
      const destinationSize = (size / 100) * docIconPercentage;

      ctx.drawImage(
        docImg,
        sourceX,
        sourceY,
        sourceSize,
        sourceSize,
        destinationCoords,
        destinationCoords,
        destinationSize,
        destinationSize,
      );

      try {
        urlCache[doc.slug] = canvas.toDataURL();
        favicon.href = urlCache[doc.slug];

        return (currentSlug = doc.slug);
      } catch (error) {
        Raven.captureException(error, { level: "info" });
        return this.resetFavicon();
      }
    }),
  );
};

/** Puts the default favicon back, if a doc replaced it. */
this.resetFavicon = function () {
  if (defaultUrl !== null && currentSlug !== null) {
    /** @type {HTMLLinkElement} */ ($('link[rel="icon"]')).href = defaultUrl;
    return (currentSlug = null);
  }
};
