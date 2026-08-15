# Completions for the `devdocs` function.
# The command list mirrors `bundle exec thor list docs`; refresh it after adding tasks.

function __devdocs_docs --description "List DevDocs documentation slugs (cached)"
    test -f Thorfile; and command -q bundle; or return

    set -l dir (set -q XDG_CACHE_HOME; and echo $XDG_CACHE_HOME; or echo $HOME/.cache)/devdocs
    set -l cache $dir/docs-list

    # Rebuild when missing/empty or older than a week (`rm` the file to force it).
    set -l stale (find $cache -mtime +7 2>/dev/null)
    if not test -s $cache; or test -n "$stale"
        mkdir -p $dir
        bundle exec thor docs:list >$cache.tmp 2>/dev/null
        set -l ok $status
        if test $ok -eq 0 -a -s $cache.tmp
            mv -f $cache.tmp $cache
        else
            rm -f $cache.tmp
            return
        end
    end

    cat $cache
end

complete -c devdocs -f

# Commands (the `docs:` namespace is implied)
complete -c devdocs -n __fish_is_first_arg -a clean -d 'Delete documentation packages'
complete -c devdocs -n __fish_is_first_arg -a commit -d 'Commit the generated documentations'
complete -c devdocs -n __fish_is_first_arg -a download -d 'Download documentation packages'
complete -c devdocs -n __fish_is_first_arg -a generate -d 'Generate a documentation'
complete -c devdocs -n __fish_is_first_arg -a list -d 'List available documentations'
complete -c devdocs -n __fish_is_first_arg -a manifest -d 'Create the manifest'
complete -c devdocs -n __fish_is_first_arg -a package -d 'Create documentation packages'
complete -c devdocs -n __fish_is_first_arg -a page -d 'Generate a page (no indexing)'
complete -c devdocs -n __fish_is_first_arg -a prepare_deploy -d 'Internal task executed before deployment'
complete -c devdocs -n __fish_is_first_arg -a upload -d 'Upload documentation packages'

# Documentation slugs (<doc> and <doc@version>)
complete -c devdocs -n '__fish_seen_subcommand_from download generate package page' -a '(__devdocs_docs)' -d Documentation

# Options
complete -c devdocs -n '__fish_seen_subcommand_from list upload' -l packaged -d 'Restrict to packaged documentations'

complete -c devdocs -n '__fish_seen_subcommand_from generate' -l all -d 'Generate all documentations'
complete -c devdocs -n '__fish_seen_subcommand_from generate' -l force -d 'Skip the confirmation prompt'
complete -c devdocs -n '__fish_seen_subcommand_from generate' -l package -d 'Package the documentation afterwards'

complete -c devdocs -n '__fish_seen_subcommand_from download' -l all -d 'Download all documentations'
complete -c devdocs -n '__fish_seen_subcommand_from download' -l default -d 'Download the default documentations'
complete -c devdocs -n '__fish_seen_subcommand_from download' -l installed -d 'Download the installed documentations'
complete -c devdocs -n '__fish_seen_subcommand_from download upload' -l rclone -d 'Transfer via rclone'

complete -c devdocs -n '__fish_seen_subcommand_from upload' -l dryrun -d 'Do not upload anything'

complete -c devdocs -n '__fish_seen_subcommand_from commit' -l message -r -d 'Commit message'
complete -c devdocs -n '__fish_seen_subcommand_from commit' -l amend -d 'Amend the last commit'

complete -c devdocs -n '__fish_seen_subcommand_from generate page' -l verbose -d 'Verbose output'
complete -c devdocs -n '__fish_seen_subcommand_from generate page' -l debug -d 'Debug output'
