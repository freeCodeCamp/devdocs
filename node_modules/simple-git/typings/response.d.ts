export interface BranchDeletionSummary {
   branch: string;
   hash: any;
   success: boolean;
}

export interface BranchSummary {
   detached: boolean;
   current: string;
   all: string[];
   branches: {
      [key: string]: {
         current: boolean;
         name: string;
         commit: string;
         label: string;
      };
   };
}

export interface CommitSummary {
   author: null | {
      email: string;
      name: string;
   };
   branch: string;
   commit: string;
   summary: {
      changes: number;
      insertions: number;
      deletions: number;
   };
}

export interface DiffResultTextFile {
   file: string;
   changes: number;
   insertions: number;
   deletions: number;
   binary: boolean;
}

export interface DiffResultBinaryFile {
   file: string;
   before: number;
   after: number;
   binary: boolean;
}

export interface DiffResult {
   /** The total number of files changed as reported in the summary line */
   changed: number;

   /** When present in the diff, lists the details of each file changed */
   files: Array<DiffResultTextFile | DiffResultBinaryFile>;

   /** The number of files changed with insertions */
   insertions: number;

   /** The number of files changed with deletions */
   deletions: number;
}

export interface FetchResult {
   raw: string;
   remote: string | null;
   branches: {
      name: string;
      tracking: string;
   }[];
   tags: {
      name: string;
      tracking: string;
   }[];
}

export interface MoveSummary {
   moves: any[];
}

export interface PullResult {
   /** Array of all files that are referenced in the pull */
   files: string[];

   /** Map of file names to the number of insertions in that file */
   insertions: { [key: string]: number };

   /** Map of file names to the number of deletions in that file */
   deletions: any;

   summary: {
      changes: number;
      insertions: number;
      deletions: number;
   };

   /** Array of file names that have been created */
   created: string[];

   /** Array of file names that have been deleted */
   deleted: string[];
}

export interface RemoteWithoutRefs {
   name: string;
}

export interface RemoteWithRefs extends RemoteWithoutRefs {
   refs: {
      fetch: string;
      push: string;
   };
}

export interface StatusResultRenamed {
   from: string;
   to: string;
}

export interface FileStatusSumary {
   /* Path of the file */
   path: string;
   /* First digit of the status code of the file, e.g. 'M' = modified.
      Represents the status of the index if no merge conflicts, otherwise represents
      status of one side of the merge. */
   index: string;
   /* Second digit of the status code of the file. Represents status of the working directory
      if no merge conflicts, otherwise represents status of other side of a merge. */
   working_dir: string;
}

export interface StatusResult {
   not_added: string[];
   conflicted: string[];
   created: string[];
   deleted: string[];
   modified: string[];
   renamed: StatusResultRenamed[];
   staged: string[];
   files: FileStatusSumary[];
   ahead: number;
   behind: number;
   current: string;
   tracking: string;

   /**
    * Gets whether this represents a clean working branch.
    */
   isClean(): boolean;
}

export interface TagResult {
   all: string[];
   latest: string;
}

export interface DefaultLogFields {
   hash: string;
   date: string;
   message: string;
   refs: string;
   body: string;
   author_name: string;
   author_email: string;
}

/**
 * The ListLogLine represents a single entry in the `git.log`, the properties on the object
 * are mixed in depending on the names used in the format (see `DefaultLogFields`), but some
 * properties are dependent on the command used.
 */
export interface ListLogLine {
   /**
    * When using a `--stat=4096` or `--shortstat` options in the `git.log` or `git.stashList`,
    * each entry in the `ListLogSummary` will also have a `diff` property representing as much
    * detail as was given in the response.
    */
   diff?: DiffResult;
}

export interface ListLogSummary<T = DefaultLogFields> {
   all: ReadonlyArray<T & ListLogLine>;
   total: number;
   latest: T & ListLogLine;
}

/**
 * Where the file was deleted, if there is a modify/delete conflict
 */
export interface MergeConflictDeletion {
   deleteRef: string;
}

/**
 * Represents a single file with conflicts in the MergeSummary
 */
export interface MergeConflict {

   /**
    * Type of conflict
    */
   reason: string;

   /**
    * Path to file
    */
   file: string;

   /**
    * Additional detail for the specific type of conflict
    */
   meta?: MergeConflictDeletion;
}

export interface MergeSummary extends PullResult {
   conflicts: MergeConflict[];
   merges: string[];
   result: "success" | string;
   failed: boolean;
}
