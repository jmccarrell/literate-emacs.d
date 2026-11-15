# 015 — PostgreSQL development in Emacs

The emacs-config project has been an evolution to bring Emacs back to being my primary
code editing tool. SQL has never been directly supported in my configuration: the
only trace is `sql` and `sqlite` in the org-babel language list, with no
confirmation before a SQL block runs. There is no setup for editing `.sql` files,
for connecting to a database, or for PostgreSQL in particular. I want that now,
because the projects I am starting will have me writing detailed PostgreSQL.

## Outcome

Done; each item names the `jmccarrell/literate-emacs.d` issue that delivered it.

- [x] Open a `.sql` file and get PostgreSQL-aware highlighting and indentation. (#38)
- [x] Send a statement, a region, or the whole buffer to a running PostgreSQL
      session and see the results in Emacs. (#43)
- [x] Get completion of table and column names from the connected database. (#51)
- [x] See syntax errors as I type, before running anything. (#51)
- [x] Format a query with one command. (#52)
- [x] Write and run PostgreSQL in org documents, with results shown in the document. (#46)

## Workflows to support

<!-- Concrete tasks, most frequent first. Each one becomes a test of the finished setup. -->
| Workflow | Example | Priority |
|----------|---------|----------|
| Edit `.sql` files | highlighting, indentation, formatting | must |
| Run a statement or region against a database | | |
| Browse the schema (tables, columns) | | |
| Completion and diagnostics (language server) | | |
| Interactive `psql` session | | |
| SQL blocks in org (org-babel) | art-of-postgresql notes | must |
| Migration files (sqlx, etc.) | | |

## Databases I connect to

<!-- Which servers, how they are reached, and where their credentials come from. -->
| Target | How it is reached | Credentials source |
|--------|-------------------|--------------------|
| `artofpg` on folio (logins `artofpg_ddl`, `artofpg_rw`) | from lyra only; `PGHOST`/`PGDATABASE`/`PGSSLMODE` set by the art-of-postgresql repo's `mise.toml` | that checkout's gitignored `.pgpass`, written by `just write-pgpass`, found through `PGPASSFILE` |

## Constraints

- Machines: editing `.sql` files works everywhere. Connecting to a database is
  set up only where `jwm/personal-mac-p` is true, since `artofpg` is reachable
  only from lyra. On the work machine the config still loads cleanly.
- Credentials: never in the Emacs config. Emacs uses the `.pgpass` that the
  project already writes, so there is one place the password lives.
- Connection settings come from the project, not from the Emacs config.
  Emacs does not hard-code a host or a database name.
- External tools come from Homebrew (`libpq` for `psql` is already installed).
  A language server or formatter is installed the same way, if chosen.
- Prefer what ships with Emacs 31 (`sql.el`, `ob-sql`) and add a third-party
  package only where it does something the built-in cannot.

## Out of scope

- Databases other than `artofpg`. This effort builds one complete path, from
  the editor to that database. Other databases are planned for later, once this
  path works well, but are not part of this spec.

## Open questions

Answered by step 1 (literate-emacs.d #40). The reasoning and sources are in
`reference-configs.md`, section "SQL and PostgreSQL decisions (spec 015)".

- Language server: `postgres-language-server`, through eglot. The project
  needs a `DATABASE_URL` without a password, so the server reads `.pgpass`.
- Formatter: `pg_format`, through `reformatter`.
- Editing mode: classic `sql-mode`; Emacs has no built-in SQL tree-sitter mode.
- Project settings: the `mise.el` package, so Emacs reads `mise.toml` directly.
  Before enabling it: turn off its automatic `mise trust --all`, set mise's
  `experimental` setting in the dotfiles repo (otherwise the package writes it
  there itself), and order it with `envrc`.

## Steps

1. **Research.** Search every repo in `reference-emacs-configs/` deeply for how
   it sets up SQL and PostgreSQL: `sql.el` settings, `ob-sql` use, connection
   and credential handling, language servers, formatters, tree-sitter modes,
   and per-project environment loading. Look specifically for a way for Emacs
   to use mise directly, so that a project's `mise.toml` sets up its buffers
   the way `envrc` does for `.envrc`; I prefer that over adding a second file
   that repeats what `mise.toml` already says. Record what each repo does, with file
   and line references, and which practices to adopt and why. Then answer each
   open question, using the Emacs manuals and vendor documentation where the
   reference configs are silent. The findings go in `reference-configs.md`,
   the workspace's home for this kind of analysis.
   *Check:* every open question has an answer with a source, and every
   adopted practice names the repo it came from.
2. **Editing `.sql` files.** PostgreSQL as the default SQL dialect, with
   highlighting and indentation. Works on every machine.
   *Check:* a `.sql` file from the art-of-postgresql repo opens in the chosen
   mode with the PostgreSQL dialect active, on lyra and on the work machine.
3. **Project settings reach Emacs.** A buffer in the art-of-postgresql repo
   sees that project's `PG*` variables and finds `psql`, using the method
   chosen in step 1 (mise used directly, if step 1 finds a workable way).
   *Check:* in such a buffer, `(getenv "PGHOST")` returns the folio host and
   `(executable-find "psql")` returns the `libpq` binary; in a buffer outside
   the repo, both are unset.
4. **Interactive session.** Start a PostgreSQL session from a `.sql` buffer
   and send a statement, a region, or the whole buffer to it.
   *Check:* `select current_user;` sent from a `.sql` buffer returns the
   login chosen for the session (`artofpg_ddl` or `artofpg_rw`), and no
   password prompt appears.
5. **SQL in org documents.** Org source blocks run against `artofpg` and show
   their results in the document. Revisit the current setting that runs SQL
   blocks without asking for confirmation.
   *Check:* a source block in an org file in the art-of-postgresql repo runs
   a query and inserts the result as an org table.
6. **Completion and diagnostics.** Table and column names complete from the
   connected database, and syntax errors show while typing, using the language
   server chosen in step 1.
   *Check:* completion offers a column of an `artofpg` table; a misspelled
   keyword is marked before the statement runs.
7. **Formatting.** One command formats a query, using the formatter chosen in
   step 1 (`pg_format`). Deferred until after step 6. Install it by adding
   `brew "pgformatter"` to `Brewfile.jwm` in `jwm-bin`, as step 6 does for
   `postgres-language-server`.
   *Check:* formatting a badly indented query gives the expected layout, and
   formatting it a second time changes nothing.
8. **Documentation.** Update the prose in `jeff-emacs-config.org` and
   `emacs-2026-landscape.org`. The cheat sheet is not left to this step: see
   Execution.
   *Check:* the cheat sheet's SQL section covers every step, and the landscape
   document records the SQL setup.

## Execution

**Blocked by a refresh of the reference configs.** Before any step here
starts, every repo in `reference-emacs-configs/` is brought up to date and a
summary of what changed since the last refresh (2026-04-26) is written. That
refresh is separate work, spec 016, not part of this spec. It blocks step 1 because the
research must read current repos: mise is recent enough that older checkouts
may predate any support for it.

Capture the implementation as GitHub issues on `jmccarrell/literate-emacs.d`,
driven by the repo's agent issue workflow (`docs/workflow/agent-workflow.md`):
each issue carries an execution spec in its body and waits at `agent:ready` for my
approval before any code is written.

**Every step documents its own use in the cheat sheet.** How to use what a
step builds (commands, key bindings, one-time setup) goes in the "SQL and
PostgreSQL" section of `emacs-cheat-sheet.org` in the same PR as the step, so
the cheat sheet never lags the config. Each step's issue lists the cheat sheet
under affected paths, and its acceptance criteria include that every new
binding and command appears there. Steps 2-4 were documented after the fact,
in literate-emacs.d #45.

Update the other docs as part of the work: the SQL setup in
`jeff-emacs-config.org` and `emacs-2026-landscape.org`.
