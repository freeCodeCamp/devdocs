// @ts-check

import { Collection } from "./collection.js";
import { Entry } from "../models/entry.js";

/** Every searchable entry, across every enabled doc. *
 * @extends {Collection<Entry>}
 */
export class Entries extends Collection {
  /** @inheritdoc */
  model() {
    return Entry;
  }
}
