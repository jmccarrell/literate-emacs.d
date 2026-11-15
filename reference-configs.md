# Reference Emacs configs — synthesis

This file is the canonical home for analysis of other developers' Emacs
configs: which repos we treat as ground-truth references during
investigations, what we've already extracted from each, and how recent
upstream changes should influence Jeff's roadmap. It is committed to
this repo and travels with the project. The actual cloned repos in
`reference-emacs-configs/` are a per-machine cache, rebuildable from the
inventory in `reference-repos.list` via `just ref-show-plan`.

**Last refreshed:** 2026-11-11 (spec 018 map: every repo brought up to
date to plan the next config changes, AI first; summary in
[2026-11-11 refresh](#2026-11-11-refresh)). Previous: 2026-09-26 (spec 016,
ahead of spec 015's SQL/PostgreSQL research).

## Inventory vs. synthesis

The inventory in `reference-repos.list` tracks all registered repos, with
last-known-SHAs for change detection. This synthesis file covers the repos
we actively analyze (HIGH/MEDIUM tier) — they're the ones whose patterns we
extract into our own config.

The other inventory-only repos are tracked for state preservation but are not
subjects of ongoing investigation. Any of them can be promoted to active
analysis by adding a section here; the inventory tooling already snapshots
their state.

## Relationship to the Landscape Document

`literate-emacs.d/emacs-2026-landscape.org` owns Jeff's modernization
roadmap: the section-by-section map, shipped work, pending backlog, and open
questions. This file owns the reference-repo intelligence that feeds that
roadmap.

When `just ref-show-changes` turns up new upstream commits:

1. Summarize the repo-specific signal here.
2. Update the landscape only if the signal changes a recommendation,
   priority, shipped-note, or pending sub-goal.
3. Avoid duplicating repo-by-repo commit surveys in the landscape.

## Tracked repos at a glance

The `name` column is also the local directory under
`reference-emacs-configs/` and the registry key in
`reference-repos.list`. The rows below are the actively-analyzed subset of
the inventory.

| name                           | URL                                                   | tier   | use for                                  |
|--------------------------------|-------------------------------------------------------|--------|------------------------------------------|
| steve-purcell-dotemacs         | https://github.com/purcell/emacs.d                    | HIGH   | per-language patterns; clean migration templates |
| jwiegley-dotemacs              | https://github.com/jwiegley/dot-emacs                 | HIGH   | AI / LLM integration; gptel; local models |
| yqrashawn-yqdotfiles           | https://github.com/yqrashawn/yqdotfiles               | HIGH   | advanced gptel tools, MCP, agent/proxy backends |
| bbatsov-dotemacs               | https://github.com/bbatsov/emacs.d                    | MEDIUM | pragmatic 2026 modernizations; theme + UI nits |
| sacha-chua-dotemacs            | https://github.com/sachac/.emacs.d                    | MEDIUM | practical gptel / agent-shell use in Org workflows |
| munen-emacs.d                  | https://github.com/munen/emacs.d                      | MEDIUM | gptel custom tools; MCP integration |
| redguardtoo-emacs.d            | https://github.com/redguardtoo/emacs.d                | MEDIUM | compact gptel + macher + agent-shell setup |
| abougouffa-minemacs            | https://github.com/abougouffa/minemacs                | MEDIUM | local/cloud LLM stack; Ellama, gptel, Aidermacs, MCP |
| matthewzmd-emacs.d             | https://github.com/MatthewZMD/.emacs.d                | MEDIUM | Aidermacs author config; OpenRouter model defaults |
| oantolin-emacs-config          | https://github.com/oantolin/emacs-config              | MEDIUM | Embark / Orderless / Vertico author config; built-ins first; Groq gptel |
| protesilaos-dotfiles           | https://github.com/protesilaos/dotfiles               | MEDIUM | literate config in modules; built-ins first; completion, Dired, Org, windows |

Tier definitions:

- **HIGH** — Active source for current or imminent sub-goals.
- **MEDIUM** — Useful for specific topic areas; consult when those areas come up.
- **LOW / DORMANT** — Either inactive upstream, inventory-only, or
  supplanted by HIGH/MEDIUM refs. Promote by adding a section here when a
  specific question makes the repo relevant again.

## 2026-11-11 refresh

Spec 018 map (issue #45). Every repo in `reference-repos.list` was
fast-forwarded to its upstream; ranges run from the SHA recorded at the
2026-09-26 refresh. The deeper surveys are separate tickets on that map: AI
changes in the configs (#47), upstream AI package changes (#48), and
everything else (#49).

| repo | commits | span | activity |
|------|---------|------|----------|
| redguardtoo-emacs.d | 37 | 2026-09-29 → 2026-11-11 | very active |
| sacha-chua-dotemacs | 33 | 2026-09-17 → 2026-11-04 | active again |
| yqrashawn-yqdotfiles | 31 | 2026-10-06 → 2026-11-11 | very active; mostly machine setup |
| jwiegley-dotemacs | 21 | 2026-09-26 → 2026-11-10 | active |
| protesilaos-dotfiles | 17 | 2026-09-29 → 2026-11-01 | active |
| abougouffa-minemacs | 15 | 2026-09-29 → 2026-10-29 | active; mostly version bumps |
| oantolin-emacs-config | 14 | 2026-10-06 → 2026-11-08 | active |
| munen-emacs.d | 6 | 2026-10-01 → 2026-10-19 | moderate |
| steve-purcell-dotemacs | 1 | 2026-10-18 | quiet |
| abo-abo-dotemacs | 0 | last commit 2025-12-17 | quiet |
| andreyorst-dotfiles | 0 | last commit 2026-09-04 | quiet |
| bbatsov-dotemacs | 0 | last commit 2026-07-29 | quiet |
| matthewzmd-emacs.d | 0 | last commit 2026-03-14 | quiet |
| manateelazycat-lazycat-emacs | 0 | last commit 2026-02-23 | quiet; clone needs repair |

### Agents and LLMs

- **oantolin removed gptel** (2026-11-08): "It keeps freezing Emacs", and he
  did not use it enough to debug it. Earlier in the range he had removed
  `gptel-extras-mini` and added a workaround for a gptel bug sending output
  to the wrong buffer.
- **jwiegley** grew `ob-agent-deck` and `org-agent-deck` (sessions on
  agent-deck remotes, a background command runner, joining agent-mail, an
  `:ultracode` option for Claude and Codex). He dropped claude-code-ide's
  Emacs tools (`claude-code-ide-emacs-tools-setup`, `ab0235976`) because his
  Nix wrapper around `claude` refuses the `--mcp-config` flag that passes
  them. His gptel setup is unchanged.
- **redguardtoo** configured `agent-shell` with a DeepSeek agent over ACP
  (`lisp/init-ai.el`).
- **Sacha** added an OpenRouter gptel backend with free models.
- **yqrashawn**'s Emacs changes are MCP server registration in
  `.doom.d/mcp.el` (with a new test file) and a fix for non-ASCII text when
  rewriting `~/.claude.json`; he dropped his rtk Claude Code hook.

### Other areas

- **Completion and editing:** redguardtoo replaced `company-statistics` with
  `company-prescient`, switched to `ast-grep` for structural search and
  `web-mode` for `.tsx`, and removed `auto-package-update`. Protesilaos set
  `completion-flex-nospace` to nil and dropped Flymake's fancy indicators.
- **Markdown and Org:** oantolin moved to `markdown-ts-mode` and turned on
  `visual-line-mode` in Org buffers; Protesilaos adopted `denote-data-mode`.
- **Packages dropped:** Purcell dropped `docker-compose-mode`.
- **minemacs** supports more than one compilation database per project.
- **jwiegley** added `dired-filter` and bookmark-backed Dired groups.
- **Sacha** and **munen** changes are personal workflow (speech-to-text,
  video, mu4e, Pomodoro) with nothing to adopt.

No repo changed anything for SQL, PostgreSQL, language-server setup, mise or
direnv.

### Repair, and candidates to drop

- **manateelazycat-lazycat-emacs** — the local clone has every file staged
  for deletion (empty index, `HEAD` at `200684c3`), so it was not pulled.
  Upstream has no new commits. `git -C reference-emacs-configs/manateelazycat-lazycat-emacs reset --hard`
  restores it; left for Jeff. No commits since 2026-02-23. Dropped 2026-11-12.
- **abo-abo-dotemacs** — no commits since 2025-12-17. Dropped 2026-11-12.
  **matthewzmd-emacs.d** — none since 2026-03-14; kept.

## 2026-09-26 refresh

Spec 016. Every repo in `reference-repos.list` was fast-forwarded to its
upstream. Ranges run from the SHA the inventory recorded at the 2026-04-26
sync (for `andreyorst-dotfiles`, which had none, from 2026-04-26 by date); per-repo detail is in each repo's
"2026-09-26 refresh" block under [Per-repo notes](#per-repo-notes).

| repo | commits | span | activity |
|------|---------|------|----------|
| abougouffa-minemacs | 301 | 2026-04-26 → 2026-09-26 | very active |
| jwiegley-dotemacs | 177 | 2026-04-28 → 2026-09-25 | very active |
| redguardtoo-emacs.d | 63 | 2026-04-27 → 2026-09-24 | very active |
| bbatsov-dotemacs | 62 | 2026-04-15 → 2026-07-29 | active |
| yqrashawn-yqdotfiles | 56 | 2026-05-13 → 2026-09-22 | very active |
| sacha-chua-dotemacs | 22 | 2026-05-28 → 2026-05-31 | bursts; quiet since June |
| steve-purcell-dotemacs | 20 | 2026-06-18 → 2026-08-29 | active, small commits |
| munen-emacs.d | 9 | 2026-05-21 → 2026-08-19 | moderate |
| jkitchin-scimax | 2 | 2026-04-23 → 2026-04-28 | inactive (discontinued); dropped 2026-09-26 |
| abo-abo-dotemacs | 0 | last commit 2025-12-17 | quiet |
| matthewzmd-emacs.d | 0 | last commit 2026-03-14 | quiet |
| manateelazycat-lazycat-emacs | 0 | last commit 2026-02-23 | quiet |
| danielmai-dotemacs | 0 | last commit 2023-02-15 | abandoned; dropped 2026-09-26 |
| oantolin-emacs-config | added this refresh | last commit 2026-09-18 | active |
| protesilaos-dotfiles | added this refresh | last Emacs commit 2026-09-23 | very active |
| andreyorst-dotfiles | 11 since 2026-04-26 | 2026-05-07 → 2026-09-04 | active (clone had been stale since 2021) |

### SQL and PostgreSQL

No repo changed anything SQL-related in its range. What exists today, all
predating the range:

- **steve-purcell-dotemacs** `lisp/init-sql.el` — the most complete
  `sql.el` setup: `--no-psqlrc` in `sql-postgres-options`, `C-c C-z` to the
  SQLi buffer, persistent `.sqli_history`, `sqlformat` on `C-c C-f`, and
  `sanityinc/sql-explain-region-as-json` (EXPLAIN ANALYZE as JSON via `psql`).
  `lisp/init-org.el:384` enables `ob-sql`.
- **yqrashawn-yqdotfiles** — the only language-server and formatter setup:
  `ejc-sql` with org-table results and a capf wrapper
  (`.doom.d/prog.el:213-248`), `sqlfluff fix --dialect postgres` as the
  sql-mode formatter (`.doom.d/lang.el:133-136`), `sqls` and `sqlfluff`
  installed by nix, the `pg` client package, and a local Postgres with
  pgvector.
- **munen-emacs.d** — per-project `sql-postgres-login-params` saved as safe
  dir-local values (`custom-settings.el:254,262`).
- **jwiegley-dotemacs** — `sql` + `sql-indent` (`init.org:6355-6384`) and
  `org-mssql` (`init.org:12014`), a possible template for an auth-source-backed
  PostgreSQL equivalent. `edbi` was removed in the range.
- **abougouffa-minemacs** — only lists `sqlformat`, `pg_format` and `sqlint`
  in its external-tools catalogue (`core/me-external-tools.el`); no SQL
  configuration.
- **andreyorst-dotfiles** — `ob-sql`, `sql-indent`, and `sql-clickhouse`
  (`.config/emacs/init.el:950,1352-1358`); no PostgreSQL specifics.
- **abo-abo-dotemacs** — an org structure template that inserts
  `#+begin_src sql :engine postgresql` (`modes/ora-org.el:394`).
- **jwiegley-dotemacs** also loads `pgmacs`, a table browser built on the
  pure-elisp `pg` client (`init.org:5732-5736`).
- Sacha and scimax use SQLite only; bbatsov and redguardtoo have no SQL setup.

The practices chosen from these are in
[SQL and PostgreSQL decisions](#sql-and-postgresql-decisions-spec-015).

### Per-project environment (mise, direnv)

No repo configures mise (`git grep -wi mise` over every refreshed tree; the
only hits are commented-out `mise activate` lines in yqrashawn's zsh nix
module). Purcell and yqrashawn use `envrc`; minemacs made its `envrc` module
obsolete in 2025-10; the rest use `exec-path-from-shell`. Two repos pass
per-project settings through safe `.dir-locals.el` values instead: munen for
Postgres login parameters, minemacs for eglot's clangd arguments
(`core/extras/me-eglot-x.el:246-272`). Whether Emacs can use mise directly
is left to spec 015's research step.

### Agents and LLMs

- **jwiegley** dropped agent-shell, ACP, gptel-agent, macher and his LiteLLM
  routing; kept gptel, claude-code-ide and aider. gptel backends are now one
  function each, generated from a single host/model registry
  (`lisp/gptel-backends.el`), defaulting to a Hermes Agent backend on his host
  Vulcan. New `ob-agent-deck` launches coding-agent sessions from Org blocks.
- **yqrashawn** rebuilt his gptel Claude Code presets (long-lived
  per-subtree sessions) on two separate routes: an HTTP proxy on localhost
  (the default `ccl` backend) and a gptel backend that runs the `claude` CLI
  as a subprocess, added `ai-code` and `eca`, dropped copilot and
  aidermacs, added MCP servers, and wrote a Claude Code PR-review plugin. His
  gptel abort-logging advice (`.doom.d/llm.el`) is cheap to copy.
- **minemacs** added `claude-code-ide` (`modules/me-ai.el:103-147`).
- **redguardtoo** dropped aider and its local Ollama backends; added
  `agent-shell` (installed, not configured) and `macher`, a gptel-based patch
  workflow (`lisp/init-ai.el:32-44`).
- **munen** added gptel `ddgs_search` and `read_url` tools.
- **oantolin** (added this refresh) runs gptel on Groq with
  `openai/gpt-oss-120b` as the default, the same choice as spec 012
  (`init.el:310-345`).
- Sacha's gptel and agent-shell setup is unchanged.

### Language servers and tree-sitter

bbatsov rebuilt around eglot plus built-in ts-modes, with guarded
`major-mode-remap-alist` entries (`init.el:1178-1205`) and Flycheck 38's
eglot bridge. Purcell disabled eglot semantic tokens. minemacs made the eglot
contact configurable per project and added grammars.

### Repair, and candidates to drop

- **andreyorst-dotfiles** — the local clone's `origin` pointed at
  `https://github.com/andreyorst/dotfiles.git`, which now asks for
  credentials, so the clone had not advanced since 2021-10-22. It was
  repointed to `https://gitlab.com/andreyorst/dotfiles.git` and pulled
  (661 commits). Its Emacs config is `.config/emacs/init.el`; since
  2026-04-26 the notable change is a move back to eglot (`279f6a10`). No mise,
  envrc, or AI packages (`git grep` over `.config/emacs`).
- **danielmai-dotemacs** — no commits since 2023-02-15. Dropped 2026-09-26.
- **jkitchin-scimax** — discontinued upstream. Dropped 2026-09-26.
- These clones in `reference-emacs-configs/` are not in the inventory, so the
  tooling does not track them: `ebzzry-dotfiles`, `editorconfig-emacs`,
  `greendog-gtd`, `howardabrams-dot-files`, `sirpscl-emacs.d`, `smartparens`.
  They were left as they are.

## SQL and PostgreSQL decisions (spec 015)

Research for spec 015 step 1 (literate-emacs.d #40), 2026-09-26. Sources are
Emacs 31.1's bundled `sql.el`, `ob-sql.el` and `ob-eval.el`, the installed
`envrc` package, each tool's own repo and documentation, and the reference
repos above. "Verified" means the command was run or the source line was
read; anything else is marked.

### Editing mode: classic `sql-mode`

Keep the built-in `sql-mode` with `sql-product` set to `postgres` (done in
literate-emacs.d #38). No tree-sitter mode.

- Emacs 31.1 ships no `sql-ts-mode`, and Emacs master has none either
  (verified: `(locate-library "sql-ts-mode")` is nil).
- The third-party `sql-ts-mode` repos are small, unmaintained, and not on
  MELPA. The grammar, DerekStride/tree-sitter-sql, describes itself as
  permissive rather than PostgreSQL-exact, and its generated parser lives on
  the `gh-pages` branch.
- `sql-mode` derives from `prog-mode` (`sql.el:4151`), so the existing flymake,
  eglot and envrc hooks already apply.
- `sql-indent` (GNU ELPA) is already turned on by `sql.el` when installed
  (`sql-use-indent-support`). Add it only if indentation proves a problem.

### Language server: `postgres-language-server`

Use `postgres-language-server` from Homebrew (0.25.7, maintained), through
eglot with `(sql-mode . ("postgres-language-server" "lsp-proxy"))`. Emacs 31.1
has no default entry for any SQL server (verified).

- It is the only candidate that gives both syntax errors while typing (it
  parses with libpg_query, PostgreSQL's own parser) and completion of tables
  and columns from the live database.
- `sqls` was rejected: it has no syntax diagnostics, uses its own parser, has
  no Homebrew formula, and calls itself unstable.
- **Credentials: set a password-less `DATABASE_URL` in the project.** Given
  separate `PG*` variables, the server uses the password `"postgres"` unless
  `PGPASSWORD` is set, and never reads `.pgpass`. Given a connection URL with
  no password, it reads the password from `PGPASSFILE`. So the project's
  `mise.toml` gains a `DATABASE_URL` naming the user, host and database, and
  the password stays in `.pgpass`. Found by reading the server's source; spec
  015 step 6 proves it.
- Costs:
  - Every project shares one server process, which reads the environment of
    whichever project started it. Harmless while `artofpg` is the only
    database.
  - Type checking covers only SELECT, INSERT, UPDATE, DELETE and CTEs.
  - A blank line inside a statement is treated as the end of the statement.
  - Its formatter is marked "Preview"; not used (see below).
- Which login the server uses (`artofpg_ddl` or `artofpg_rw`) is left to
  spec 015 step 6.

### Formatter: `pg_format` through `reformatter`

Use `pg_format` (Homebrew `pgformatter`, 5.11, maintained) with a local
`reformatter-define`, the way the config already formats Go and Python.

- `sqlfluff` was rejected: it is a linter first, slower, needs a dialect
  file, and fails on anything it cannot parse. yqrashawn uses it
  (`.doom.d/lang.el:133-136`).
- Purcell's `sqlformat` package is only a `reformatter-define` around the same
  command, so it adds a dependency for nothing.
- The language server's formatter is in preview; revisit when it is not.

### Project settings: `mise.el`

Use `mise.el` (MELPA package `mise`, https://github.com/eki3z/mise.el). No
reference repo configures mise, and mise's own documentation lists `mise.el`
as the Emacs integration (`docs/ide-integration.md`). It works the way
`envrc` does: per buffer it runs `mise env --json` and sets a buffer-local
`process-environment` and `exec-path`, and it wraps `org-babel-eval` so
org source blocks inherit them (`mise.el:83`).

Verified with mise 2026.9.14: `mise env --json` in the art-of-postgresql repo
gives `PATH` starting with `/opt/homebrew/opt/libpq/bin` and an absolute
`PGPASSFILE`; in `$HOME` it gives no `PG*` variables; on an untrusted
`mise.toml` it refuses.

It needs these settings before it is safe here (all read in `mise.el` at
849c44b):

- **`mise-trust nil`.** The default asks once, then runs `mise trust --all`,
  which trusts every config in the directory and its parents.
- **The `experimental` setting.** When mise's `experimental` setting is not
  true, the package runs `mise settings set experimental true`, which writes
  to the global mise config. On this machine the setting is false and the
  global config is `jwm-dotfiles-2024/home/.config/mise/config.toml`, so the
  package would edit a dotfiles file without review. Set it in the dotfiles
  repo deliberately before enabling the package.
- **Running alongside `envrc`.** Each package clears the other's buffer-local
  environment. Turn on `global-mise-mode` before `envrc-global-mode`, and
  exclude buffers where envrc is active (the workaround in mise.el issue
  #22). Inferred from source, not tested.
- **Speed.** It runs several blocking `mise` processes for each new buffer
  (issues #23, #24). Measure the effect when opening files in spec 015 step 3.

The package is quiet (last commit 2025-12-29), but it is small and the
behavior above was read from its source.

Rejected:

- `.envrc` with `use mise`, under the existing `envrc`: mise marks it
  deprecated and unsupported (`docs/direnv.md`), and it needs a second file
  and a second approval (`direnv allow`) in each project.
- `.dir-locals.el`, as munen does for PostgreSQL login settings
  (`custom-settings.el:254-265`): repeats every setting, needs `eval`, and
  does not reach temporary or SQL session buffers.
- mise shims on the global PATH: `[env]` variables are set only when a shim
  runs, and `psql` is not a mise tool.

### Practices to adopt

`sql.el`:

- **`sql-postgres-login-params` set to nil.** The default prompts for user
  and database with `jeff` as the default, and passing those overrides
  `PGDATABASE` (`sql.el:1204-1213, 5398-5416`, verified). With nil, psql
  takes everything from the `PG*` variables and `.pgpass`.
- **`--no-psqlrc` added to `sql-postgres-options`**, so a custom prompt in
  `~/.psqlrc` cannot break the session's prompt matching. From Purcell,
  `lisp/init-sql.el:5-7`.
- **`C-c C-z` to jump to the SQL session buffer.** Purcell,
  `lisp/init-sql.el:9-21`.
- **Persistent session history** through `sql-input-ring-file-name`. Purcell,
  `lisp/init-sql.el:31-32`.
- **Full highlighting in the session buffer.** Purcell,
  `lisp/init-sql.el:35-38`.
- **EXPLAIN as JSON** (optional). Purcell, `lisp/init-sql.el:47-102`, changed
  so that empty `sql-database`, `sql-server` and `sql-user` do not override
  the `PG*` variables (lines 73-77 set them unconditionally).
- The SQL session buffer should get the project environment from its own
  directory, since `global-mise-mode` turns on in it before `psql` starts
  (`sql.el:4724-4739`, `comint.el:829-832`; read, not run). Spec 015 step 4
  proves this; if it fails, wrap `sql-comint` with `inheritenv-add-advice`.

`ob-sql`:

- **Default header arguments `:engine postgres` and `:cmdline -X`.** Without
  `-X`, `psql` reads `~/.psqlrc`, whose output would corrupt the result table
  (`ob-sql.el:289-305`, verified). The engine default follows abo-abo's
  template (`modes/ora-org.el:394`), except for the name: `ob-sql` runs
  blocks under `postgres` or `postgresql`, but `C-c '` hands the engine to
  `sql-set-product` (`ob-sql.el:111-116`), which knows only `postgres`.
  `postgresql` broke `C-c '` until literate-emacs.d #53.
- **No connection header arguments.** With none of `:dbhost`, `:dbport`,
  `:dbuser` or `:database`, `psql` gets no connection flags and uses the `PG*`
  variables (`ob-sql.el:130-140`). Never use `:dbpassword`: it puts the
  password on the command line (`ob-sql.el:293-296`).
- Any output on stderr, including PostgreSQL notices, opens the babel error
  buffer even when the query succeeds (`ob-eval.el:74-78`). Expect this in
  spec 015 step 5.

Skipped: `ejc-sql` (a JVM client with its own connection settings, from
yqrashawn), `flymake-sqlfluff` and `sqlup-mode` (minemacs; the language
server covers diagnostics), `pgmacs` (jwiegley; not needed yet), and
jwiegley's `org-mssql` connection pattern (Microsoft SQL Server only, and it
puts the password on the command line).

## Async agent work (spec 017)

Findings from the research tickets on map #31 (#32-#35), read 2026-11-08.
The full write-ups sit on unmerged `research/*` branches, linked from each
ticket. The decision is the Outcome of `specs/017-emacs-async-agent-work.md`.

- **No config or AI package uses Lisp threads.** Parallel work is always an
  outside process (curl, an agent CLI, a language or agent server) that Emacs
  follows through process filters, sentinels and timers. Threads share one
  lock and switch only while waiting; `call-process` inside a thread still
  freezes the editor.
- **Packages split by what Emacs sees.** Some parse the agent's protocol and own
  cancellation and per-request state: gptel (one curl per request),
  agent-shell over acp.el, eca, mcp.el. Others host a terminal interface and
  see only screen text: claude-code-ide (plus a WebSocket channel for editor
  tools such as ediff), aidermacs.
- **Streaming never blocks; the freezes are at the edges:** synchronous
  tools, startup waits, synchronous management calls, `y-or-n-p` prompts.
  munen's gptel tools are all synchronous. `gptel-abort` stops only the first
  request in a buffer.
- **jwiegley moved agent runtimes out of Emacs.** He keeps gptel (default
  backend: a remote Hermes Agent), claude-code-ide and aider, and runs heavy
  work in agent-deck on another host, launched from Org blocks with output
  pulled into Org on demand. He removed agent-shell, gptel-agent, macher and
  pi-coding-agent.
- **yqrashawn is the only one with hand-written async code for agents:** a
  gptel backend that runs the `claude` CLI with its own filter, sentinel and
  timeout, registered so `gptel-abort` works; `file-notify` watchers on
  sub-agent transcripts; one tool definition registered for both gptel and
  Claude Code over MCP.
- **Patterns worth copying:** a callback that runs only once plus a timeout
  timer around every async call; capturing the workspace and directory when a
  request starts; logging why requests die (yqrashawn's advice on gptel's
  sentinel and abort); fanning out and consuming results in order (Sacha's
  whisper queue).

## Current Landscape-Level Signals

These are the cross-repo conclusions that currently matter most to
Jeff's roadmap:

- Purcell remains the cleanest migration reference for language tooling and
  built-in-era Emacs defaults. Re-read him before Terraform, eat, undo, or
  any broad language-mode work.
- AI references now have a useful spread: jwiegley remains the ambitious
  ceiling; munen and yqrashawn cover custom tools / MCP; redguardtoo covers
  a compact gptel + macher setup; Sacha covers practical Org/language-learning use;
  MinEmacs and MatthewZMD show package-stack and agent choices.
- bbatsov is best for small, pragmatic quality-of-life upgrades and modern
  defaults that can land as tight cleanup commits.
- Sacha is useful when the question touches Org, publishing, blogging,
  transcription, or "what has filtered into long-running daily use?" She is
  now also a practical gptel / agent-shell reference rather than only an
  Org/blogging reference.

## Secondary AI Sources

These are not tracked as personal-config ground truth, but they should be
consulted during AI work:

- `karthink/gptel` and https://gptel.org/ — package-level truth for backend
  support, tool use, MCP integration, multimodal context, and transient UI.
- `xenodium/agent-shell` — package-level truth for ACP agent shells, supported
  agents, environment handling, MCP server config, and container path
  resolution.
- `MatthewZMD/aidermacs` and `tninja/aider.el` — package-level truth for
  Aider-style pair programming from Emacs.
- John Kitchin's RAG packages (`jkitchin/emacs-rag-libsql`,
  `jkitchin/org-db-v3`) — secondary package context when an AI sub-goal
  reaches retrieval or Org/DB-backed context. Kitchin has stopped using
  Emacs, so check upstream activity first.
- Mastering Emacs / Mickey Petersen — useful as blog and package context
  (e.g. Combobulate, ligatures, shell/editor workflow), but no current public
  personal Emacs config was found during this pass.

## Per-repo notes

### steve-purcell-dotemacs

Steve Purcell's `emacs.d`. Most actively maintained reference in the set;
small commits, cleanly incremental migrations.

Latest commit at the 2026-04-26 sync: `5be20de8 2026-04-22 Add basic golang support`.

**2026-09-26 refresh** (`5be20de8..80e1470d`, 20 commits; latest
`80e1470d 2026-08-29 Correction in README`): eglot semantic tokens disabled
(`fa3dcf6`, `lisp/init-eglot.el`); Emacs 31 prep (`elisp-fontify-semantically`,
corfu-terminal only below 31); minimum Emacs 28.1; expreg added on `C-=`/`C--`;
`consult-xref` for xrefs; `session` dropped for `desktop-save-mode`. No SQL,
environment or AI changes. `lisp/init-sql.el` (unchanged since 2023) is the
lead reference for spec 015.

**What we've extracted so far:**

- `lisp/init-minibuffer.el` → completion-stack sub-goal (vertico + consult +
  embark + orderless + savehist + remap-style bindings).
- `lisp/init-python.el`, `lisp/init-flymake.el` → python-LSP-treesit
  sub-goal (eglot + ty + ruff + reformatter pattern; `flymake-ruff` hook).
- `lisp/init-go.el`, `lisp/init-javascript.el`, `lisp/init-docker.el` →
  lsp-coverage sub-goal (go-ts-mode + goimports reformatter; js-mode
  base + js2-mode minor; minimal dockerfile-mode).
- `lisp/init-treesitter.el` → reviewed but not adopted; his
  `auto-configure-treesitter` is more sophisticated than our explicit
  `treesit-ready-p` checks. Worth a second look if our remap list grows
  past ~10 languages.
- `lisp/init-git.el` → drop-hydra investigation; observed
  `magit-diff-visit-prefer-worktree` setting (not adopted yet).
- Drop-dash-s-f and drop-hydra investigations: confirmed zero usage.

**Likely future relevance:**

- Terraform LSP (he uses `tofu-ls`).
- Eat terminal investigation (he adopted eat).
- Modern undo investigation (his choice if he has one).

**Notable recent activity (as of 2026-04-25 sync):**

- 2026-04-22 — `Add basic golang support`: independent confirmation
  that `go-ts-mode` + `eglot` + `gopls` is the 2026 default (matches
  our lsp-coverage sub-goal).
- `Define a reformatter for terraform` + `Add tofu-ls as an eglot LSP
  for terraform` — directly applicable to the pending Terraform LSP
  sub-goal. Re-read his terraform setup before drafting that proposal.
- `Remove now-upstreamed addition of ty to eglot-server-programs` —
  `ty` is now bundled into upstream eglot's default
  `eglot-server-programs`. Our explicit `("ty" "server")` entry can
  be dropped when our Emacs ships that change (track as a small
  follow-up).
- `Define a handy ruff-fix-on-save-mode` — runs `ruff check --fix-only`
  on save (separate from `ruff format`). Candidate follow-on to our
  ruff-format integration.
- `Enable pulsar, but conservatively` — visual cursor-jump feedback;
  candidate QoL enhancement, not in our backlog yet.
- Eglot tweaks: keep same LSP across out-of-project xref jumps; don't
  display emoji in margin; non-emoji modeline character.

### jwiegley-dotemacs

John Wiegley's `dot-emacs`. The most sophisticated reference — uses
literate-style org for everything, deep customization, *very* AI-heavy
in 2025-2026.

Latest commit at the 2026-04-26 sync: `1d50d3e3f 2026-04-22 changes`.

**2026-09-26 refresh** (`1d50d3e3f..9a512ede6`, 177 commits; latest
`9a512ede6 2026-09-25 Remove documentation files`): submodules replaced by a
Nix package bundle (`d00e29a88`); opt-in XDG state migration; agent-shell /
ACP / gptel-agent / macher / ragmacs dropped (`aeb337efd`); LiteLLM routing
and Anvil MCP dropped; gptel backends generated per function from one registry
(`lisp/gptel-backends.el`, default Hermes Agent on Vulcan), OAuth backends
removed; `org-agent-deck` / `ob-agent-deck` added; claude-code-ide still
configured; `org-today-agenda.el` reads SQL results from a Claude skill;
`edbi` removed; exec-path-from-shell now copies a named variable list. No
mise, no eglot/tree-sitter change beyond path moves.

**What we've extracted so far:**

- Phase 0 landscape: identified as the AI/LLM ceiling reference.
- drop-hydra investigation: noted he is one of the few who *still* uses
  hydra (lone holdout among references).

**Likely future relevance:**

- AI / LLM integration sub-goal (canonical reference): `gptel-presets.el`,
  `hf.el` (local llama-swap orchestration), `lisp/gptel-*` modules,
  `mcp-server-lib`, `agent-shell`.
- Lots of unused-so-far material; expect to mine heavily when we get
  to AI work.

**Notable recent activity (as of 2026-04-25 sync):**

- Most active files in the last 30 commits: `lisp/gptel-presets.el`
  (13 commits) and `lisp/hf.el` (10) — ongoing model-preset and
  local-LLM tuning. Confirms his AI focus is steady.
- `gptel: Update presets, fix LiteLLM header, enable org-roam sync` —
  he routes all LLM traffic through LiteLLM and is now enabling
  org-roam sync from gptel. Both mechanisms worth understanding before
  AI sub-goal.
- `init.org: Add relint, enable magit ANSI coloring, unblock org-roam
  sync` — beyond AI, he's still tuning core dev workflow.
- Move of `hf.el` into its own submodule — code organization step;
  suggests `hf.el` is mature enough to be reused independently.

### bbatsov-dotemacs

Bozhidar Batsov's `emacs.d`. Pragmatic, modern-leaning, opinionated
choices.

Latest commit at the 2026-04-26 sync: `d6cbae1 2026-04-06 Update tokyo-night setup
to reflect upstream changes`.

**2026-09-26 refresh** (`d6cbae1..01286d8`, 62 commits; latest
`01286d8 2026-07-29 Enable Flycheck inline diagnostics and the built-in eglot
bridge`): new `early-init.el`; tree-sitter grammar recipes and guarded
`major-mode-remap-alist` (`init.el:1160-1205`); eglot for every language he
uses via ts-modes (`init.el:1242-1380`), `eglot-events-buffer-config
'(:size 0)`, Flycheck 38 eglot bridge; completion additions (embark, cape,
corfu-history, `completion-preview-mode`); swaps undo-tree→vundo,
flyspell→jinx, vterm→mistty. No SQL, environment or AI changes.

**What we've extracted so far:**

- Completion-stack sub-goal: cross-referenced his vertico / orderless /
  marginalia / consult setup.
- emacs-30 cleanups: cross-referenced his patterns (built-in which-key,
  use-package bootstrap drop).
- drop-dash-s-f and drop-hydra investigations: confirmed.

**Likely future relevance:**

- Small cleanup pass: `expand-region` → `expreg` (his choice),
  `repeat-mode` patterns, possible copilot patterns.
- Theme exploration: he uses tokyo-night / catppuccin.

**Notable recent activity (as of 2026-04-25 sync):**

A burst of small QoL upgrades worth scanning when designing any "minor
enhancements" sub-goal:

- `minibuffer-regexp-mode` — live regexp feedback in the minibuffer.
- `visual-wrap-prefix-mode` — indentation-aware soft-wrap.
- `read-extended-command-predicate` — filter irrelevant `M-x` candidates.
- `eglot-autoshutdown` — already in our config; corroboration.
- Dired drag-and-drop to other apps.
- `file-notification`-based auto-revert (replaces polling).
- Show matching paren context when offscreen.
- Silenced native-comp async warnings.
- `repeat-mode` with a custom repeat-map for expreg — directly relevant
  to the expand-region → expreg item in our Small cleanup pass.
- `Highlight current error in compilation/grep buffers`.
- Theme: tokyo-night (latest update 2026-04-06).

### sacha-chua-dotemacs

Sacha Chua's `.emacs.d`. Organic, blog/journaling-heavy, less of a clean
migration source, but now a concrete practical AI-workflow reference.

Latest commit at the 2026-04-26 sync: `44d6958 2026-04-18 PDF` (on `gh-pages`
branch — her config is published as her blog).

**2026-09-26 refresh** (`44d6958..57c7f7b`, 22 commits, all
2026-05-28 → 2026-05-31; latest `57c7f7b 2026-05-31 additional files`):
tips borrowed from oantolin (Embark bindings, search/goto maps, `:vc`
extras), popper, diff-hl in dired, link-hint, emacs-everywhere; publishing
and streaming churn. gptel and agent-shell setup unchanged; SQLite only.

**What we've extracted so far:**

- Phase 0 landscape: organic-evolution profile.
- drop-dash-s-f: confirmed.
- drop-hydra: confirmed.
- 2026-04-26 AI reference expansion: `Sacha.org` now has `gptel`
  backends for Groq, Gemini, paid Gemini, and Mistral; a custom
  `sacha-gptel-set-model`; `agent-shell` defaults for Claude Code; and
  task-specific `gptel-request` workflows for language learning.

**Likely future relevance:**

- Practical AI workflows inside Org, especially small task-specific
  `gptel-request` helpers and "what actually stuck in daily use?"
  patterns.
- Still lower than jwiegley / yqrashawn for agentic coding architecture;
  her config is shaped around blogging, transcript, publishing, and
  learning workflows that only partially map onto Jeff's daily use.
- Useful for org-modern adoption notes (she has commits about it).
- Useful for `goto-chg` / `substitute` / `minibuffer-regexp-mode`
  evaluations.

**Notable recent activity (as of 2026-04-25 sync):**

- `more stuff from prot and bbatsov` (explicit cross-pollination
  signal — confirms Sacha tracks Prot and bbatsov's configs; we track
  both as of 2026-09-26). She's a good "what's filtering down to working users?" indicator.
- Whisperx (small model) for live transcription — relevant if we ever
  explore audio-input sub-goals.
- `gptel` backend matrix includes Groq, Gemini, paid Gemini, and Mistral
  with API keys read from environment variables.
- `agent-shell` is present with Claude Code as the preferred agent and a
  custom per-working-directory dot-subdir function.
- Streaming-related commits (her live coding sessions).
- yas-minor-mode-map TAB conflict resolution — small note for if/when
  we hit similar yasnippet/mode interactions.

### munen-emacs.d

Munen's `emacs.d`. Different AI flavor than jwiegley — heavy on custom
gptel tools (filesystem read/write/edit, lint integration), uses MCP and
agent-shell. His mcp.el servers are not started automatically: auto-start is
deliberately left off (`configuration.org:4012-4031`).

Latest commit at the 2026-04-26 sync: `010121d 2026-04-15 feat: Add
edge-tts-speak-region`.

**2026-09-26 refresh** (`010121d..c7be64d`, 9 commits; latest
`c7be64d 2026-08-19 chore: Switch active things.org file`): gptel
`ddgs_search` tool replaces `search_web` (`cdbc9a6`); gptel `read_url` tool via
`url-retrieve` + `shr`, with guidance on which fetch tool to use (`2d2cc30`);
ghostel terminal (`af977f1`); UTF-8 defaults for the daemon. Existing
dir-local `sql-postgres-login-params` (`custom-settings.el:254,262`) is a
per-project Postgres pattern.

**What we've extracted so far:**

- Phase 0 landscape: alt-pattern reference for AI integration.

**Likely future relevance:**

- AI / LLM integration sub-goal: complementary to jwiegley. munen's
  pattern (gptel + custom tools + MCP) is more compact; jwiegley's is
  more elaborate. Worth seeing both before designing.

**Notable recent activity (as of 2026-04-25 sync):**

- `agent-shell uses opencode by default` — opencode is an AI agent
  backend (CLI/protocol). Relevant alternative architecture for AI
  sub-goal.
- `Remove old-school js dev stuff and add agent-shell` — clear signal
  of AI-first refactor.
- `Add vterm package` — he previously didn't use a terminal; now does.
  Useful data point for the eat-vs-vterm investigation.
- `Add edge-tts-speak-region` — text-to-speech via Microsoft Edge TTS.
  Niche but interesting if we ever explore voice output.
- Many ongoing prompt iteration commits for agent-shell and gptel
  tools — suggests his prompt engineering is still active.
- `Prefer packages via Guix, again` — uses Guix (Linux) for package
  management. Less directly relevant for Jeff's macOS setup but
  illuminates his deployment style.

### redguardtoo-emacs.d

Chen Bin's `emacs.d`. Very popular, active, and useful as the compact
local-first AI counterpoint to jwiegley's large stack.

Latest commit at the 2026-04-26 sync: `8c892ed7 2026-04-19 use apeleia to format code`.

**2026-09-26 refresh** (`8c892ed7..d6f7674a`, 63 commits; latest
`d6f7674a 2026-09-24 python snippet`): **the Ollama backends and aider noted
below are gone** — hard-coded backends removed (`5f9aa2e6`), aider.el removed
(`6e7353e4`); gptel now plain `use-package` with no pinned model; `macher`
added (`lisp/init-ai.el:32-44`, Emacs 30+); `agent-shell` + `acp` installed but
not configured. ivy/counsel replaced by vertico/orderless/consult/embark;
apheleia formats shell with shfmt; minimum Emacs 29. No SQL or environment
changes.

**What we've extracted so far:**

- 2026-04-26 AI reference expansion: `lisp/init-ai.el` configures `gptel`
  with local Ollama backends for DeepSeek R1 and Gemma 3n, org-mode chat
  buffers, presets, prompt directives, and `gptel-include-reasoning nil`.
- Same module wires Aider to local Ollama models and adds small project /
  commit analysis helpers around `gptel-request`.

**Likely future relevance:**

- Best small reference for "local model first, minimum Emacs surface" and
  for deciding which parts of AI integration can stay lightweight.
- Re-read before local Ollama, local Aider, or one-off code-review helper
  sub-goals.

### abougouffa-minemacs

Abdelhak Bougouffa's MinEmacs framework. More of an Emacs distribution
than a single personal init, but active and broad enough to be useful for
package-stack comparisons.

Latest commit at the 2026-04-26 sync: `ae4967d6 2026-04-26 chore(version): v14.0.0`.

**2026-09-26 refresh** (`ae4967d6..43dfa211`, 301 commits, v14.1.0 →
v14.14.0; latest `43dfa211 2026-09-26 tweak: bump packages versions`):
claude-code-ide added (`modules/me-ai.el:103-147`); per-project eglot clangd
contact from safe dir-local variables (`core/extras/me-eglot-x.el:246-272`);
more tree-sitter grammars and ts-modes; ghostel is the default terminal;
yasnippet replaced by tempel; `once`/`satch` libraries removed. No SQL
configuration; envrc module obsolete since 2025-10.

**What we've extracted so far:**

- 2026-04-26 AI reference expansion: `modules/me-ai.el` combines `llm`,
  `llm-ollama`, `llm-models`, Ellama, gptel, Aidermacs, `mcp-hub`, and
  Whisper in one module.
- Shows local-backend choices for Ollama and llama.cpp, dynamic Aidermacs
  model selection from available Ollama models, and an MCP-to-Ellama-tools
  bridge.

**Likely future relevance:**

- Useful when comparing gptel-first versus Ellama/`llm` abstractions.
- Re-read for MCP server registration and "many AI packages in one module"
  tradeoffs.

### matthewzmd-emacs.d

Matthew Zeng's M-EMACS configuration. Useful mainly because Matthew is the
Aidermacs author; the personal AI surface is smaller than the package repo.

Latest commit at the 2026-04-26 sync: `e8a999b 2026-03-14 Update stuff`.

**What we've extracted so far:**

- 2026-04-26 AI reference expansion: `elisp/init-llm.el` configures
  Aidermacs with `comint`, disables auto-commits, uses OpenRouter Gemini
  as the default model, and sets a DeepSeek weak model.
- Same file enables Emigo against OpenRouter, using `OPENROUTER_API_KEY`
  from the environment.

**Likely future relevance:**

- Re-read when evaluating Aidermacs defaults, model split between primary
  and weak model, and whether to use `comint` or terminal-backed agent UI.
- Treat `MatthewZMD/aidermacs` itself as the package-level source of truth.

### yqrashawn-yqdotfiles

yqrashawn's dotfiles. Advanced Doom-based AI reference with substantial
custom gptel tooling, MCP server work, proxy backends, and tests.

Latest commit at the 2026-04-26 sync: `900106d4 2026-04-25 fix: auq`.

**2026-09-26 refresh** (`900106d4..db35cd8f`, 56 commits; latest
`db35cd8f 2026-09-22 fix(pr-review)…`): Claude Code `pr-review-loop` plugin
(babashka, `claude-code-plugins/`); gptel Claude Code presets rebuilt
with long-lived per-subtree sessions (`.doom.d/llm.el`), now split between an
HTTP proxy and a separate CLI-subprocess backend
(`modules/llm/gptel-claude-code/`); gptel abort logging;
`ai-code` and `eca` added; copilot and aidermacs dropped; new mcp-hub servers.
Predating the range, and the closest ready-made SQL setup across the
references: `ejc-sql` (`.doom.d/prog.el:213-248`), `sqlfluff --dialect
postgres` formatter (`.doom.d/lang.el:133-136`), `sqls` via nix.

**What we've extracted so far:**

- 2026-04-26 AI reference expansion: `.doom.d/llm.el` builds a large gptel
  preset matrix for Claude Code, OpenRouter, GitHub Copilot, and Codex-like
  local proxy backends.
- `.doom.d/gptel-tools/` contains tested tools for file creation/editing,
  reading, buffers, ripgrep, shell, linting, memory, imenu, treesit, todo,
  and workspace context.
- `.doom.d/packages.el` includes gptel, Elysium, chatgpt-shell, Whisper,
  Copilot, Aidermacs, MCP, `mcp-server-lib`, `elisp-dev-mcp`,
  `agent-shell`, `agent-shell-sidebar`, and `agent-shell-manager`.

**Likely future relevance:**

- New HIGH-tier AI reference for agentic gptel architecture, custom tool
  design, MCP/server integration, and local proxy adapters for external
  coding agents.
- Re-read alongside jwiegley before designing any serious tool-use or
  agent-shell sub-goal; use redguardtoo if the desired answer is smaller.

### oantolin-emacs-config

Omar Antolín Camarena's personal config, added 2026-09-26 during spec 016
after Sacha's refresh showed her borrowing from it. He is the author of
Embark and Orderless. The README states his approach: learn the built-in
package first, write a tiny package for a small itch, and go shopping for
external packages only for big ones. One `init.el` using `use-package`, plus
small packages of his own in `user-lisp/`, which others (Sacha) load with
`:vc`.

Latest commit at the 2026-09-26 sync: `f11d436 2026-09-18 Binding for
jinx-occur`. History from 2020-04; active through 2026.

**What we've extracted so far:**

- Nothing yet.

**Likely future relevance:**

- The authoritative reference for Embark, Orderless and Vertico setup
  (`init.el:402-516`: completion styles, orderless dispatchers,
  vertico-multiform, embark bindings).
- gptel on Groq with `openai/gpt-oss-120b` as the default
  (`init.el:310-345`), plus `user-lisp/gptel-extras.el` (`-mini`, `-define`)
  — a direct comparison for spec 012's setup.
- `user-lisp/` extras (isearch, narrow, window, comint, eshell) as small
  built-in-first patterns.
- Not a source for SQL, mise/direnv or eglot: `git grep -i -w` over its
  `.el` files finds no `sql`, `postgres`, `mise`, `envrc`, `direnv`,
  `exec-path` or `eglot`.

### protesilaos-dotfiles

Protesilaos Stavrou's (Prot's) dotfiles, managed with GNU Stow; the Emacs
config is under `emacs/.emacs.d/`. Added 2026-09-26 during spec 016 after
Sacha's notes showed her tracking it. Prot writes `modus-themes`,
`ef-themes`, `denote` and many other packages.

Latest commit at the 2026-09-26 sync: `cd4608b1 2026-09-23 emacs: make
prot-icons-tab-bar-name reuse tab-bar-current face for consistency`. History
from 2019-02; 245 commits under `emacs/` since 2026-01-01.

The config is literate, like Jeff's: `prot-emacs.org` is the prose source,
tangled into `init.el`, `early-init.el`, topic modules in
`prot-emacs-modules/` (completion, dired, git, langs, org, search, window, …)
and small libraries in `prot-lisp/`. The org file warns readers not to
copy-paste without understanding.

**What we've extracted so far:**

- Nothing yet.

**Likely future relevance:**

- A second literate config to compare against Jeff's own structure: how prose,
  modules and a personal library split across files.
- Built-in-first setups for completion (vertico, orderless, embark,
  marginalia via `prot-lisp/`), Dired, Org, windows and search.
- eglot basics in `prot-emacs-modules/prot-emacs-langs.el:80-83`
  (`eglot-sync-connect nil`, `eglot-autoshutdown t`).
- Not a source for SQL, mise/direnv or AI: `grep -r -i -w` over its `.el`
  files finds no `sql`, `postgres`, `mise`, `envrc`, `direnv`, `exec-path`,
  `gptel`, `llm` or `claude`.

## Workflow

### Starting a new investigation that might need ground-truth refs

1. Read this file to identify candidate repos.
2. Confirm those repos are present locally (`reference-emacs-configs/<name>/`).
   `just ref-show-plan` prints clone commands for missing entries.
3. If a repo is potentially stale (last analyzed > N months and we're
   starting a substantial sub-goal in its area), refresh: `just
   ref-show-changes` reports new commits per repo since the
   inventory's last-known SHA. Pull manually if you want to advance
   local state, then `just ref-update-inventory` to record the new SHA.
4. Grep / read with `git -C reference-emacs-configs/<name> ...`.

### Discovering a new repo worth tracking

```sh
cd /Users/jeff/jwm/proj/literate-emacs.d
just ref-add <name> <url>
just ref-show-plan          # prints `git clone …`
# execute the clone
just ref-update-inventory   # records the SHA
# update this file with notes about the new repo
git add justfile reference-configs.md reference-repos.list
git commit -m "ref: track <name>"
```

### Re-analysis heuristic

A tracked repo becomes worth re-analyzing if:

- We're starting an investigation in its specific area of focus
  (e.g. jwiegley before AI/LLM work).
- `just ref-show-changes` reports a non-trivial number of new commits
  since the last analyzed SHA.
- A specific question requires "what does this developer do *now*?"
  (current state) rather than "what did we extract previously?"
  (point-in-time snapshot).

### About the inventory-only repos

Repos that appear in `reference-repos.list` but not in the table above are
tracked for state preservation. `just ref-show-changes` reports their
upstream activity along with the others; if anything notable happens, we can
promote one to active analysis by writing a section here. Until then, no
synthesis update needed.

Current inventory-only notes:

- `andreyorst-dotfiles`: tracked for continuity. GitLab / web search did not
  surface a strong AI/LLM config signal during the 2026-04-26 AI reference
  expansion, so it remains inventory-only.

### Dropped repos

Removed from the inventory; their notes live in git history.

- `danielmai-dotemacs` (2026-09-26): no commits since 2023-02-15. It shaped
  Jeff's original config, which still credits it.
- `jkitchin-scimax` (2026-09-26): Kitchin discontinued scimax development on
  2026-04-23 and no longer uses Emacs.
- `abo-abo-dotemacs` (2026-11-12): no commits since 2025-12-17.
- `manateelazycat-lazycat-emacs` (2026-11-12): no commits since 2026-02-23,
  and its local clone had every file staged for deletion.

## Updating this file

Whenever a sub-goal pulls a new pattern from a tracked repo, append a
line to that repo's "What we've extracted" list. Whenever a new repo
gets `ref-add`'d, add a section here.
