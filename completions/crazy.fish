set -l __crazy_cmds lines transient duration right clock palette compact

# True when the command line has exactly one token after "crazy".
function __crazy_complete_arg -a cmd
    set -l tokens (commandline -opc)
    test (count $tokens) -eq 2; and test "$tokens[2]" = $cmd
end

complete -c crazy -f

complete -c crazy -n "not __fish_seen_subcommand_from $__crazy_cmds" -a lines -d "Set or toggle prompt lines"
complete -c crazy -n "not __fish_seen_subcommand_from $__crazy_cmds" -a transient -d "Collapse old prompts"
complete -c crazy -n "not __fish_seen_subcommand_from $__crazy_cmds" -a duration -d "Min command time to show, ms"
complete -c crazy -n "not __fish_seen_subcommand_from $__crazy_cmds" -a right -d "Show the right prompt"
complete -c crazy -n "not __fish_seen_subcommand_from $__crazy_cmds" -a clock -d "Show the clock"
complete -c crazy -n "not __fish_seen_subcommand_from $__crazy_cmds" -a palette -d "List palettes or set one"
complete -c crazy -n "not __fish_seen_subcommand_from $__crazy_cmds" -a compact -d "Compact mode"

complete -c crazy -n "__crazy_complete_arg lines" -a "1\t'One line' 2\t'Two lines'"
for cmd in transient right clock
    complete -c crazy -n "__crazy_complete_arg $cmd" -a "on off"
end
complete -c crazy -n "__crazy_complete_arg duration" -a "30000\t'30 s' 60000\t'1 min' 120000\t'2 min' 300000\t'5 min'"
complete -c crazy -n "__crazy_complete_arg palette" -a "(__crazy_palette_names)"
complete -c crazy -n "__crazy_complete_arg compact" -a on -d "Always compact"
complete -c crazy -n "__crazy_complete_arg compact" -a off -d "Never compact"
complete -c crazy -n "__crazy_complete_arg compact" -a auto -d "Compact in narrow windows (default)"
complete -c crazy -n "__crazy_complete_arg compact" -a max -d "Max name length"
complete -c crazy -n "__crazy_complete_arg duration" -a ignore -d "Commands without duration"

# crazy duration ignore add|rm|reset
function __crazy_complete_ignore -a sub
    set -l tokens (commandline -opc)
    test "$tokens[2]" = duration; and test "$tokens[3]" = ignore; or return 1
    if test -z "$sub"
        test (count $tokens) -eq 3
    else
        test (count $tokens) -ge 4; and test "$tokens[4]" = $sub
    end
end
complete -c crazy -n "__crazy_complete_ignore" -a add -d "Add commands"
complete -c crazy -n "__crazy_complete_ignore" -a rm -d "Remove commands"
complete -c crazy -n "__crazy_complete_ignore" -a reset -d "Restore the default list"
complete -c crazy -n "__crazy_complete_ignore add" -a "(__fish_complete_command)"
complete -c crazy -n "__crazy_complete_ignore rm" -a "(__crazy_ignore_list)"
