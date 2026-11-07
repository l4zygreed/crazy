function __crazy_duration -a ms -d "Format milliseconds as 3.2s, 1m05s or 1h02m"
    if test $ms -lt 60000
        printf '%.1fs' (math $ms / 1000)
    else if test $ms -lt 3600000
        printf '%dm%02ds' (math -s0 $ms / 60000) (math -s0 $ms / 1000 % 60)
    else
        printf '%dh%02dm' (math -s0 $ms / 3600000) (math -s0 $ms / 60000 % 60)
    end
end

# ----------------------------------------------------------------------------
# Commands without duration (interactive programs: editors, file managers...)
# ----------------------------------------------------------------------------

set -g __crazy_duration_ignore_default nvim gg yazi ranger tig

function __crazy_postexec --on-event fish_postexec -d "Remember the last command line"
    set -g __crazy_last_cmd $argv[1]
end

function __crazy_ignore_list
    if set -q crazy_duration_ignore
        printf '%s\n' $crazy_duration_ignore
    else
        printf '%s\n' $__crazy_duration_ignore_default
    end
end

# Print the program name of a command line. Skips "sudo", "env", "command",
# "builtin", "exec", "time", "nice" and VAR=value. Removes the directory part.
function __crazy_program -a cmdline
    for token in (string split -n ' ' -- $cmdline)
        contains -- $token sudo env command builtin exec time nice; and continue
        string match -qr '^-|^\w+=' -- $token; and continue
        basename -- $token
        return
    end
end

# True if the last command is in the ignore list. Follows aliases
# ("alias y=yazi" makes a function with --wraps=yazi), up to 3 levels.
function __crazy_duration_ignored
    set -l prog (__crazy_program "$__crazy_last_cmd")
    test -n "$prog"; or return 1
    set -l ignore (__crazy_ignore_list)
    for i in 1 2 3
        contains -- $prog $ignore; and return 0
        functions -q -- $prog; or return 1
        set -l wraps (functions -- $prog | string match -rg -- "--wraps[= ]'?([^' ]+)" | head -n1)
        test -n "$wraps"; or return 1
        set prog (basename -- $wraps)
    end
    return 1
end

# crazy duration ignore [add|rm <cmd>...|reset]
function __crazy_ignore_cmd
    set -l list (__crazy_ignore_list)
    switch "$argv[1]"
        case ''
            printf '%s\n' $list
        case add
            for cmd in $argv[2..-1]
                contains -- $cmd $list; or set -a list $cmd
            end
            set -U crazy_duration_ignore $list
        case rm
            for cmd in $argv[2..-1]
                set -l i (contains -i -- $cmd $list); and set -e list[$i]
            end
            set -U crazy_duration_ignore $list
        case reset
            set -Ue crazy_duration_ignore
        case '*'
            echo "crazy: use 'crazy duration ignore [add|rm <cmd>...|reset]'" >&2
            return 1
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
    if test -n "$CMD_DURATION"; and test $CMD_DURATION -ge $threshold; and not __crazy_duration_ignored
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
