function devdocs --description "Run DevDocs' docs: thor tasks (bundle exec thor docs:*)"
    set -l root (__devdocs_root)
    if test -z "$root"
        echo "devdocs: no DevDocs checkout found (no Thorfile); set \$DEVDOCS_ROOT" >&2
        return 1
    end

    set -l args $argv
    if test (count $args) -eq 0
        set args list docs
    else if string match -qv '*:*' -- $args[1]
        # `devdocs clean` -> `thor docs:clean`; namespaced arguments pass through.
        set args[1] docs:$args[1]
    end

    # Thor reads the Thorfile from the current directory.
    pushd $root
    bundle exec thor $args
    set -l code $status
    popd
    return $code
end
