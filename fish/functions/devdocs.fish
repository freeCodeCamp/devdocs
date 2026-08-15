function devdocs --description "Run DevDocs' docs: thor tasks (bundle exec thor docs:*)"
    set -l args $argv
    if test (count $args) -eq 0
        set args list docs
    else if string match -qv '*:*' -- $args[1]
        # `devdocs clean` -> `thor docs:clean`; namespaced arguments pass through.
        set args[1] docs:$args[1]
    end

    bundle exec thor $args
end
