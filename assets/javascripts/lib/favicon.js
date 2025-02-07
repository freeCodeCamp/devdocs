let defaultUrl = null;
let currentSlug = null;

const imageCache = {};
const urlCache = {};

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

this.setFaviconForDoc = function (doc) {
  if (currentSlug === doc.slug || app.settings.get("noDocSpecificIcon")) {
    return;
  }

  const favicon = $('link[rel="icon"]');

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

this.resetFavicon = function () {
  if (defaultUrl !== null && currentSlug !== null) {
    $('link[rel="icon"]').href = defaultUrl;
    return (currentSlug = null);
  }
};
