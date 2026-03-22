function fish_should_add_to_history --description "Filter commands saved to history"
    set -l cmdline $argv[1]

    # Preserve fish's default behavior: commands that start with a space are not persisted.
    if string match -qr '^[[:space:]]' -- $cmdline
        return 1
    end

    return 0
end
