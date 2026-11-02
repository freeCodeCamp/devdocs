// @ts-check

import assert from "node:assert/strict";
import { mkdtemp, readFile, rm, writeFile } from "node:fs/promises";
import { tmpdir } from "node:os";
import { join } from "node:path";
import test from "node:test";
import { deflateSync } from "node:zlib";

import {
  decodeImage,
  encodePng,
  iconCandidates,
  IconError,
  markIcon,
  resize,
  run,
} from "../../scripts/fetch_icon.js";

/** A square image of one colour. */
function solid(size, [r, g, b, a]) {
  const rgba = new Uint8Array(size * size * 4);
  for (let i = 0; i < size * size; i++) rgba.set([r, g, b, a], i * 4);
  return { width: size, height: size, rgba };
}

/** @param {number} x @param {number} y */
const pixel = (image, x, y) => [...image.rgba.subarray((y * image.width + x) * 4, (y * image.width + x) * 4 + 4)];

test("a PNG written by the script reads back the same", () => {
  const image = solid(4, [10, 20, 30, 128]);
  image.rgba.set([255, 0, 0, 255], 0);
  const back = decodeImage(encodePng(image));
  assert.equal(back.width, 4);
  assert.deepEqual([...back.rgba], [...image.rgba]);
});

test("PNG row filters are undone", () => {
  // A 2×2 RGB image: row 1 uses the Sub filter, row 2 Paeth.
  const header = Buffer.alloc(13);
  header.writeUInt32BE(2, 0);
  header.writeUInt32BE(2, 4);
  header.set([8, 2, 0, 0, 0], 8);
  const rows = Buffer.from([
    1, 100, 50, 0, /* + */ 10, 10, 10,
    4, 5, 5, 5, /* Paeth picks up or left */ 0, 0, 0,
  ]);
  const png = Buffer.concat([
    Buffer.from([0x89, 0x50, 0x4e, 0x47, 0x0d, 0x0a, 0x1a, 0x0a]),
    chunk("IHDR", header),
    chunk("IDAT", deflateSync(rows)),
    chunk("IEND", Buffer.alloc(0)),
  ]);
  const image = decodeImage(png);
  assert.deepEqual(pixel(image, 0, 0), [100, 50, 0, 255]);
  assert.deepEqual(pixel(image, 1, 0), [110, 60, 10, 255]);
  assert.deepEqual(pixel(image, 0, 1), [105, 55, 5, 255]);
  // Paeth: left (105,55,5), up (110,60,10), up-left (100,50,0) → p is nearest up.
  assert.deepEqual(pixel(image, 1, 1), [110, 60, 10, 255]);
});

function chunk(type, data) {
  const out = Buffer.alloc(12 + data.length);
  out.writeUInt32BE(data.length, 0);
  out.write(type, 4, "latin1");
  data.copy(out, 8);
  // The script doesn't check CRCs, so any value does here.
  return out;
}

/** @param {[number, Buffer][]} entries Each image's width and file. */
function ico(entries) {
  const header = Buffer.alloc(6 + entries.length * 16);
  header.writeUInt16LE(1, 2);
  header.writeUInt16LE(entries.length, 4);
  let offset = header.length;
  entries.forEach(([width, data], i) => {
    header[6 + i * 16] = width === 256 ? 0 : width;
    header.writeUInt32LE(data.length, 6 + i * 16 + 8);
    header.writeUInt32LE(offset, 6 + i * 16 + 12);
    offset += data.length;
  });
  return Buffer.concat([header, ...entries.map(([, data]) => data)]);
}

test("the largest image in an ICO file is read, PNG or bitmap", () => {
  const small = encodePng(solid(16, [0, 0, 255, 255]));
  const large = encodePng(solid(48, [0, 255, 0, 255]));
  const image = decodeImage(ico([[16, small], [48, large]]));
  assert.equal(image.width, 48);
  assert.deepEqual(pixel(image, 0, 0), [0, 255, 0, 255]);

  // A 2×2, 32-bit bitmap: bottom row first, BGRA, then the 1-bit mask.
  const bmp = Buffer.alloc(40 + 2 * 2 * 4 + 2 * 4);
  bmp.writeUInt32LE(40, 0);
  bmp.writeInt32LE(2, 4);
  bmp.writeInt32LE(4, 8);
  bmp.writeUInt16LE(1, 12);
  bmp.writeUInt16LE(32, 14);
  bmp.set([0, 0, 255, 255, 0, 0, 255, 255], 40); // bottom row: red
  bmp.set([255, 0, 0, 255, 255, 0, 0, 0], 48); // top row: blue, then transparent
  const fromBmp = decodeImage(ico([[2, bmp]]));
  assert.deepEqual(pixel(fromBmp, 0, 0), [0, 0, 255, 255]);
  assert.equal(pixel(fromBmp, 1, 0)[3], 0);
  assert.deepEqual(pixel(fromBmp, 0, 1), [255, 0, 0, 255]);
});

test("an SVG icon is refused with a reason", () => {
  assert.throws(
    () => decodeImage(new TextEncoder().encode('<svg xmlns="http://www.w3.org/2000/svg"></svg>')),
    (error) => error instanceof IconError && /SVG/.test(error.message),
  );
});

test("resizing averages pixels without dark edges", () => {
  // Left half opaque white, right half transparent black.
  const image = solid(64, [0, 0, 0, 0]);
  for (let y = 0; y < 64; y++) for (let x = 0; x < 32; x++) image.rgba.set([255, 255, 255, 255], (y * 64 + x) * 4);
  const small = resize(image, 16);
  assert.deepEqual(pixel(small, 0, 0), [255, 255, 255, 255]);
  assert.equal(pixel(small, 15, 0)[3], 0);

  // Odd sizes average partly covered pixels: 3 → 2.
  const odd = { width: 3, height: 1, rgba: new Uint8Array([0, 0, 0, 255, 255, 255, 255, 255, 0, 0, 0, 255]) };
  const two = resize(odd, 2);
  assert.equal(two.width, 2);
  assert.equal(pixel(two, 0, 0)[0], 85); // two thirds black, one third white
});

test("a wide image is centred in the square", () => {
  const wide = { width: 4, height: 2, rgba: solid(4, [255, 0, 0, 255]).rgba.subarray(0, 32) };
  const square = resize(wide, 4);
  assert.equal(pixel(square, 0, 0)[3], 0);
  assert.deepEqual(pixel(square, 0, 1), [255, 0, 0, 255]);
  assert.equal(pixel(square, 0, 3)[3], 0);
});

test("the page's icons are tried smallest first from 32 pixels, before the usual addresses", () => {
  const html = `<head>
    <link rel="icon" href="/favicon-16.png" sizes="16x16">
    <link rel="stylesheet" href="/site.css">
    <link rel="icon" type="image/svg+xml" href="/logo.svg">
    <link rel="apple-touch-icon" href="touch.png">
    <link href="/favicon-32.png" sizes="32x32" rel="icon">
    <link rel="shortcut icon" href="/old.ico?a=1&amp;b=2">
  </head>`;
  assert.deepEqual(iconCandidates(html, "https://example.com/docs/"), [
    "https://example.com/favicon-32.png",
    "https://example.com/docs/touch.png",
    "https://example.com/old.ico?a=1&b=2",
    "https://example.com/favicon-16.png",
    "https://example.com/apple-touch-icon.png",
    "https://example.com/favicon.ico",
    "https://example.com/logo.svg",
  ]);
});

test("a pack's docs.json is marked, keeping its layout", () => {
  assert.equal(markIcon('[{"name":"Notes","slug":"notes"}]', "notes"), '[{"name":"Notes","slug":"notes","icon":true}]');
  const pretty = markIcon('{\n  "name": "Pack",\n  "docs": [{ "name": "A", "slug": "a" }]\n}\n', "a");
  assert.equal(JSON.parse(pretty || "").docs[0].icon, true);
  assert.ok(pretty?.includes('\n  "docs"'));
  assert.equal(markIcon('[{"name":"A","slug":"a"}]', "b"), null);
});

/** Swaps fetch for a fake website for the length of `fn`. */
async function withSite(files, fn) {
  const real = globalThis.fetch;
  globalThis.fetch = async (url) => {
    const body = files[String(url)];
    return body ? new Response(body, { status: 200 }) : new Response("Not found", { status: 404 });
  };
  try {
    return await fn();
  } finally {
    globalThis.fetch = real;
  }
}

test("a built-in doc gets both sizes and a SOURCE file", async () => {
  const root = await mkdtemp(join(tmpdir(), "icon-"));
  try {
    await withSite(
      {
        "https://example.com/": '<link rel="icon" href="/icon.png" sizes="64x64">',
        "https://example.com/icon.png": encodePng(solid(64, [200, 0, 0, 255])),
      },
      () => run(["example", "https://example.com/"], { root, log: () => {} }),
    );
    const folder = join(root, "public", "icons", "docs", "example");
    assert.equal(decodeImage(await readFile(join(folder, "16.png"))).width, 16);
    assert.deepEqual(pixel(decodeImage(await readFile(join(folder, "16@2x.png"))), 5, 5), [200, 0, 0, 255]);
    assert.equal(await readFile(join(folder, "SOURCE"), "utf8"), "https://example.com/icon.png\n");
  } finally {
    await rm(root, { recursive: true, force: true });
  }
});

test("a pack doc gets its icon and is marked in docs.json", async () => {
  const pack = await mkdtemp(join(tmpdir(), "pack-"));
  try {
    await writeFile(join(pack, "docs.json"), '[{"name":"Notes","slug":"notes~2"}]');
    await withSite(
      {
        // No icon tags: the usual /favicon.ico is used.
        "https://example.com/": "<title>Example</title>",
        "https://example.com/favicon.ico": ico([[32, encodePng(solid(32, [0, 0, 200, 255]))]]),
      },
      () => run(["notes~2", "https://example.com/", "--pack", pack], { log: () => {} }),
    );
    assert.equal(decodeImage(await readFile(join(pack, "notes~2", "16@2x.png"))).width, 32);
    assert.equal(JSON.parse(await readFile(join(pack, "docs.json"), "utf8"))[0].icon, true);
  } finally {
    await rm(pack, { recursive: true, force: true });
  }
});

test("problems are explained in plain sentences", async () => {
  await assert.rejects(run([], { log: () => {} }), /Usage: npm run icon/);
  await assert.rejects(run(["Vue", "https://vuejs.org"], { log: () => {} }), /isn't a doc slug/);
  await assert.rejects(run(["vue", "vuejs.org"], { log: () => {} }), /should start with https:\/\//);
  await assert.rejects(
    withSite({ "https://example.com/": "<p>No icons</p>" }, () =>
      run(["example", "https://example.com/"], { root: tmpdir(), log: () => {} }),
    ),
    /No usable icon was found[\s\S]*--icon/,
  );
});
