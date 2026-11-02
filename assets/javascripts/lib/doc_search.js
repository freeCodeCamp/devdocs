// @ts-check

/**
 * Searching within one doc, for the opened doc's menu in the header. Kept
 * free of the app so it can be tested under Node.
 */

/**
 * The entries whose names contain every word of the query, best first: names
 * that are the query, then names that start with it, then the rest, shorter
 * names first within each group.
 *
 * @template {{ name: string }} T
 * @param {T[]} entries
 * @param {string} query
 * @param {number} [limit]
 * @returns {T[]}
 */
export function searchEntries(entries, query, limit = 50) {
  const needle = normalize(query);
  if (!needle) {
    return [];
  }
  const words = needle.split(" ");
  const scored = [];
  for (const entry of entries) {
    const name = normalize(entry.name);
    if (!words.every((word) => name.includes(word))) {
      continue;
    }
    const rank = name === needle ? 0 : name.startsWith(needle) ? 1 : 2;
    scored.push({ entry, rank, length: name.length });
  }
  scored.sort((a, b) => a.rank - b.rank || a.length - b.length);
  return scored.slice(0, limit).map(({ entry }) => entry);
}

/** @param {string} text */
function normalize(text) {
  return text.toLowerCase().replace(/\s+/g, " ").trim();
}
