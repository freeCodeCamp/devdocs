function __devdocs_root --description "Print the root of the DevDocs checkout, if any"
    # Explicit override wins, so `devdocs` works from outside the checkout.
    if set -q DEVDOCS_ROOT
        test -f $DEVDOCS_ROOT/Thorfile; and echo $DEVDOCS_ROOT
        return
    end

    set -l root (git rev-parse --show-toplevel 2>/dev/null)
    if test -n "$root" -a -f "$root/Thorfile"
        echo $root
    else if test -f Thorfile
        pwd
    end
end
