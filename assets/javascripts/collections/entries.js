// @ts-check

/** Every searchable entry, across every enabled doc. *
 * @extends {Collection<Entry>}
 */
class Entries extends Collection {
  static model = "Entry";
}

// Registered on `app` so that the rest of the code can reach it; declared at
// the top level so that it can be named in a type.
app.collections.Entries = Entries;
