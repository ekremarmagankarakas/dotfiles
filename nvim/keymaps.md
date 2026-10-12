# Keymaps Reference

Leader: `Space` | Local leader: `\`

## Essential Vim Motions & Commands

### Movement

| Key | Description |
|-----|-------------|
| `h` `j` `k` `l` | Left, down, up, right |
| `w` `b` | Next word / previous word |
| `e` `ge` | End of word / end of previous word |
| `W` `B` `E` | WORD motions (whitespace-delimited) |
| `0` `$` | Start / end of line |
| `^` | First non-blank character |
| `f{c}` `F{c}` | Jump to next / previous char on line |
| `t{c}` `T{c}` | Jump before next / after previous char |
| `;` `,` | Repeat last `f`/`t` forward / backward |
| `gg` `G` | Top / bottom of file |
| `{` `}` | Previous / next paragraph |
| `%` | Jump to matching bracket |
| `H` `M` `L` | Top / middle / bottom of screen |
| `Ctrl-d` `Ctrl-u` | Half-page down / up |
| `Ctrl-f` `Ctrl-b` | Full page down / up |
| `Ctrl-o` `Ctrl-i` | Jump list back / forward |

### Editing

| Key | Description |
|-----|-------------|
| `i` `a` | Insert before / after cursor |
| `I` `A` | Insert at line start / end |
| `o` `O` | New line below / above |
| `r{c}` | Replace one character |
| `R` | Replace mode |
| `x` | Delete char under cursor |
| `dd` `yy` `cc` | Delete / yank / change line |
| `D` `C` | Delete / change to end of line |
| `J` | Join line below |
| `~` | Toggle case |
| `gu` `gU` | Lowercase / uppercase with motion |
| `.` | Repeat last change |
| `u` `Ctrl-r` | Undo / redo |
| `p` `P` | Paste after / before |
| `"_d` | Delete without yanking |
| `"+y` `"+p` | System clipboard yank / paste |

### Text Objects (use with `d`, `c`, `y`, `v`)

| Key | Description |
|-----|-------------|
| `iw` `aw` | Inner / around word |
| `i"` `a"` | Inner / around quotes |
| `i(` `a(` | Inner / around parens |
| `i{` `a{` | Inner / around braces |
| `i[` `a[` | Inner / around brackets |
| `it` `at` | Inner / around tag |
| `ip` `ap` | Inner / around paragraph |
| `is` `as` | Inner / around sentence |

### Visual Mode

| Key | Description |
|-----|-------------|
| `v` | Character visual |
| `V` | Line visual |
| `Ctrl-v` | Block visual |
| `gv` | Reselect last visual |
| `>` `<` | Indent / unindent selection |
| `=` | Auto-indent selection |

### Search & Substitute

| Key | Description |
|-----|-------------|
| `/pattern` `?pattern` | Search forward / backward |
| `n` `N` | Next / previous match (centered in this config) |
| `*` `#` | Search word under cursor forward / backward |
| `:s/old/new/g` | Substitute in line |
| `:%s/old/new/gc` | Substitute in file with confirm |

### Marks, Registers, Macros

| Key | Description |
|-----|-------------|
| `ma` | Set mark `a` |
| `'a` `` `a `` | Jump to mark `a` |
| `''` | Jump to pre-jump position |
| `"ay` `"ap` | Yank to / paste from register `a` |
| `:reg` | Show registers |
| `qa` | Record macro to register `a` |
| `q` | Stop recording |
| `@a` | Run macro `a` |
| `@@` | Replay last macro |

### Windows & Tabs

| Key | Description |
|-----|-------------|
| `Ctrl-w s` | Horizontal split |
| `Ctrl-w v` | Vertical split |
| `Ctrl-w h/j/k/l` | Move between splits |
| `Ctrl-w =` | Equalize split sizes |
| `Ctrl-w q` | Close split |
| `:tabnew` | New tab |
| `gt` `gT` | Next / previous tab |

## Custom Keymaps

### General (`lua/config/keymaps.lua` + `lua/config/autocmds.lua`)

| Key | Mode | Description |
|-----|------|-------------|
| `<leader>sp` | n | Toggle spell check |
| `<leader>y` | v | Yank to system clipboard |
| `<leader>x` | v | Cut to system clipboard |
| `<leader>/` | n | Clear search highlight |
| `<leader>t` | n | Open terminal split |
| `<leader>T` | n | Open terminal in new tab |
| `<Esc><Esc>` | t | Exit terminal insert mode |
| `yd` | n | Yank current file's directory to system clipboard |
| `<leader>sj` | n | Toggle `j/k` and `gj/gk` |
| `<leader>st` | n | Theme picker |
| `<leader>sr` | n | Search and replace in file |
| `<leader>sq` | n | Search and replace over quickfix |
| `<leader>sv` | n | Toggle virtual edit |
| `<leader>sb` | n | Open scratch buffer (floating, no save) |
| `<leader>sm` | n | Open global cheatsheet (floating, persisted at `~/.local/share/nvim/cheatsheet.md`) |
| `<leader>sM` | n | Open project cheatsheet (floating, persisted at `~/.local/share/nvim/cheatsheets/<project>.md`) |
| `<leader>ms` | n | Convert Markdown buffer to PDF (`:MarkdownToPdf`) |
| `<C-h>` `<C-j>` `<C-k>` `<C-l>` | n | Move across splits |
| `<` `>` | v | Re-indent and keep selection |
| `n` `N` | n | Next/prev search result + center cursor |

### Diagnostics (`lua/config/diagnostics.lua`)

| Key | Mode | Description |
|-----|------|-------------|
| `<leader>lee` | n | Toggle virtual text |
| `<leader>leu` | n | Toggle diagnostic underline |
| `<leader>li` | n | Toggle inlay hints |
| `<leader>lef` | n | Diagnostic float |
| `]d` `[d` | n | Next / previous diagnostic |
| `]e` `[e` | n | Next / previous error |
| `]w` `[w` | n | Next / previous warning |
| `<leader>leq` | n | Send diagnostics to quickfix |
| `<leader>lel` | n | Send diagnostics to location list |
| `<leader>lD` | n | Browse diagnostics (Telescope fallback to quickfix) |

### LSP + Completion (`lua/plugins/lsp.lua`, `lua/plugins/format.lua`, `lua/plugins/lint.lua`)

| Key | Mode | Description |
|-----|------|-------------|
| `gd` `gD` `gy` | n | Go to definition / declaration / type definition |
| `K` | n | Hover |
| `<leader>lr` | n | Rename symbol |
| `<leader>la` | n | Code action |
| `<C-s>` | i | Signature help |
| `grn` `gra` `grr` `gri` `gO` | n | Rename / code action / references / implementation / symbols (Neovim 0.11+ defaults) |
| `<leader>lf` | n | Format file |
| `<leader>ltc` | n | Toggle completion suggestions |
| `<leader>ll` | n | Run linters |
| `<C-p>` `<C-n>` | i | Previous / next completion item |
| `<C-y>` | i | Confirm completion |
| `<C-Space>` | i | Trigger completion |

### Oil (`lua/plugins/file-explorer.lua`)

| Key | Mode | Description |
|-----|------|-------------|
| `-` | n | Open parent directory in Oil |
| `<leader>n` | n | Open parent directory in Oil |

### Telescope (`lua/plugins/telescope.lua`)

| Key | Mode | Description |
|-----|------|-------------|
| `<leader>ff` | n | Find files |
| `<leader>fg` | n | Live grep |
| `<leader>fF` | n | Find files (current buffer's directory) |
| `<leader>fG` | n | Live grep (current buffer's directory) |
| `<leader>fb` | n | Buffers |
| `<leader>fo` | n | Old files |
| `<leader>fw` | n | Grep word under cursor |
| `<leader>fh` | n | Help tags |
| `<leader>fk` | n | Keymaps |
| `<leader>fc` | n | Commands |
| `<leader>fC` | n | Command history |
| `<leader>fs` | n | Fuzzy search current buffer |
| `<leader>fm` | n | Marks |
| `<leader>fj` | n | Jumplist |
| `<leader>fr` | n | Registers |
| `<leader>ft` | n | Treesitter symbols |
| `<leader>f/` | n | Search history |
| `<leader>fq` | n | Quickfix list |
| `<leader>fl` | n | Location list |
| `<leader>fa` | n | Find files in configured base directories (`profile.search_dirs`) |

(`<leader>gtc`/`gts`/`gtB` dispatch to Telescope's git pickers but are bound
in `lua/config/vcs_keymaps.lua`, not here -- see Git / VCS below.)

### Flash (`lua/plugins/tools.lua`)

| Key | Mode | Description |
|-----|------|-------------|
| `s` | n/x/o | Flash jump |
| `S` | n/x/o | Flash Treesitter jump |
| `r` | o | Flash remote |
| `R` | o/x | Flash Treesitter search |

### Treesitter Text Objects (`lua/plugins/treesitter.lua`)

| Key | Mode | Description |
|-----|------|-------------|
| `af` `if` | x/o | Function outer / inner |
| `ac` `ic` | x/o | Class outer / inner |
| `aa` `ia` | x/o | Argument outer / inner |
| `ai` `ii` | x/o | Conditional outer / inner |
| `al` `il` | x/o | Loop outer / inner |
| `]m` `[m` | n/x/o | Next / previous function start |
| `]M` `[M` | n/x/o | Next / previous function end |
| `]]` `[[` | n/x/o | Next / previous class start |
| `][` `[]` | n/x/o | Next / previous class end |
| `]a` `[a` | n/x/o | Next / previous argument |

### Git / VCS (`lua/config/vcs_keymaps.lua`, `lua/config/vcs.lua`)

Hunk, diff, and blame operations are routed through `config.vcs` (see
`lua/config/vcs.lua`). Git is the always-available static fallback. Add
another backend (jj, hg, ...) by calling `vcs.register_provider({ name = ...,
is_active = function() ... end, hunk = {...}, diff = {...}, blame = {...},
pickers = {...} })` from any module; `is_active()` should inspect the current
buffer/cwd (e.g. look for a `.jj` dir) to decide whether that provider should
take over. `get_active_provider()` checks registered providers in
registration order and falls back to Git if none claim the buffer -- there's
no static "selected backend" setting. Any hunk/diff/blame/pickers action a
provider doesn't implement (e.g. a VCS with no staging area) is auto-filled
with a no-op that notifies "not supported", so providers only need to define
what they actually support.

The keymaps below are bound unconditionally from `lua/config/vcs_keymaps.lua`,
independent of whether `gitsigns.nvim`/`diffview.nvim`/`telescope.nvim` are
enabled via profile -- so a custom provider gets full keymap coverage even if
those specific UI plugins are turned off. If the active provider's backing
plugin isn't loaded (e.g. you disabled `gitsigns.nvim` and no other provider
claimed the buffer), the keymap notifies "not loaded" instead of erroring.
`gitsigns.nvim`/`diffview.nvim`/`telescope.nvim`'s own specs (in
`lua/plugins/git.lua`/`telescope.lua`) now only hold their own display/behavior
config -- Diffview's conflict-resolution keymaps (`<leader>dco`/`dct`/`dcb`/
`dca`, `dx`) stay there since they're view-local, not part of this
abstraction.

| Key | Mode | Description |
|-----|------|-------------|
| `<leader>gp` | n | Preview hunk |
| `<leader>gP` | n | Preview hunk inline |
| `]g` `[g` | n | Next / previous hunk |
| `<leader>gs` | n/v | Stage hunk |
| `<leader>gr` | n/v | Reset hunk |
| `<leader>gS` | n | Stage buffer |
| `<leader>gR` | n | Reset buffer |
| `<leader>gu` | n | Undo stage hunk |
| `<leader>gb` | n | Full commit/CL description popup for current line (`blame_line({ full = true })`) |
| `<leader>gB` | n | Full buffer blame |
| `<leader>gtb` | n | Toggle inline line blame |
| `<leader>gT` | n | Toggle git signs |
| `ih` | o/x | Select hunk text object |
| `<leader>gdo` | n | Open Diffview |
| `<leader>gdc` | n | Close Diffview |
| `<leader>gdh` | n | Diffview file history (all) |
| `<leader>gdf` | n | Diffview file history (current file) |
| `<leader>gdt` | n | Diffview toggle file panel |
| `<leader>dco` `<leader>dct` `<leader>dcb` `<leader>dca` | n | Diffview conflict choose ours/theirs/base/all |
| `dx` | n | Diffview conflict: delete region |

### Debug / DAP (`lua/plugins/debug.lua`)

| Key | Mode | Description |
|-----|------|-------------|
| `<leader>dc` | n | Prepare + continue |
| `<leader>dn` `<leader>di` `<leader>do` | n | Step over / into / out |
| `<leader>dC` | n | Run to cursor |
| `<leader>db` | n | Toggle breakpoint |
| `<leader>dB` | n | Conditional breakpoint |
| `<leader>dl` | n | Logpoint |
| `<leader>dh` | n/v | Hover value |
| `<leader>dr` | n | Toggle REPL |
| `<leader>du` | n | Toggle DAP UI |
| `<leader>dq` | n | Terminate session |
| `<leader>ds` | n | Debug nearest Python test |
| `<leader>df` | n | Debug Python test class |
| `<leader>de` | v | Debug selection |
| `<leader>dtj` | n | Toggle `justMyCode` |
| `<leader>dtv` | n | Toggle `.vscode/launch.json` loading |

### AI (`lua/config/ai_keymaps.lua`, `lua/config/ai.lua`, `lua/plugins/ai.lua`)

Suggestion and chat operations are routed through `config.ai` (see
`lua/config/ai.lua`), the same pluggable-provider pattern used for VCS.
Copilot is the always-available static fallback. Add another backend
(CodeCompanion, avante.nvim, a Claude-based chat plugin, ...) by calling
`ai.register_provider({ name = ..., is_active = function() ... end,
suggest = {...}, chat = {...} })` from any module; any `suggest`/`chat`
action it doesn't implement is auto-filled with a no-op that notifies "not
supported". The keymaps below are bound unconditionally from
`lua/config/ai_keymaps.lua`, independent of whether `copilot.lua`/
`CopilotChat.nvim` are enabled via profile -- if the active provider's
backing plugin isn't loaded, the keymap notifies "not loaded" instead of
erroring.

Not part of this abstraction (each plugin's own tightly-coupled UI, stays
in `lua/plugins/ai.lua`): the ghost-text accept/next/prev/dismiss insert-mode
keys, and CopilotChat's chat-buffer-local accept/show/yank-diff keys.

| Key | Mode | Description |
|-----|------|-------------|
| `<leader>act` | n | Toggle inline suggestions |
| `<leader>acd` | n | Disable inline suggestions |
| `<leader>ace` | n | Enable inline suggestions |
| `<leader>aca` | n | Toggle suggestion auto-trigger |
| `Alt-y` | i | Accept Copilot suggestion (copilot.lua-specific) |
| `Alt-]` | i | Next suggestion (copilot.lua-specific) |
| `Alt-[` | i | Previous suggestion (copilot.lua-specific) |
| `Ctrl-]` | i | Dismiss suggestion (copilot.lua-specific) |
| `<leader>aac` | n | Toggle chat |
| `<leader>aaf` | v | Fix selection |
| `<leader>aar` | v | Refactor selection |
| `<leader>aae` | v | Explain selection |
| `<leader>aat` | v | Generate tests for selection |
| `<leader>aaa` | n/i (chat buffer) | CopilotChat: accept diff (CopilotChat-specific) |
| `<leader>aad` | n (chat buffer) | CopilotChat: show diff (CopilotChat-specific) |
| `<leader>aay` | n (chat buffer) | CopilotChat: yank diff (CopilotChat-specific) |

### Other Tools (`lua/plugins/tools.lua`, `lua/plugins/whichkey.lua`, `lua/plugins/markdown.lua`, `lua/plugins/snippets.lua`)

| Key | Mode | Description |
|-----|------|-------------|
| `<leader>ha` `<leader>hd` `<leader>hh` | n | Harpoon add / remove / menu |
| `<leader>h1` `<leader>h2` `<leader>h3` `<leader>h4` | n | Harpoon jump to slots 1-4 |
| `<leader>hp` `<leader>hn` | n | Harpoon previous / next |
| `<leader>?l` | n | Show buffer-local which-key mappings |
| `<leader>?g` | n | Show global which-key mappings |
| `<leader>mf` `<leader>mF` | n | Mkdnflow follow / destroy link |
| `<leader>mc` `<leader>mC` | n/v | Mkdnflow create link / from clipboard |
| `<leader>mn` `<leader>mp` | n | Mkdnflow next / previous link |
| `<leader>mb` `<leader>mB` | n | Mkdnflow back / forward |
| `<leader>mt` | n/v | Mkdnflow toggle todo |
| `<C-j>` `<C-k>` | i/s | LuaSnip expand-or-jump / jump back |

## Profiles

Named profiles (`personal`, `minimal`) toggle plugins, LSP servers, and
`vim.opt`/`vim.g` settings — see `lua/profile.lua`. The Mason-installed
formatter/linter/DAP tool groups ride on the matching plugin's own toggle
(`profile.plugins["conform.nvim"]`, `["nvim-lint"]`, `["nvim-dap"]`) rather
than a separate key, so disabling one of those plugins also stops Mason from
installing its tools. Pick the active profile, in priority order:
`vim.g.nvim_profile`, the `NVIM_PROFILE` env var, a `profile` field returned
from `profile_local.lua`, else `personal`.

Machine-local overrides go in the gitignored `lua/profile_local.lua` or any
file under `lua/local/`, deep-merged on top of the named profile. Three more
fields exist purely to let gitignored config live outside those two spots:

- `profile.rtp_paths` — extra directories prepended to `'runtimepath'`.
- `profile.modules` — extra module names `require()`'d after config loads.
- `profile.plugin_dirs` — extra `{ import = ... }` targets merged into
  `lazy.setup({ spec = ... })` next to `{ import = "plugins" }`.

`lsp.lua` also exposes `profile.extra("lsp_update_capabilities")` and
`profile.extra("lsp_extra_setup")` so other modules can adjust LSP
capabilities or register whole new servers without editing `lsp.lua`.

| Command | Description |
|---------|--------------|
| `:Profile` | Show the active profile name |

## Which-key Groups

| Prefix | Group |
|--------|-------|
| `<leader>a` | ai |
| `<leader>d` | debug |
| `<leader>f` | find |
| `<leader>g` | git |
| `<leader>h` | harpoon |
| `<leader>l` | lsp |
| `<leader>m` | markdown |
| `<leader>n` | files (oil) — currently a single direct action, not an actual submenu |
| `<leader>s` | settings |
| `<leader>?` | whichkey |
