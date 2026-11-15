# 017 — How Emacs runs and monitors parallel agent work

I want AI to help Emacs help me write code, PostgreSQL in particular (spec 015).
What I don't understand, and see as a real limitation, is that Emacs runs its Lisp
on one thread. If agents are to work in parallel, streaming results back while
Emacs manages or monitors them, Emacs must have primitives that make that
possible.

## Ask

1. Find the Emacs primitives for asynchronous work: what each one lets run at the
   same time as the editor, and what still blocks it.
2. Find how every reference config in `reference-repos.list` talks to its AI
   packages, and which of those primitives the packages use underneath.
   jwiegley in particular.
3. From that evidence, decide how my setup should launch and monitor parallel
   agent work.

## Scope

The wayfinder map #31 made the decisions; they are recorded under Outcome.
Building them in `literate-emacs.d` is tracked under Build plan, one
`literate-emacs.d` branch per step. A PostgreSQL-aware agent workflow is the
motivating use case.

Related: spec 010 covers the opposite direction, an external agent calling into
Emacs.

## Outcome

Decided on the wayfinder map #31; each item names the `jmccarrell/emacs-config`
ticket that holds the detail. The evidence is in the map's research tickets
(#32-#35).

- **No Lisp threads, no child Emacs.** Agents always run as outside
  processes. Emacs follows them through process filters, sentinels and
  timers, which is what every reference config and AI package does. (#36)
- **Short requests go to gptel.** One prompt, one streamed answer into a
  buffer; several may run at once in different buffers. gptel gets no
  PostgreSQL tools.
  (#36, #41)
- **Long-running coding agents go to claude-code-ide.** The `claude` CLI runs
  in a **ghostel** buffer, one or more sessions per project, so my existing
  Claude Code settings, skills and CLAUDE.md files apply. Through its
  WebSocket connection Claude opens files, reads the selection and
  diagnostics, and proposes edits as ediff sessions. (#36; ghostel replaced
  vterm in `literate-emacs.d` #66)
  - Claude Code's permission prompts and allow-lists stay on; no
    `--dangerously-skip-permissions`.
  - It loads on any machine where `claude` is on `PATH`, not only where
    `jwm/personal-mac-p` is true.
  - ghostel offers to download its prebuilt native module on first use; no
    cmake or libvterm.
- **Session status reaches Emacs through Claude Code hooks**, the pattern
  claude-code.el uses. (#39, #42, #44)
  - Hooks added through `--settings` on sessions claude-code-ide launches
    call `emacsclient` on `Notification` (needs me), `Stop` (turn done),
    `UserPromptSubmit` (working) and `SessionEnd` (ended). Global Claude
    settings are untouched.
  - The receiver is copied from claude-code.el (`03199df`, Apache-2.0) under
    the `jwm/` prefix: an event hook and the `emacsclient` entry point.
    claude-code.el itself is not installed.
  - Each session is named by `CLAUDE_BUFFER_NAME`, added by `:around` advice
    on `claude-code-ide--create-terminal-session`, as minemacs advises it.
  - Display: a message and a mode-line flash; a macOS notification when a
    session needs permission or is waiting for input.
- **Tools.** Claude gets claude-code-ide's built-in Emacs tools
  (`claude-code-ide-emacs-tools-setup`) and the PostgreSQL tools below,
  defined for claude-code-ide only, as jwiegley does. (#36, #41)
- **PostgreSQL tools:** describe schema, run query, explain, and run write.
  (#40, #43)
  - Each call is its own `psql -X --csv` process, with server-side timeouts,
    a 35-second Emacs timer, and a cap of 200 rows or 64 KB of output.
  - The project's mise environment names the logins: `PGUSER_AGENT` for the
    read tools, `PGUSER_AGENT_WRITE` for run write. A tool refuses when its
    variable is unset.
  - The login alone limits what an agent can do. A write commits like any
    other statement, with no confirmation in Emacs. Targets are whatever the
    project points at, the local container or folio.
  - Schema changes are not a tool; they stay Sqitch changes.
- **No blocking calls in agent code I write.** Every tool or helper is
  asynchronous: `make-process` with a callback, a timeout timer, and a
  callback that runs only once. No `call-process`,
  `shell-command-to-string` or `url-retrieve-synchronously`. (#36)

## Build plan

Done; each item names the `jmccarrell/literate-emacs.d` issue that delivered it.
The execution map was `literate-emacs.d` #61.

- [x] **claude-code-ide**, with the built-in Emacs tools on. (#57, then #66 moved
      sessions to ghostel and #67 retired vterm)
- [x] **Session status:** the copied receiver, the `--settings` hooks, the
      `CLAUDE_BUFFER_NAME` advice, and the display. (#58)
- [x] **PostgreSQL read tools:** describe schema, run query, explain. (#59)
- [x] **PostgreSQL run write tool.** (#60)

Work in other repos, done:

- `mcc-lab/lab-infra` #1545: the read-only and writer agent logins on folio
  (lab-gitops #518, lab-infra #1552).
- `jmccarrell/art-of-postgresql` #15: their grants as a Sqitch change deployed to
  folio, the local container, `.pgpass`, `PGUSER_AGENT` and `PGUSER_AGENT_WRITE`
  in `mise.toml`, and AGENTS.md allowing agent row writes to folio.
- `jmccarrell/jwm-bin` #45: `libvterm` dropped from the Brewfile.
