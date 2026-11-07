function __crazy_duration -a ms -d "Format milliseconds as 3.2s, 1m05s or 1h02m"
    if test $ms -lt 60000
        printf '%.1fs' (math $ms / 1000)
    else if test $ms -lt 3600000
        printf '%dm%02ds' (math -s0 $ms / 60000) (math -s0 $ms / 1000 % 60)
    else
        printf '%dh%02dm' (math -s0 $ms / 3600000) (math -s0 $ms / 60000 % 60)
    end
end

function fish_right_prompt -d "Write out the right prompt of the crazy theme"
    test "$crazy_right_prompt" = 0; and return

    set -l clock 1
    test "$crazy_clock" = 0; and set clock 0

    # Transient: keep only the time when the command started.
    if contains -- --final-rendering $argv
        test $clock = 1; and printf '%s' (set_color brblack)(date +%H:%M)(set_color normal)
        return
    end

    set -l threshold 120000
    string match -qr '^\d+$' -- "$crazy_duration_threshold"; and set threshold $crazy_duration_threshold

    # Compact mode: no space at the start of a panel and after icons,
    # one space at the end of a panel.
    set -l pad ' '
    test "$__crazy_compact" = 1; and set pad ''

    set -l prev normal
    if test -n "$CMD_DURATION"; and test $CMD_DURATION -ge $threshold
        printf '%s' (set_color $__crazy_c_dur -b normal) \
            (set_color -o $__crazy_c_ink -b $__crazy_c_dur)"$pad""$pad"(__crazy_duration $CMD_DURATION)" "
        set prev $__crazy_c_dur
    end

    if test $clock = 1
        printf '%s' (set_color $__crazy_c_dark -b $prev) \
            (set_color -o $__crazy_c_clean -b $__crazy_c_dark)"$pad""$pad"(date +%H:%M)" "
    end
    printf '%s' (set_color normal)
end
