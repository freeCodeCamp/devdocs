// @ts-check

/**
 * Downloads a website's icon and saves it the way DevDocs expects.
 *
 *   npm run icon -- <doc_slug> <website>
 *   npm run icon -- <doc_slug> --icon <image address>   to use that image instead
 *
 * It writes public/icons/docs/<slug>/16.png, 16@2x.png and SOURCE, which the
 * spritesheet is built from.
 *
 * The icon is looked up in the page's <link rel="icon"> and
 * <link rel="apple-touch-icon"> tags, then at /apple-touch-icon.png and
 * /favicon.ico. PNG and ICO files are read; SVG ones can't be, without a
 * dependency, so the script says so instead.
 */

import { mkdir, writeFile } from "node:fs/promises";
import { join } from "node:path";
import { fileURLToPath, pathToFileURL } from "node:url";
import { crc32, deflateSync, inflateSync } from "node:zlib";

const PNG_SIGNATURE = Buffer.from([0x89, 0x50, 0x4e, 0x47, 0x0d, 0x0a, 0x1a, 0x0a]);
const SLUG_RGX = /^[a-z0-9_.]+(?:~[a-z0-9_.]+)?$/;
const MAX_DOWNLOAD_BYTES = 2 * 1024 * 1024;

/** An error whose message is meant for the person running the script. */
export class IconError extends Error {
  name = "IconError";
}

/**
 * @typedef {object} Image
 * @property {number} width
 * @property {number} height
 * @property {Uint8Array} rgba Four bytes a pixel, top row first, not premultiplied.
 */

// --- Finding the icon ---------------------------------------------------------

/**
 * The icon addresses to try for a page, best first: the page's own icons, the
 * smallest of those at least 32 pixels wide first, then the usual addresses.
 *
 * @param {string} html
 * @param {string} pageUrl Where the HTML came from, after redirects.
 * @returns {string[]}
 */
export function iconCandidates(html, pageUrl) {
  const links = [];
  // Tried last, so that the reason they can't be used is listed if nothing
  // else works.
  const svgs = [];
  for (const tag of html.match(/<link\b[^>]*>/gi) || []) {
    const rel = attribute(tag, "rel")?.toLowerCase().split(/\s+/) || [];
    const href = attribute(tag, "href");
    if (!href || !(rel.includes("icon") || rel.includes("apple-touch-icon"))) continue;
    let url;
    try {
      url = new URL(decodeEntities(href), pageUrl).href;
    } catch {
      continue;
    }
    const type = attribute(tag, "type")?.toLowerCase() || "";
    if (type.includes("svg") || /\.svg(?:[?#]|$)/i.test(url)) {
      svgs.push(url);
      continue;
    }
    const sizes = (attribute(tag, "sizes") || "")
      .split(/\s+/)
      .map((size) => parseInt(size, 10))
      .filter((size) => size > 0);
    const apple = rel.includes("apple-touch-icon");
    links.push({ url, size: sizes.length ? Math.max(...sizes) : apple ? 180 : 0 });
  }

  const rank = ({ size }) => (size >= 32 ? size : size === 0 ? 10_000 : 20_000 - size);
  links.sort((a, b) => rank(a) - rank(b));

  const origin = new URL(pageUrl).origin;
  const urls = [
    ...links.map((link) => link.url),
    `${origin}/apple-touch-icon.png`,
    `${origin}/favicon.ico`,
    ...svgs,
  ];
  return [...new Set(urls)];
}

/**
 * @param {string} tag
 * @param {string} name
 */
function attribute(tag, name) {
  const match = tag.match(new RegExp(`\\s${name}\\s*=\\s*(?:"([^"]*)"|'([^']*)'|([^\\s>]+))`, "i"));
  return match ? (match[1] ?? match[2] ?? match[3]) : undefined;
}

/** @param {string} text */
function decodeEntities(text) {
  return text.replace(/&amp;/g, "&").replace(/&#38;/g, "&");
}

// --- Reading images -----------------------------------------------------------

/**
 * @param {Uint8Array} bytes A PNG or ICO file.
 * @returns {Image}
 */
export function decodeImage(bytes) {
  const buffer = Buffer.from(bytes.buffer, bytes.byteOffset, bytes.byteLength);
  if (buffer.subarray(0, 8).equals(PNG_SIGNATURE)) return decodePng(buffer);
  if (buffer.length > 6 && buffer.readUInt16LE(0) === 0 && buffer.readUInt16LE(2) === 1) {
    return decodeIco(buffer);
  }
  const start = buffer.subarray(0, 200).toString("latin1").trimStart().toLowerCase();
  if (start.startsWith("<svg") || (start.startsWith("<?xml") && start.includes("<svg"))) {
    throw new IconError("it's an SVG image, which this script can't convert");
  }
  throw new IconError("it isn't a PNG or ICO image");
}

/**
 * @param {Buffer} buffer
 * @returns {Image}
 */
export function decodePng(buffer) {
  let offset = 8;
  let header;
  /** @type {Buffer[]} */
  const data = [];
  let palette;
  let transparency;
  while (offset + 8 <= buffer.length) {
    const length = buffer.readUInt32BE(offset);
    const type = buffer.toString("latin1", offset + 4, offset + 8);
    const chunk = buffer.subarray(offset + 8, offset + 8 + length);
    offset += 12 + length;
    if (type === "IHDR") {
      header = {
        width: chunk.readUInt32BE(0),
        height: chunk.readUInt32BE(4),
        depth: chunk[8],
        colorType: chunk[9],
        interlaced: chunk[12] === 1,
      };
    } else if (type === "PLTE") {
      palette = chunk;
    } else if (type === "tRNS") {
      transparency = chunk;
    } else if (type === "IDAT") {
      data.push(chunk);
    } else if (type === "IEND") {
      break;
    }
  }
  if (!header || data.length === 0) throw new IconError("the PNG image is incomplete");
  const { width, height, depth, colorType } = header;
  if (header.interlaced) throw new IconError("it's an interlaced PNG, which this script can't read");
  const channels = { 0: 1, 2: 3, 3: 1, 4: 2, 6: 4 }[colorType];
  if (!channels || ![1, 2, 4, 8, 16].includes(depth) || width > 4096 || height > 4096) {
    throw new IconError("the PNG image uses a format this script can't read");
  }

  const raw = inflateSync(Buffer.concat(data));
  const bytesPerPixel = Math.max(1, (channels * depth) / 8);
  const stride = Math.ceil((width * channels * depth) / 8);
  if (raw.length < (stride + 1) * height) throw new IconError("the PNG image is incomplete");
  const rows = unfilter(raw, stride, height, bytesPerPixel);

  const rgba = new Uint8Array(width * height * 4);
  const max = (1 << Math.min(depth, 8)) - 1;
  for (let y = 0; y < height; y++) {
    const row = rows.subarray(y * stride, (y + 1) * stride);
    /** @param {number} index Which sample in the row. */
    const sample = (index) => {
      if (depth === 16) return row[index * 2];
      if (depth === 8) return row[index];
      const bit = index * depth;
      return (row[bit >> 3] >> (8 - depth - (bit & 7))) & max;
    };
    for (let x = 0; x < width; x++) {
      const out = (y * width + x) * 4;
      let r, g, b, a = 255;
      if (colorType === 3) {
        const i = sample(x);
        if (!palette || i * 3 + 2 >= palette.length) throw new IconError("the PNG image is damaged");
        [r, g, b] = [palette[i * 3], palette[i * 3 + 1], palette[i * 3 + 2]];
        if (transparency && i < transparency.length) a = transparency[i];
      } else if (colorType === 0 || colorType === 4) {
        const grey = sample(x * channels);
        r = g = b = depth < 8 ? Math.round((grey * 255) / max) : grey;
        if (colorType === 4) a = sample(x * channels + 1);
        else if (transparency && transparency.length >= 2 && grey === transparency.readUInt16BE(0) >> (depth === 16 ? 8 : 0)) a = 0;
      } else {
        r = sample(x * channels);
        g = sample(x * channels + 1);
        b = sample(x * channels + 2);
        if (colorType === 6) a = sample(x * channels + 3);
      }
      rgba.set([r, g, b, a], out);
    }
  }
  return { width, height, rgba };
}

/**
 * Undoes PNG's per-row filters.
 *
 * @param {Buffer} raw
 * @param {number} stride
 * @param {number} height
 * @param {number} bytesPerPixel
 */
function unfilter(raw, stride, height, bytesPerPixel) {
  const out = new Uint8Array(stride * height);
  for (let y = 0; y < height; y++) {
    const filter = raw[y * (stride + 1)];
    const line = raw.subarray(y * (stride + 1) + 1, (y + 1) * (stride + 1));
    const at = y * stride;
    for (let x = 0; x < stride; x++) {
      const left = x >= bytesPerPixel ? out[at + x - bytesPerPixel] : 0;
      const up = y > 0 ? out[at - stride + x] : 0;
      const upLeft = y > 0 && x >= bytesPerPixel ? out[at - stride + x - bytesPerPixel] : 0;
      let value = line[x];
      if (filter === 1) value += left;
      else if (filter === 2) value += up;
      else if (filter === 3) value += (left + up) >> 1;
      else if (filter === 4) {
        const p = left + up - upLeft;
        const [pa, pb, pc] = [Math.abs(p - left), Math.abs(p - up), Math.abs(p - upLeft)];
        value += pa <= pb && pa <= pc ? left : pb <= pc ? up : upLeft;
      } else if (filter !== 0) throw new IconError("the PNG image is damaged");
      out[at + x] = value & 0xff;
    }
  }
  return out;
}

/**
 * Reads the largest image in an ICO file.
 *
 * @param {Buffer} buffer
 * @returns {Image}
 */
export function decodeIco(buffer) {
  const count = buffer.readUInt16LE(4);
  let best;
  for (let i = 0; i < count; i++) {
    const entry = 6 + i * 16;
    if (entry + 16 > buffer.length) break;
    const width = buffer[entry] || 256;
    const size = buffer.readUInt32LE(entry + 8);
    const offset = buffer.readUInt32LE(entry + 12);
    if (offset + size > buffer.length) continue;
    if (!best || width > best.width) best = { width, data: buffer.subarray(offset, offset + size) };
  }
  if (!best) throw new IconError("the ICO file holds no images");
  return best.data.subarray(0, 8).equals(PNG_SIGNATURE) ? decodePng(best.data) : decodeBmp(best.data);
}

/**
 * Reads the bitmap form of an image in an ICO file: a BMP header without the
 * file header, twice the height (the colours, then a transparency mask).
 *
 * @param {Buffer} data
 * @returns {Image}
 */
function decodeBmp(data) {
  const headerSize = data.readUInt32LE(0);
  const width = data.readInt32LE(4);
  const height = Math.abs(data.readInt32LE(8)) / 2;
  const bits = data.readUInt16LE(14);
  const compression = data.readUInt32LE(16);
  if (compression !== 0 || ![1, 4, 8, 24, 32].includes(bits) || width <= 0 || width > 256) {
    throw new IconError("the ICO file uses a format this script can't read");
  }
  const colours = bits <= 8 ? data.readUInt32LE(32) || 1 << bits : 0;
  const palette = data.subarray(headerSize, headerSize + colours * 4);
  const pixels = headerSize + colours * 4;
  const stride = Math.ceil((width * bits) / 32) * 4;
  const maskStart = pixels + stride * height;
  const maskStride = Math.ceil(width / 32) * 4;
  if (maskStart > data.length) throw new IconError("the ICO file is damaged");

  const rgba = new Uint8Array(width * height * 4);
  let anyAlpha = false;
  for (let y = 0; y < height; y++) {
    // Bitmaps are stored bottom row first.
    const row = pixels + (height - 1 - y) * stride;
    for (let x = 0; x < width; x++) {
      const out = (y * width + x) * 4;
      if (bits >= 24) {
        const at = row + x * (bits / 8);
        const a = bits === 32 ? data[at + 3] : 255;
        if (bits === 32 && a > 0) anyAlpha = true;
        rgba.set([data[at + 2], data[at + 1], data[at], a], out);
      } else {
        const bit = x * bits;
        const index = (data[row + (bit >> 3)] >> (8 - bits - (bit & 7))) & ((1 << bits) - 1);
        rgba.set([palette[index * 4 + 2], palette[index * 4 + 1], palette[index * 4], 255], out);
      }
    }
  }
  // Without an alpha channel (or with an empty one), the mask says which
  // pixels are transparent.
  if (bits < 32 || !anyAlpha) {
    for (let y = 0; y < height; y++) {
      const row = maskStart + (height - 1 - y) * maskStride;
      for (let x = 0; x < width; x++) {
        const masked = row + (x >> 3) < data.length && (data[row + (x >> 3)] >> (7 - (x & 7))) & 1;
        rgba[(y * width + x) * 4 + 3] = masked ? 0 : 255;
      }
    }
  }
  return { width, height, rgba };
}

// --- Resizing and writing -----------------------------------------------------

/**
 * Scales an image to fit a square, centred, by averaging the pixels each new
 * pixel covers, which keeps small icons crisp where simpler resizing blurs or
 * drops detail.
 *
 * @param {Image} image
 * @param {number} size
 * @returns {Image}
 */
export function resize(image, size) {
  const scale = Math.min(size / image.width, size / image.height);
  const width = Math.max(1, Math.round(image.width * scale));
  const height = Math.max(1, Math.round(image.height * scale));
  const left = Math.floor((size - width) / 2);
  const top = Math.floor((size - height) / 2);

  // Premultiplied so that transparent pixels' colours don't bleed into edges.
  const source = new Float64Array(image.width * image.height * 4);
  for (let i = 0; i < image.width * image.height; i++) {
    const a = image.rgba[i * 4 + 3] / 255;
    source[i * 4] = image.rgba[i * 4] * a;
    source[i * 4 + 1] = image.rgba[i * 4 + 1] * a;
    source[i * 4 + 2] = image.rgba[i * 4 + 2] * a;
    source[i * 4 + 3] = image.rgba[i * 4 + 3];
  }
  const columns = weights(image.width, width);
  const rows = weights(image.height, height);

  const rgba = new Uint8Array(size * size * 4);
  for (let y = 0; y < height; y++) {
    for (let x = 0; x < width; x++) {
      const sum = [0, 0, 0, 0];
      let total = 0;
      for (const [sy, wy] of rows[y]) {
        for (const [sx, wx] of columns[x]) {
          const weight = wx * wy;
          const at = (sy * image.width + sx) * 4;
          for (let c = 0; c < 4; c++) sum[c] += source[at + c] * weight;
          total += weight;
        }
      }
      const a = sum[3] / total;
      const out = ((top + y) * size + left + x) * 4;
      rgba[out + 3] = Math.round(a);
      if (a > 0) {
        for (let c = 0; c < 3; c++) {
          rgba[out + c] = Math.min(255, Math.round(sum[c] / total / (a / 255)));
        }
      }
    }
  }
  return { width: size, height: size, rgba };
}

/**
 * For each new pixel along one side, the old pixels it covers and how much.
 *
 * @param {number} from
 * @param {number} to
 * @returns {[number, number][][]}
 */
function weights(from, to) {
  const step = from / to;
  return Array.from({ length: to }, (_, i) => {
    const start = i * step;
    const end = start + step;
    const cover = [];
    for (let s = Math.floor(start); s < Math.min(from, Math.ceil(end)); s++) {
      cover.push([s, Math.min(end, s + 1) - Math.max(start, s)]);
    }
    return /** @type {[number, number][]} */ (cover);
  });
}

/**
 * @param {Image} image
 * @returns {Buffer}
 */
export function encodePng({ width, height, rgba }) {
  const rows = Buffer.alloc((width * 4 + 1) * height);
  for (let y = 0; y < height; y++) {
    rows.set(rgba.subarray(y * width * 4, (y + 1) * width * 4), y * (width * 4 + 1) + 1);
  }
  const header = Buffer.alloc(13);
  header.writeUInt32BE(width, 0);
  header.writeUInt32BE(height, 4);
  header.set([8, 6, 0, 0, 0], 8);
  return Buffer.concat([
    PNG_SIGNATURE,
    chunk("IHDR", header),
    chunk("IDAT", deflateSync(rows, { level: 9 })),
    chunk("IEND", Buffer.alloc(0)),
  ]);
}

/**
 * @param {string} type
 * @param {Buffer} data
 */
function chunk(type, data) {
  const out = Buffer.alloc(12 + data.length);
  out.writeUInt32BE(data.length, 0);
  out.write(type, 4, "latin1");
  data.copy(out, 8);
  out.writeUInt32BE(crc32(out.subarray(4, 8 + data.length)), 8 + data.length);
  return out;
}

// --- Saving -------------------------------------------------------------------

/**
 * @param {string} url
 * @returns {Promise<{ bytes: Uint8Array, url: string, type: string }>}
 */
async function download(url) {
  let response;
  try {
    response = await fetch(url, { redirect: "follow", headers: { "User-Agent": "DevDocs icon fetcher" } });
  } catch {
    throw new IconError(`couldn't connect to ${new URL(url).host}`);
  }
  if (!response.ok) throw new IconError(`the server answered ${response.status}`);
  const bytes = new Uint8Array(await response.arrayBuffer());
  if (bytes.length > MAX_DOWNLOAD_BYTES) throw new IconError("the file is too big for an icon");
  return { bytes, url: response.url || url, type: response.headers.get("content-type") || "" };
}

/**
 * @param {string} website
 * @param {string | undefined} iconUrl An image to use instead of looking one up.
 * @param {(message: string) => void} log
 * @returns {Promise<{ image: Image, url: string }>}
 */
async function findIcon(website, iconUrl, log) {
  let candidates = iconUrl ? [iconUrl] : [];
  if (!iconUrl) {
    const page = await download(website).catch((error) => {
      throw new IconError(`Couldn't open ${website}: ${error.message}. Check the address, or pass the icon's own address with --icon.`);
    });
    candidates = iconCandidates(new TextDecoder().decode(page.bytes), page.url);
  }
  const problems = [];
  for (const url of candidates) {
    try {
      const { bytes } = await download(url);
      const image = decodeImage(bytes);
      if (image.width < 32 || image.height < 32) {
        log(`Note: the best icon found is ${image.width}×${image.height} pixels, so the 32-pixel version is enlarged and may look soft.`);
      }
      return { image, url };
    } catch (error) {
      if (!(error instanceof IconError)) throw error;
      problems.push(`${url}: ${error.message}`);
    }
  }
  throw new IconError(
    `No usable icon was found. Tried:\n  ${problems.join("\n  ")}\n` +
      "Save a PNG of the icon somewhere online and pass its address with --icon, or add the files by hand.",
  );
}

/**
 * @param {string[]} args
 * @param {{ root?: string, log?: (message: string) => void }} [options]
 */
export async function run(args, { root = process.cwd(), log = console.log } = {}) {
  const positional = [];
  const flags = {};
  for (let i = 0; i < args.length; i++) {
    if (args[i] === "--icon") flags.icon = args[++i];
    else positional.push(args[i]);
  }
  const [slug, website] = positional;
  if (!slug || !(website || flags.icon) || positional.length > 2) {
    throw new IconError(
      "Usage: npm run icon -- <doc_slug> <website> [--icon <image address>]\n" +
        "Example: npm run icon -- vue https://vuejs.org",
    );
  }
  if (!SLUG_RGX.test(slug)) {
    throw new IconError(`"${slug}" isn't a doc slug. Slugs are lower case, like "vue" or "my_notes~2".`);
  }
  for (const [name, value] of [["website", website], ["--icon", flags.icon]]) {
    if (value && !/^https?:\/\//i.test(value)) {
      throw new IconError(`The ${name} address should start with https://, like https://vuejs.org.`);
    }
  }

  const { image, url } = await findIcon(website, flags.icon, log);

  const folder = join(root, "public", "icons", "docs", slug.split("~")[0]);
  await mkdir(folder, { recursive: true });
  await writeFile(join(folder, "16.png"), encodePng(resize(image, 16)));
  await writeFile(join(folder, "16@2x.png"), encodePng(resize(image, 32)));
  await writeFile(join(folder, "SOURCE"), url + "\n");
  log(`Saved the icon from ${url} to ${folder}. Restart DevDocs to rebuild the spritesheet, and check it looks right at 16 pixels.`);
}

if (process.argv[1] && import.meta.url === pathToFileURL(process.argv[1]).href) {
  const root = fileURLToPath(new URL("..", import.meta.url));
  run(process.argv.slice(2), { root }).catch((error) => {
    console.error(error instanceof IconError ? error.message : `Something went wrong: ${error.message}`);
    process.exitCode = 1;
  });
}
