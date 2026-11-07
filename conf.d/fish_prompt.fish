# name: crazy
# A cyberpunk-styled fish prompt with slanted neon panels.

# ----------------------------------------------------------------------------
# Palettes
# ----------------------------------------------------------------------------

# Each palette is a list of 10 hex colors, in this role order:
#   1 ink    dark text on bright panels
#   2 dir    current directory panel, text on the error panel
#   3 repo   repo name panel
#   4 dark   background of depth, git counts and clock panels
#   5 clean  git clean, clock text
#   6 dirty  git dirty
#   7 alert  error, git conflict or operation in progress
#   8 nest   ranger / yazi nesting
#   9 arrow  prompt arrow
#  10 dur    command duration
#
# Add your own palette: set -U crazy_palette_<name> <10 colors>

set -g __crazy_palettes neon corpo netrunner synthwave toxic mono
set -g __crazy_palette_desc_neon "yellow, cyan, hot pink (default)"
set -g __crazy_palette_desc_corpo "red, silver, black"
set -g __crazy_palette_desc_netrunner "cyan, acid green, amber"
set -g __crazy_palette_desc_synthwave "pink, mint, sunset yellow"
set -g __crazy_palette_desc_toxic "acid lime, aqua, violet"
set -g __crazy_palette_desc_mono "grayscale, pink accent"

#                          ink    dir    repo   dark   clean  dirty  alert  nest   arrow  dur
set -g __crazy_palette_neon 0D0221 FCEE0A B8AD00 2A1B5C 00F0FF FF2A6D FF003C 9D4EDD FF2A6D FF2A6D
set -g __crazy_palette_corpo 0A0A0A FF1E3C 8C0F1F 1F1F24 E6E6E6 FF6B00 FFD400 7A7A85 FF1E3C FF6B00
set -g __crazy_palette_netrunner 001014 00F0FF 0099A8 062A30 39FF14 FFB000 FF2052 7B61FF 00F0FF FFB000
set -g __crazy_palette_synthwave 1A0B2E FF6AD5 B04DB3 2D1B4E 6EF0B4 FFD54F FF4466 41E0F0 FF6AD5 FFD54F
set -g __crazy_palette_toxic 0B1100 B6FF00 6F9A00 1C2610 00FFC6 FFE600 FF3D00 C04BFF B6FF00 FFE600
set -g __crazy_palette_mono 111111 D0D0D0 8A8A8A 2A2A2A A0A0A0 FF2A6D FF003C 6A6A6A FF2A6D FF2A6D

# Print the 10 colors of a palette. Returns 1 if the palette does not exist.
function __crazy_palette_colors -a name
    for var in crazy_palette_$name __crazy_palette_$name
        if set -q $var; and test (count $$var) -eq 10
            printf '%s\n' $$var
            return 0
        end
    end
    return 1
end

# Print all palette names, with descriptions for completions.
function __crazy_palette_names
    for name in $__crazy_palettes
        set -l desc __crazy_palette_desc_$name
        printf '%s\t%s\n' $name $$desc
    end
    for var in (set -n | string match -r '^crazy_palette_.+')
        set -l name (string replace crazy_palette_ '' $var)
        contains -- $name $__crazy_palettes; or printf '%s\t%s\n' $name custom
    end
end

# Set the __crazy_c_* globals. Runs again only when crazy_palette changes,
# so a change in one session reaches all sessions on the next prompt.
function __crazy_load_palette
    set -l name neon
    __crazy_palette_colors "$crazy_palette" >/dev/null; and set name $crazy_palette
    test "$__crazy_palette_loaded" = "$name"; and return

    set -l c (__crazy_palette_colors $name)
    set -g __crazy_c_ink $c[1]
    set -g __crazy_c_dir $c[2]
    set -g __crazy_c_repo $c[3]
    set -g __crazy_c_dark $c[4]
    set -g __crazy_c_clean $c[5]
    set -g __crazy_c_dirty $c[6]
    set -g __crazy_c_alert $c[7]
    set -g __crazy_c_nest $c[8]
    set -g __crazy_c_arrow $c[9]
    set -g __crazy_c_dur $c[10]
    set -g __crazy_palette_loaded $name
end

# Print one line for each palette: a swatch of its colors and its name.
function __crazy_palette_list
    set -l current neon
    __crazy_palette_colors "$crazy_palette" >/dev/null; and set current $crazy_palette
    for line in (__crazy_palette_names)
        set -l name (string split -f1 \t $line)
        set -l desc (string split -f2 \t $line)
        set -l mark ' '
        test $name = $current; and set mark '*'
        set -l swatch
        for c in (__crazy_palette_colors $name)
            set -a swatch (set_color -b $c)'  '
        end
        printf '%s %s%s  %-10s %s\n' $mark (string join '' $swatch) (set_color normal) $name $desc
    end
end

# ----------------------------------------------------------------------------
# Settings
# ----------------------------------------------------------------------------

# crazy_prompt_lines        1 or 2 (default 2)
# crazy_duration_threshold  ms; show command duration above this (default 120000)
# crazy_transient           1 or 0; collapse old prompts (default 1)
# crazy_right_prompt        1 or 0; show the right prompt (default 1)
# crazy_clock               1 or 0; show the clock in the right prompt (default 1)
# crazy_palette             palette name (default neon)
# crazy_compact             on, off or auto (default auto)
# crazy_compact_width       auto: compact below this many columns (default 80)
# crazy_compact_max         compact: max length of dir and branch names (default 16)

if test "$crazy_transient" != 0
    set -g fish_transient_prompt 1
end

function crazy -d "Configure the crazy prompt theme"
    switch "$argv[1]"
        case lines
            set -l n $argv[2]
            if test -z "$n"
                test (__crazy_lines) = 2; and set n 1; or set n 2
            end
            if not contains -- $n 1 2
                echo "crazy: lines must be 1 or 2" >&2
                return 1
            end
            set -U crazy_prompt_lines $n
        case transient
            switch "$argv[2]"
                case on 1
                    set -U crazy_transient 1
                    set -g fish_transient_prompt 1
                case off 0
                    set -U crazy_transient 0
                    set -g fish_transient_prompt 0
                case '*'
                    echo "crazy: use 'crazy transient on|off'" >&2
                    return 1
            end
        case duration
            if not string match -qr '^\d+$' -- "$argv[2]"
                echo "crazy: use 'crazy duration <ms>'" >&2
                return 1
            end
            set -U crazy_duration_threshold $argv[2]
        case right clock
            set -l var crazy_right_prompt
            test "$argv[1]" = clock; and set var crazy_clock
            switch "$argv[2]"
                case on 1
                    set -U $var 1
                case off 0
                    set -U $var 0
                case '*'
                    echo "crazy: use 'crazy $argv[1] on|off'" >&2
                    return 1
            end
        case palette
            if test -z "$argv[2]"
                __crazy_palette_list
                return
            end
            if not __crazy_palette_colors $argv[2] >/dev/null
                echo "crazy: unknown palette '$argv[2]'. Run 'crazy palette' to list palettes." >&2
                return 1
            end
            set -U crazy_palette $argv[2]
        case compact
            switch "$argv[2]"
                case on off
                    set -U crazy_compact $argv[2]
                case auto
                    if set -q argv[3]
                        if not string match -qr '^\d+$' -- $argv[3]
                            echo "crazy: use 'crazy compact auto [columns]'" >&2
                            return 1
                        end
                        set -U crazy_compact_width $argv[3]
                    end
                    set -U crazy_compact auto
                case max
                    if not string match -qr '^[1-9]\d*$' -- "$argv[3]"
                        echo "crazy: use 'crazy compact max <chars>'" >&2
                        return 1
                    end
                    set -U crazy_compact_max $argv[3]
                case '*'
                    echo "crazy: use 'crazy compact on|off|auto [columns]|max <chars>'" >&2
                    return 1
            end
        case '*'
            echo "usage: crazy lines [1|2]          set or toggle prompt lines"
            echo "       crazy transient on|off     collapse old prompts"
            echo "       crazy duration <ms>        min command time to show"
            echo "       crazy right on|off         show the right prompt"
            echo "       crazy clock on|off         show the clock"
            echo "       crazy palette [name]       list palettes or set one"
            echo "       crazy compact on|off       compact mode"
            echo "       crazy compact auto [cols]  compact below this width"
            echo "       crazy compact max <chars>  max name length in compact mode"
            test -z "$argv[1]"
    end
end

# Set __crazy_compact (1 or 0) and __crazy_sp (space between icon and text).
function __crazy_update_compact
    set -g __crazy_compact 0
    switch "$crazy_compact"
        case on
            set __crazy_compact 1
        case off
        case '*'
            set -l width 80
            string match -qr '^\d+$' -- "$crazy_compact_width"; and set width $crazy_compact_width
            test $COLUMNS -lt $width; and set __crazy_compact 1
    end
    set -g __crazy_sp ' '
    test $__crazy_compact = 1; and set __crazy_sp ''
end

# Shorten a name in compact mode: "feature/very-long-bra…"
function __crazy_shorten -a text
    if test "$__crazy_compact" = 1
        set -l max 16
        string match -qr '^[1-9]\d*$' -- "$crazy_compact_max"; and set max $crazy_compact_max
        string shorten -m $max -- $text
    else
        echo $text
    end
end

function __crazy_lines
    if contains -- "$crazy_prompt_lines" 1 2
        echo $crazy_prompt_lines
    else
        echo 2
    end
end

# ----------------------------------------------------------------------------
# Panels
# ----------------------------------------------------------------------------

# Print one panel and remember its color for the next separator.
# The first panel of a line starts with a flat background, without a slant.
function __crazy_panel -a bg fg text
    if test -n "$__crazy_prev_bg"
        printf '%s' (set_color $__crazy_prev_bg -b $bg)
    end
    # Compact mode: no space at the start, one space at the end.
    set -l pad ' '
    test "$__crazy_compact" = 1; and set pad ''
    printf '%s' (set_color -o $fg -b $bg)"$pad$text "(set_color normal)
    set -g __crazy_prev_bg $bg
end

function __crazy_panel_end
    if test -n "$__crazy_prev_bg"
        printf '%s' (set_color $__crazy_prev_bg -b normal)(set_color normal)
    end
    set -g __crazy_prev_bg
end

# ----------------------------------------------------------------------------
# Git
# ----------------------------------------------------------------------------

# Read the git state into __crazy_git_* globals. Returns 1 outside a repo.
# Uses only two git calls: rev-parse and status.
function __crazy_git
    set -l rp (command git rev-parse --show-toplevel --absolute-git-dir 2>/dev/null)
    or return 1
    set -g __crazy_git_top $rp[1]
    set -l gd $rp[2]

    set -l st (command git status --porcelain=v2 --branch --show-stash --ignore-submodules=dirty 2>/dev/null)

    set -g __crazy_git_head (string replace -rf '^# branch\.head ' '' -- $st)
    if test "$__crazy_git_head" = "(detached)"
        set -g __crazy_git_head (string replace -rf '^# branch\.oid ' '' -- $st | string sub -l 7)
    end

    set -l ab (string match -r '^# branch\.ab \+(\d+) -(\d+)$' -- $st)
    set -g __crazy_git_ahead 0
    set -g __crazy_git_behind 0
    if set -q ab[3]
        set __crazy_git_ahead $ab[2]
        set __crazy_git_behind $ab[3]
    end

    set -g __crazy_git_stash (string replace -rf '^# stash ' '' -- $st)
    test -n "$__crazy_git_stash"; or set __crazy_git_stash 0

    # Entry lines: "1 XY ..." / "2 XY ..." changed, "u" unmerged, "?" untracked.
    set -g __crazy_git_staged (count (string match -r '^[12] [^.]' -- $st))
    set -g __crazy_git_modified (count (string match -r '^[12] .[^.]' -- $st))
    set -g __crazy_git_untracked (count (string match -r '^\? ' -- $st))
    set -g __crazy_git_conflicts (count (string match -r '^u ' -- $st))

    set -g __crazy_git_state
    if test -d $gd/rebase-merge -o -d $gd/rebase-apply
        set __crazy_git_state REBASE
    else if test -f $gd/MERGE_HEAD
        set __crazy_git_state MERGE
    else if test -f $gd/CHERRY_PICK_HEAD
        set __crazy_git_state PICK
    else if test -f $gd/REVERT_HEAD
        set __crazy_git_state REVERT
    else if test -f $gd/BISECT_LOG
        set __crazy_git_state BISECT
    end
    return 0
end

# Panels: [branch, state, ahead/behind] [file counts]
# The counts panel appears only if there is something to count.
# Compact mode: short branch name, one total count of changed files, no stash.
function __crazy_git_panels
    set -l bg $__crazy_c_clean
    set -l changed (math $__crazy_git_staged + $__crazy_git_modified + $__crazy_git_untracked)
    test $changed -gt 0; and set bg $__crazy_c_dirty
    test $__crazy_git_conflicts -gt 0 -o -n "$__crazy_git_state"; and set bg $__crazy_c_alert

    # Compact mode: no git icon.
    set -l info (__crazy_shorten $__crazy_git_head)
    test "$__crazy_compact" = 1; or set info " $info"
    test -n "$__crazy_git_state"; and set info "$info ⟨$__crazy_git_state⟩"
    test $__crazy_git_ahead -gt 0; and set info "$info ↑$__crazy_git_ahead"
    test $__crazy_git_behind -gt 0; and set info "$info ↓$__crazy_git_behind"
    __crazy_panel $bg $__crazy_c_ink "$info"

    if test "$__crazy_compact" = 1
        set -l total (math $changed + $__crazy_git_conflicts)
        test $total -gt 0; and __crazy_panel $__crazy_c_dark $bg $total
        return
    end

    # Codicons: git_branch_conflicts, diff_added, diff_modified, question, git_stash
    set -l counts
    test $__crazy_git_conflicts -gt 0; and set -a counts " $__crazy_git_conflicts"
    test $__crazy_git_staged -gt 0; and set -a counts " $__crazy_git_staged"
    test $__crazy_git_modified -gt 0; and set -a counts " $__crazy_git_modified"
    test $__crazy_git_untracked -gt 0; and set -a counts " $__crazy_git_untracked"
    test $__crazy_git_stash -gt 0; and set -a counts " $__crazy_git_stash"
    if set -q counts[1]
        __crazy_panel $__crazy_c_dark $bg "$counts"
    end
end

# ----------------------------------------------------------------------------
# Path panels: [repo] [dir] [depth]
# Repo appears only below the repo root. Depth appears only if it is above 0.
# Compact mode: only the short directory name.
# ----------------------------------------------------------------------------

function __crazy_path_panels -a in_git
    set -l name (basename (prompt_pwd))
    if test $name = "~"
      set name " ~"
    end

    if test "$__crazy_compact" = 1
        __crazy_panel $__crazy_c_dir $__crazy_c_ink (__crazy_shorten $name)
        return
    end

    set -l repo
    set -l depth 0

    if test "$in_git" = 1
        set -l here (pwd -P)
        if test "$here" != "$__crazy_git_top"
            set repo (basename $__crazy_git_top)
            set depth (math (count (string split -n / -- $here)) - (count (string split -n / -- $__crazy_git_top)))
        end
    else if string match -q -- "$HOME*" $PWD
        set depth (math (count (string split -n / -- $PWD)) - (count (string split -n / -- $HOME)))
    else
        set depth (count (string split -n / -- $PWD))
    end

    test -n "$repo"; and __crazy_panel $__crazy_c_repo $__crazy_c_ink $repo
    __crazy_panel $__crazy_c_dir $__crazy_c_ink $name
    test $depth -gt 0; and __crazy_panel $__crazy_c_dark $__crazy_c_dir $depth
end

# ----------------------------------------------------------------------------
# Prompt
# ----------------------------------------------------------------------------

function fish_prompt -d "Write out the left prompt of the crazy theme"
    set -l last_status $status
    __crazy_load_palette

    # Transient: compact line for prompts that are already in the history.
    if contains -- --final-rendering $argv
        printf '%s' (set_color $__crazy_c_dir)(basename (prompt_pwd)) \
            (set_color $__crazy_c_arrow)' ❯ '(set_color normal)
        return
    end

    set -g __crazy_prev_bg
    __crazy_update_compact
    set -l sp $__crazy_sp

    # Exit status
    if test $last_status -ne 0
        __crazy_panel $__crazy_c_alert $__crazy_c_dir "✘$sp$last_status"
    end

    # Path and git
    set -l in_git 0
    __crazy_git; and set in_git 1
    __crazy_path_panels $in_git
    test $in_git = 1; and __crazy_git_panels

    # ranger / yazi nesting: one icon, plus the total level if it is above 1
    set -l nest 0
    string match -qr '^\d+$' -- "$RANGER_LEVEL"; and set nest (math $nest + $RANGER_LEVEL)
    string match -qr '^\d+$' -- "$YAZI_LEVEL"; and set nest (math $nest + $YAZI_LEVEL)
    if test $nest -gt 1
        __crazy_panel $__crazy_c_nest $__crazy_c_ink "$sp$nest"
    else if test $nest -eq 1
        __crazy_panel $__crazy_c_nest $__crazy_c_ink 
    end

    # Prompt arrow: a mini panel, alert color after an error
    set -l arrow_bg $__crazy_c_arrow
    test $last_status -ne 0; and set arrow_bg $__crazy_c_alert

    if test (__crazy_lines) = 2
        __crazy_panel_end
        printf '\n'
    end
    __crazy_panel $arrow_bg $__crazy_c_ink ❯
    __crazy_panel_end
    printf ' '
end
