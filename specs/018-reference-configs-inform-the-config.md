# 018 — What the refreshed reference configs suggest for my config, AI first

The reference configs were last refreshed on 2026-09-26 (spec 016). I want them
brought up to date, and the changes since then read for what they suggest for my
Emacs config. My main interest is AI: gptel, claude-code-ide, and how best to use
AI from Emacs. I also want the other changes they made, where they inform how I
might configure Emacs.

## Ask

1. Refresh every repo in `reference-repos.list` and summarize what changed since
   2026-09-26.
2. Find what the reference configs changed in their AI setup, and what changed
   upstream in the AI packages they and I use.
3. Find what else they changed that I might adopt.
4. From that evidence, rank the changes to make to my config, AI first, each
   sized to its own `literate-emacs.d` worktree and pull request.

## Scope

Planning only: the outcome is the ranked list below, not configuration in
`literate-emacs.d`. The spec 017 decisions stand and are built.

## Outcome

Decided on the wayfinder map #45; each item names the `jmccarrell/emacs-config`
ticket that holds the detail. The refresh is in `reference-configs.md` (#46, PR
#54); the evidence is in the map's research tickets (#47, #48, #49).

### Build order

Each item is one `literate-emacs.d` worktree and pull request, built in this
order.

Done: item 1 in `jmccarrell/literate-emacs.d` PR #73, item 2 in PR #75, item 3
in PR #74.

1. **Replace the hand-written gptel tools with `llm-tool-collection`.** (#50,
   #51)
   - Register its `filesystem`, `editing` and `introspection` tags with
     `gptel-make-tool`, as jwiegley does. Its `grep` runs as an asynchronous
     process, which removes the two tools that block Emacs today
     (`list_project_files` and `search_project`, both
     `shell-command-to-string`), as spec 017 requires.
   - Its `system` tools (`bash`, `eval-elisp`) are not registered.
     `read_documentation` goes, as in jwiegley's config.
   - Install it through `jwm/required-vc-packages`, since it is in no package
     archive.
   - Tools stay chosen per request: `gptel-use-tools` at its default and
     `gptel-tools` unset, so no tool is sent unless chosen in `gptel-menu`.
     gptel gets no PostgreSQL tools.
   - The cheat sheet gets gptel's tool-call keys: steering a running request
     (`gptel-send` with prefix argument 0, or `gptel-menu`) and rejecting a
     tool call while the conversation continues (`C-c C-r` in the overlay,
     `r` in the minibuffer prompt). (#48)
2. **`C-x c` as the one prefix for AI commands**, jwiegley's layout. (#51)
   - `C-x c c` opens `claude-code-ide-menu`, replacing the `C-c C-'`
     placeholder from `literate-emacs.d` #57.
   - gptel's keys move from `C-c g` to `C-x c` with the same letters: `g`
     gptel, `s` send, `m` menu, `r` rewrite, `a` add context, `A` clear
     context; `C-x c x` stops a running request (`gptel-abort`).
   - `C-c g` and `C-c C-'` are removed; which-key labels and the cheat sheet
     follow.
   - After item 1, so any new tool keys land under `C-x c`.
3. **Completion and debugging settings from the reference configs.** (#52)
   - `vertico-repeat`, with `vertico-repeat-history` saved through savehist and
     its key binding in the cheat sheet.
   - `corfu-history-mode`, with `corfu-history` saved through savehist.
   - `debugger-stack-frame-as-list`.
   - A cheat-sheet section for the Markdown table keys `gfm-mode` already has.
   - Independent of items 1 and 2.

### Passed on

- gptel presets (#51): nothing I repeat today calls for one.
- agent-shell over ACP (#51): coding agents stay with claude-code-ide.
- yqrashawn's gptel backend that drives the `claude` CLI (#51): duplicates
  claude-code-ide.
- jwiegley's agent-deck (#51): remote sessions I don't need, and its launch
  blocks Emacs.
- OpenRouter free models (#51): the Groq backend covers cheap short requests.
- Upgrading gptel past the installed version (#51): a routine package update.
- The `markdown-ts-mode` trial and Protesilaos's Flymake helper (#52).

### Rule

Config code calls only gptel's public functions, never `gptel--…` ones. (#51)
