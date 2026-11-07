#### crazy
> A cyberpunk theme for fish shell: slanted neon panels, one or two lines.

```
 ✘ 1 ◤ crazy ◤ conf.d ◤ 1 ◤  main ⟨REBASE⟩ ↑2 ◤  1  3  1  1 ◤  2 ◤
 ❯ ◤                                                       ◢  2m10s ◢  21:47
```

Requires fish 4.1+ (for transient prompt), a Nerd Font and a truecolor terminal.

## Install

```fish
fisher install l4zygreed/lazy
```

## Segments

| Segment | Shows |
| --- | --- |
| Status | Exit code of the last command, if it is not 0 |
| Path | Separate panels: repo name (only below the repo root), current directory, depth (only if above 0). In a git repo, depth starts at the repo root; in `~`, at home |
| Git | Branch (or short SHA), merge/rebase/pick/revert/bisect state, `↑` ahead, `↓` behind |
| Git files | A separate panel, only if there is something to count: `` conflicts, `` staged, `` modified, `` untracked, `` stash |
| Nesting | ranger / yazi icon, plus the total level if it is above 1 |
| Right | Duration of the last command (above a threshold), current time |

Git panel colors (neon palette): cyan is clean, pink is dirty, red is a conflict or an operation in progress. The git files panel uses the same color for its text.

## Settings

```fish
crazy lines 1          # one-line prompt
crazy lines 2          # two-line prompt (default)
crazy lines            # toggle
crazy transient off    # keep full prompts in the history (default: on)
crazy duration 60000   # show command duration above 1 min (default: 120000 ms = 2 min)
crazy duration ignore              # list commands without duration
crazy duration ignore add vim man  # add commands
crazy duration ignore rm tig       # remove commands
crazy duration ignore reset        # default: nvim gg yazi ranger tig
crazy clock off        # hide the clock (default: on)
crazy right off        # hide the whole right prompt (default: on)
crazy palette          # list palettes with color swatches
crazy palette corpo    # set a palette (default: neon)
crazy compact on       # always compact
crazy compact off      # never compact
crazy compact auto 100 # compact below 100 columns (default: auto, 80 columns)
crazy compact max 12   # max dir and branch name length in compact mode (default: 16)
```

Tab completion works for all `crazy` commands and values.

Settings are universal variables: `crazy_prompt_lines`, `crazy_transient`, `crazy_duration_threshold`, `crazy_duration_ignore`, `crazy_clock`, `crazy_right_prompt`, `crazy_palette`, `crazy_compact`, `crazy_compact_width`, `crazy_compact_max`.

## Duration of interactive programs

The theme does not show the duration after interactive programs, for example editors and file managers. The ignore list matches the program name, so these command lines also match:

- `/opt/homebrew/bin/nvim file`, `sudo nvim file`, `EDITOR=x nvim file`
- Aliases: `alias y=yazi` makes `y` match `yazi`.

A function that only calls a program inside its body does not match. Add the function name to the list.

## Compact mode

Compact mode makes the prompt short for narrow windows, for example a split:

- No space at the start of a panel and after icons, one space at the end of a panel.
- No git branch icon.
- No repo name and no depth panels.
- Dir and branch names are cut to `crazy_compact_max` characters: `feature/very-lo…`.
- One total count of changed files instead of the git files panel. No stash count.

```
conf.d ◤feature/very-lo… ◤5 ◤2 ◤
❯ ◤
```

In `auto` mode the theme checks the window width at each prompt.

## Palettes

| Name | Colors |
| --- | --- |
| `neon` | yellow, cyan, hot pink (default) |
| `corpo` | red, silver, black |
| `netrunner` | cyan, acid green, amber |
| `synthwave` | pink, mint, sunset yellow |
| `toxic` | acid lime, aqua, violet |
| `mono` | grayscale, pink accent |

To add your own palette, set a universal variable with 10 hex colors in this order:
`ink dir repo dark clean dirty alert nest arrow dur`.

```fish
set -U crazy_palette_mine 0D0221 FCEE0A B8AD00 2A1B5C 00F0FF FF2A6D FF003C 9D4EDD FF2A6D FF2A6D
crazy palette mine
```

| Role | Used for |
| --- | --- |
| `ink` | Dark text on bright panels |
| `dir` | Current directory panel, text on the error panel |
| `repo` | Repo name panel |
| `dark` | Background of the depth, git files and clock panels |
| `clean` | Git clean, clock text |
| `dirty` | Git dirty |
| `alert` | Error, git conflict or operation in progress |
| `nest` | ranger / yazi nesting |
| `arrow` | Prompt arrow |
| `dur` | Command duration |
