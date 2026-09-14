// @ts-check

/** Every searchable entry, across every enabled doc. */
app.collections.Entries = class Entries extends app.Collection {
  static model = "Entry";
};
