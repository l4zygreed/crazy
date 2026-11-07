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
