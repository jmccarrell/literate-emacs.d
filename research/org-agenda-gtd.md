# Org agendas for GTD-style project management

**Question.** How do the reference configs use Org agendas to manage
projects, GTD-style: next actions, projects, stuck projects, weekly review,
waiting/someday states, contexts, capture and refile, and agenda commands that
surface priorities?

**Scope.** A local-first snapshot of the active literate config, every clone
under `reference-emacs-configs/`, and the Org 9.8.7 Info manual that ships
with Jeff's Emacs.  It does not change Emacs configuration.  Reference paths
are relative to `reference-emacs-configs/`.

## Short answer

Real GTD agenda setups exist in **steve-purcell-dotemacs**,
**jwiegley-dotemacs**, **sacha-chua-dotemacs**, and **greendog-gtd** (a local
2019 snapshot Jeff saved from the GTD forums; not in `reference-repos.list`).
**protesilaos-dotfiles** has a well-built *priority* dashboard but no GTD
project model.  The rest set `org-todo-keywords` and little else.

The patterns that recur, and that fit Jeff's existing `TODO`/`NEXT`/`WAITING`
states with little change:

1. **One block agenda as the GTD dashboard** (`C-c a g` or similar):
   today's agenda, then Inbox, Stuck projects, Next actions, Waiting, and
   On hold, each an `org-agenda-custom-commands` block with its own header.
   Purcell's is the cleanest reference.
2. **Explicit project marker plus `org-stuck-projects`.**  A project is a
   heading with a `PROJECT` keyword (Purcell, Sacha) or `project` tag (Sacha),
   and `org-stuck-projects` names "a project with no `NEXT` below it".
   Jeff has no project marker and leaves `org-stuck-projects` at its default,
   which assumes level-2 headings and is not tuned for his files.
3. **A "Next actions" block that skips waiting/held subtrees** via
   `org-agenda-skip-function`, so a `NEXT` under a `WAITING` parent does not
   appear actionable.
4. **Priority surfaced in its own block**, not just as a sort key: Prot's
   "Important tasks without a date", Sacha's "Important and unscheduled", and
   jwiegley's super-agenda "Important" group all pull `[#A]` items that
   would otherwise hide in an undated TODO list.
5. **Weekly review as a saved command**: `agenda` with `org-agenda-span 7`
   and `org-agenda-log-mode` on (Sacha), plus review-specific lists
   (jwiegley's `r` prefix).
6. **Capture to a single inbox, refile out**, with an `INBOX` file tag so
   the dashboard can show unprocessed items (Purcell, jwiegley, greendog).

## Jeff's baseline

From `jeff-emacs-config.org` at commit 086df40, before spec 020 changed it:

- **Keys.** `C-c c` capture, `C-c a` agenda, `C-c l` store link
  ([L1437-L1441](https://github.com/jmccarrell/literate-emacs.d/blob/086df406bea98f359f88aad32d304e658e6ffa9d/jeff-emacs-config.org#L1437-L1441)).
- **Files.** `org-directory` is derived from the nearest
  `org-agenda-files-list` registry, falling back to `~/jwm/todo`;
  `org-default-notes-file` is `todo.org`; a separate `tickler.org`
  ([L1463-L1479](https://github.com/jmccarrell/literate-emacs.d/blob/086df406bea98f359f88aad32d304e658e6ffa9d/jeff-emacs-config.org#L1463-L1479)).
  `org-agenda-files` points at the registry file
  ([L1506-L1510](https://github.com/jmccarrell/literate-emacs.d/blob/086df406bea98f359f88aad32d304e658e6ffa9d/jeff-emacs-config.org#L1506-L1510)).
- **Capture.** `t` TODO under `todo.org` / `Tasks`, `T` tickler, `j` journal
  datetree ([L1519-L1526](https://github.com/jmccarrell/literate-emacs.d/blob/086df406bea98f359f88aad32d304e658e6ffa9d/jeff-emacs-config.org#L1519-L1526)).
- **States.** One sequence: `TODO NEXT(n!) DOING(g!) WAITING(w@/!) |
  DONE CANCELLED(c@) DEFERRED(D@)`
  ([L1530-L1538](https://github.com/jmccarrell/literate-emacs.d/blob/086df406bea98f359f88aad32d304e658e6ffa9d/jeff-emacs-config.org#L1530-L1538)).
- **Refile.** Any agenda file to `:maxlevel 2`, matching a `TASKS`/`PROJECTS`
  top-level layout ([L1541-L1546](https://github.com/jmccarrell/literate-emacs.d/blob/086df406bea98f359f88aad32d304e658e6ffa9d/jeff-emacs-config.org#L1541-L1546)).

Not configured: `org-agenda-custom-commands`, `org-stuck-projects`,
`org-tag-alist` / contexts, priority range, `org-agenda-sorting-strategy`,
`org-enforce-todo-dependencies`, `org-log-into-drawer`, habits.  Neither
`org-super-agenda` nor `org-ql` is installed (only a leftover
`~/.emacs.d/elpa/org-super-agenda-readme.txt`).

Two gaps follow from the states.  `DEFERRED` is a *done* state, so a deferred
item drops out of every TODO view, which makes it closer to "cancelled with a
note" than GTD's Someday/Maybe.  And there is no way to tell a project from a
task other than position under a `PROJECTS` heading.

## Reference configurations

### steve-purcell-dotemacs — the canonical small GTD dashboard

`lisp/init-org.el` is explicitly "an opinionated setup for the Getting Things
Done (GTD) system based around the Org Agenda", much of it from Bernt
Hansen's norang guide ([L4-L21](../reference-emacs-configs/steve-purcell-dotemacs/lisp/init-org.el#L4-L21),
[L55](../reference-emacs-configs/steve-purcell-dotemacs/lisp/init-org.el#L55)).

- **Inbox.** `inbox.org` carries `#+FILETAGS: INBOX` and is
  `org-default-notes-file`; capture `t` writes `* NEXT %?` there
  ([L113-L118](../reference-emacs-configs/steve-purcell-dotemacs/lisp/init-org.el#L113-L118)).
  Captured items are next actions by default.
- **States.** Separate sequences: `TODO NEXT | DONE`; `PROJECT | DONE CANCELLED`;
  `WAITING DELEGATED HOLD | CANCELLED`; repeaters reset to `NEXT`
  ([L163-L167](../reference-emacs-configs/steve-purcell-dotemacs/lisp/init-org.el#L163-L167)).
- **Stuck projects.** `'("-INBOX/PROJECT" ("NEXT"))` — any `PROJECT` outside
  the inbox with no `NEXT` beneath it
  ([L180-L181](../reference-emacs-configs/steve-purcell-dotemacs/lisp/init-org.el#L180-L181)).
- **`g` "GTD" block agenda**
  ([L196-L261](../reference-emacs-configs/steve-purcell-dotemacs/lisp/init-org.el#L196-L261)):
  agenda (day span), Inbox (`tags "INBOX"`), Stuck Projects (`stuck`), Next
  Actions (`NEXT`, skipping subtrees under `HOLD`/`WAITING`), Projects
  (reusing the `car` of `org-stuck-projects` as the match), Orphaned Tasks
  (plain `TODO` not inside a project), Waiting, Delegated, On Hold.
  Future-scheduled items are hidden with
  `org-agenda-todo-ignore-scheduled 'future` plus
  `org-agenda-tags-todo-honor-ignore-options t`.
- **Sorting.** Global strategy is `habit-down time-up effort-up
  category-keep` for the agenda and `category-up effort-up` for lists
  ([L190-L194](../reference-emacs-configs/steve-purcell-dotemacs/lisp/init-org.el#L190-L194)) —
  effort rather than priority.
- **Refile.** This file plus agenda files to level 5, outline paths in one
  step, create parents with confirmation, refuse `DONE` headings as targets,
  and save all Org buffers after each refile
  ([L124-L158](../reference-emacs-configs/steve-purcell-dotemacs/lisp/init-org.el#L124-L158)).

His own open TODOs note the model's limits: no warning for a `TODO` outside a
`PROJECT`, and no nested projects
([L315-L316](../reference-emacs-configs/steve-purcell-dotemacs/lisp/init-org.el#L315-L316)).

### greendog-gtd — Jeff's 2019 snapshot from the GTD forums

A local-only repo (no remote, single 2019 commit) whose readme points at Jeff's
notes on the forum thread "Emacs org-mode is the perfect tool for GTD"
([readme.org](../reference-emacs-configs/greendog-gtd/readme.org)).  It is the
most complete *context*-driven setup here.

- **File-level settings.** Mutually exclusive context tags
  `{ @home @errand @review @read_watch_listen }` plus `work` and `daily`;
  `HOLD TODO NEXT WAITING | DONE CANCELLED`; priorities `A G D` (highest,
  lowest, default — so unmarked items sit mid-range)
  ([gtd-settings.org](../reference-emacs-configs/greendog-gtd/gtd-settings.org)).
- **Projects by structure.** A project is a `TODO` with TODO children; a
  hook forces any heading that gains TODO children back to `TODO`, so `NEXT`
  only ever lands on leaves
  ([emacs-org-mode.el L1-L66](../reference-emacs-configs/greendog-gtd/emacs-org-mode.el#L1-L66)).
- **Files.** Separate inbox, projects, someday and birthdays files; refile to
  projects and someday at any depth
  ([L76-L103](../reference-emacs-configs/greendog-gtd/emacs-org-mode.el#L76-L103)).
  Someday is a *file*, not a state.
- **`g` "My General Agenda"**
  ([L126-L244](../reference-emacs-configs/greendog-gtd/emacs-org-mode.el#L126-L244)):
  Inbox, Waiting, Tasks Without Context (no `@` tag), Active and Stuck
  projects split by `work` tag (stuck = project subtree with no `NEXT`, via
  `org-agenda-skip-subtree-if 'todo '("NEXT")`), today's agenda, then a
  `NEXT` block and a `TODO` block per context, each skipping scheduled items
  and sorted `priority-down`.
- **`a` "Tasks that need attention"**: `HOLD` items and `DONE`/`CANCELLED`
  roots awaiting archive
  ([L120-L125](../reference-emacs-configs/greendog-gtd/emacs-org-mode.el#L120-L125)).
- **`r` repeated/scheduled** view and a capture template for repeating tasks
  that reset to `NEXT` with checkboxes cleared
  ([L68-L74](../reference-emacs-configs/greendog-gtd/emacs-org-mode.el#L68-L74),
  [L109-L119](../reference-emacs-configs/greendog-gtd/emacs-org-mode.el#L109-L119)).

The cost is size: the context blocks are near-copies, which is what
`org-super-agenda` groups or a generated list would collapse.

### jwiegley-dotemacs — review-driven, built on org-ql and org-super-agenda

The largest system here; GTD vocabulary is present but the organizing idea is
*periodic review* of every open item.

- **States.** `DRAFT TODO DOING WAIT DEFER TASK HABIT APPT | DONE CANCELED
  PASS`, plus a done-only sequence for `NOTE`, `LINK`, and similar
  ([init.org L11235-L11240](../reference-emacs-configs/jwiegley-dotemacs/init.org#L11235-L11240)).
  `WAIT` is waiting-on-someone; `TASK` is delegated; `DEFER` is a live
  (not done) someday state.
- **Contexts as persistent tags.** `Call`, `Errand`, `Home`, with
  inheritance limited to a named list
  ([L11229-L11232](../reference-emacs-configs/jwiegley-dotemacs/init.org#L11229-L11232),
  [L11272-L11274](../reference-emacs-configs/jwiegley-dotemacs/init.org#L11272-L11274)).
- **Daily `a` agenda** grouped by `org-super-agenda`: Important (`[#A]`,
  not habit), Overdue, Due Soon, Reschedule (scheduled in the past), Review,
  Calls, Errands, Tasks, Habits; then an "Items needing review" block capped
  by `org-agenda-max-entries`, inbox first and otherwise random
  ([lisp/org-config.el L1030-L1071](../reference-emacs-configs/jwiegley-dotemacs/lisp/org-config.el#L1030-L1071),
  [L527-L547](../reference-emacs-configs/jwiegley-dotemacs/lisp/org-config.el#L527-L547)).
- **`r` review prefix**
  ([L1138-L1238](../reference-emacs-configs/jwiegley-dotemacs/lisp/org-config.el#L1138-L1238)):
  needing review, Next Actions (first open child of each project), Projects
  (top-level TODO with TODO children), Stuck projects (project whose first
  child task is unscheduled), Waiting/delegated, Deferred with age, Habits,
  Unscheduled, Never reviewed, and a lint for headlines over 72 characters.
  The project predicates are plain Elisp, not `org-stuck-projects`
  ([lisp/org-ext.el L985-L1030](../reference-emacs-configs/jwiegley-dotemacs/lisp/org-ext.el#L985-L1030)).
- **Review dates** come from [org-review](https://github.com/brabalan/org-review):
  `LAST_REVIEW`/`NEXT_REVIEW` properties, with agenda keys to mark reviewed
  ([init.org L13027-L13060](../reference-emacs-configs/jwiegley-dotemacs/init.org#L13027-L13060)).
- **`g` org-ql prefix** for queries the tag matcher cannot express, e.g.
  `(and (todo …) (not (scheduled)) (property-ts "NEXT_REVIEW" :to today))`
  ([L1086-L1136](../reference-emacs-configs/jwiegley-dotemacs/lisp/org-config.el#L1086-L1136)).
- **Sorting.** Agenda `habit-down time-up todo-state-up priority-down`; lists
  `priority-down category-keep`
  ([init.org L11385-L11389](../reference-emacs-configs/jwiegley-dotemacs/init.org#L11385-L11389)).
- **Experiments.** `org-balance.el` scores tasks by priority × staleness of
  task and category, after LifeBalance
  ([lisp/org-balance.el](../reference-emacs-configs/jwiegley-dotemacs/lisp/org-balance.el));
  `org-today-agenda.el` renders picks from a Claude Code skill as an
  org-ql/super-agenda view
  ([lisp/org-today-agenda.el](../reference-emacs-configs/jwiegley-dotemacs/lisp/org-today-agenda.el)).
  `org-edna` is enabled
  ([init.org L12365-L12369](../reference-emacs-configs/jwiegley-dotemacs/init.org#L12365-L12369)),
  but no `TRIGGER`/`BLOCKER` use turned up in the config itself.

### sacha-chua-dotemacs — many small views, contexts, weekly review

- **States.** `STARTED TODO(next action) TOBLOG WAITING READY SOMEDAY
  BLOCKED | DONE CANCELLED`, a separate `PROJECT | DONE` sequence, and a
  delegation sequence
  ([Sacha.org L14892-L14904](../reference-emacs-configs/sacha-chua-dotemacs/Sacha.org#L14892-L14904)).
  `SOMEDAY` is a live state.
- **Contexts** via `org-tag-alist` with single-key selection
  ([L15009-L15023](../reference-emacs-configs/sacha-chua-dotemacs/Sacha.org#L15009-L15023)).
- **Commands**, documented as a key table in the config
  ([L15629-L15646](../reference-emacs-configs/sacha-chua-dotemacs/Sacha.org#L15629-L15646),
  definitions [L15689-L15869](../reference-emacs-configs/sacha-chua-dotemacs/Sacha.org#L15689-L15869)):
  - `a`: two-day agenda plus org-ql blocks Started, **Important and
    unscheduled** (`[#A]`, no date), Waiting, Projects.
  - `P` **By priority**: one `tags-todo` block each for `PRIORITY="A"`,
    `"B"`, unset, `"C"`.
  - `w` / `W` **Weekly review**: seven-day agenda with log mode, the second
    filtering out `routine`.
  - `c` / `9`: top three per context (`org-agenda-max-entries 3`), all or
    unscheduled only.
  - `u` unscheduled tasks, `!` Someday, `.` Waiting, `pp` projects,
    `5` quick tasks by `EFFORT`, `0` unestimated.
- **Capture** prepends to one inbox with a `CREATED` property; variants
  schedule for today, tomorrow, next week, or mark `SOMEDAY`
  ([L14537-L14580](../reference-emacs-configs/sacha-chua-dotemacs/Sacha.org#L14537-L14580)).
- **Refile** to an explicit file list, plus a faster "inbox" refile to a
  smaller target set and tag-driven automatic refile
  ([L16876-L16900](../reference-emacs-configs/sacha-chua-dotemacs/Sacha.org#L16876-L16900),
  [L17009-L17033](../reference-emacs-configs/sacha-chua-dotemacs/Sacha.org#L17009-L17033)).
- **Shuffled lists** of unscheduled TODO and SOMEDAY items via org-ql
  `:sort 'random`, an Autofocus-style alternative to strict priority
  ([L15894-L15923](../reference-emacs-configs/sacha-chua-dotemacs/Sacha.org#L15894-L15923)).

Her own note — "I often forget to use them" — is a fair warning about
proliferating single-purpose commands
([L15625-L15627](../reference-emacs-configs/sacha-chua-dotemacs/Sacha.org#L15625-L15627)).

### protesilaos-dotfiles — priority-first daily dashboard, no projects

- **States** are minimal: `TODO MAYBE | CANCELLED DONE`; priorities `A`–`C`
  with **default `A`**
  ([prot-emacs-org.el L136-L138](../reference-emacs-configs/protesilaos-dotfiles/emacs/.emacs.d/prot-emacs-modules/prot-emacs-org.el#L136-L138),
  [L166-L167](../reference-emacs-configs/protesilaos-dotfiles/emacs/.emacs.d/prot-emacs-modules/prot-emacs-org.el#L166-L167)).
  `org-enforce-todo-dependencies` and checkbox dependencies are on
  ([L209-L210](../reference-emacs-configs/protesilaos-dotfiles/emacs/.emacs.d/prot-emacs-modules/prot-emacs-org.el#L209-L210)).
- **`C-c a` opens the custom view directly**; plain dispatcher is `C-c A`
  ([L317-L349](../reference-emacs-configs/protesilaos-dotfiles/emacs/.emacs.d/prot-emacs-modules/prot-emacs-org.el#L317-L349)).
- **The daily agenda** ([prot-org.el L330-L408](../reference-emacs-configs/protesilaos-dotfiles/emacs/.emacs.d/prot-lisp/prot-org.el#L330-L408)):
  "Important tasks without a date" (`[#A]` with neither scheduled nor
  deadline), pending past-scheduled items, today, next three days, and
  deadlines in the following fortnight.  The first block uses a custom skip
  function because, per his comments, a `tags-todo "+PRIORITY=\"A\""` match
  did not work for him and an earlier timestamp skip stopped working
  ([L317-L349](../reference-emacs-configs/protesilaos-dotfiles/emacs/.emacs.d/prot-lisp/prot-org.el#L317-L349)).
- **Sorting** `priority-down` within agenda, todo, and tags views
  ([prot-emacs-org.el L378-L382](../reference-emacs-configs/protesilaos-dotfiles/emacs/.emacs.d/prot-emacs-modules/prot-emacs-org.el#L378-L382)).

Worth borrowing for the priority question even without his task model.

### The rest

- **munen-emacs.d** — `TODO`, `PROJECT AGENDA | MINUTES`, `WAITING`;
  capture to an Inbox outline with a Waiting template; refile to agenda files
  level 4; custom commands only filter a work file tag and show habits
  ([configuration.org L2479-L2483](../reference-emacs-configs/munen-emacs.d/configuration.org#L2479-L2483),
  [L2635-L2638](../reference-emacs-configs/munen-emacs.d/configuration.org#L2635-L2638),
  [L5945-L5955](../reference-emacs-configs/munen-emacs.d/configuration.org#L5945-L5955)).
  No stuck or next-action views.
- **redguardtoo-emacs.d** — Purcell-derived keywords including `WAITING`,
  `SOMEDAY`, `PROJECT`; no custom commands
  ([lisp/init-org.el L228-L232](../reference-emacs-configs/redguardtoo-emacs.d/lisp/init-org.el#L228-L232)).
- **abougouffa-minemacs** — Doom-style `TODO PROJ LOOP STRT WAIT HOLD IDEA |
  DONE KILL` keywords only
  ([core/me-builtin.el L630-L643](../reference-emacs-configs/abougouffa-minemacs/core/me-builtin.el#L630-L643)).
- **oantolin-emacs-config** — enables `org-habit` and uses `org-ql-find` for
  navigation; no GTD views
  ([init.el L1079](../reference-emacs-configs/oantolin-emacs-config/init.el#L1079),
  [L1134-L1147](../reference-emacs-configs/oantolin-emacs-config/init.el#L1134-L1147)).
- **matthewzmd-emacs.d** — `TODO IN-PROGRESS REVIEW | DONE CANCELED` only
  ([elisp/init-org.el L57-L58](../reference-emacs-configs/matthewzmd-emacs.d/elisp/init-org.el#L57-L58)).
- **andreyorst-dotfiles** — capture templates for a blog only.
- **yqrashawn-yqdotfiles** — Doom org-roam tweaks; nothing on GTD.
- **bbatsov-dotemacs** — nothing on Org agendas.

## Patterns worth adopting, mapped to Jeff's flow

Each is independent; none requires a new package.

1. **Mark projects explicitly.**  Either add a `PROJECT` sequence
   (Purcell) or a non-inherited `project` tag (Sacha,
   `org-tags-exclude-from-inheritance`).  A tag keeps Jeff's single
   keyword sequence intact; a keyword makes projects visible in every
   view.  This is the prerequisite for items 2 and 3.
2. **Configure `org-stuck-projects` and use the built-in `stuck` block.**
   With a tag: `'("+project/-DONE-CANCELLED" ("NEXT" "DOING") nil "")`.
   Jeff's `DOING` counts as movement, so it belongs in the non-stuck list.
3. **A single `g` GTD block agenda**, Purcell's shape over Jeff's states:
   today; inbox (`todo.org` `Tasks`, or an `INBOX` file tag); stuck
   projects; `NEXT`/`DOING` skipping `WAITING` subtrees; `WAITING`; and
   "Orphaned" `TODO`s outside any project.  Keep it to one command rather
   than Sacha's many.
4. **Decide what `DEFERRED` means.**  If it is Someday/Maybe, move it left of
   the `|` (or add `SOMEDAY`) so it stays live and can have its own
   weekly-review block.  If it really is "closed for now", the tickler file
   already handles "bring this back on a date".
5. **Weekly review command**: `agenda` with `org-agenda-span 7`,
   `org-agenda-start-on-weekday 1`, and `org-agenda-log-mode` on, followed
   by stuck, waiting, and someday blocks — Sacha's `w` plus the GTD lists.
6. **Contexts as a mutually exclusive tag group** (`#+TAGS: { @home(h)
   @work(w) @errand(e) }` or `org-tag-alist` with `:startgroup`), then a
   `NEXT`-by-context block (greendog) or ad-hoc `/` filtering in the
   dashboard rather than a block per context.
7. **Capture as `NEXT` or with a `CREATED` stamp.**  Purcell captures
   straight to `NEXT`; Sacha and Prot add `:CREATED: %U`, which later
   supports "oldest first" or age-based review views.
8. **Refile hygiene** from Purcell: `org-refile-use-outline-path t`,
   `org-outline-path-complete-in-steps nil` (better with Vertico),
   `org-refile-allow-creating-parent-nodes 'confirm`, and a verify function
   that excludes done headings.  Jeff's `:maxlevel 2` is a deliberate
   choice and can stay.

## Built-in agenda features for priorities

All in Org 9.8.7 as installed; node names are from `(org)`.

- **Priority cookies** `[#A]`–`[#C]`; unmarked items count as `B` by
  default.  `C-c ,` sets, `S-<up>`/`S-<down>` cycle, `,` in the agenda sets
  remotely.  Range and default are `org-priority-highest`,
  `org-priority-lowest`, `org-priority-default`, or per file with
  `#+PRIORITIES:` — (org) Priorities.  Two reference choices: Prot defaults
  to `A`; greendog uses `A G D` so new items are mid-range.
- **Urgency sorting.**  The default `org-agenda-sorting-strategy` already
  sorts by `urgency-down` (priority plus deadline/scheduled proximity)
  within category for the agenda, TODO, and tags views; tags *matches* are
  otherwise unsorted — (org) Sorting of agenda items, and the
  variable's docstring.  Dropping `category-keep` sorts across files by
  priority rather than within each file.  Per-block overrides go inside a
  custom command — (org) Setting options.
- **Matching on priority** in tag/property searches:
  `+PRIORITY="A"`, and TODO sublists with `/!NEXT` — (org) Matching tags and
  properties.  Sacha's `P` view is one such block per priority.
- **Skip functions** for what the matcher cannot express:
  `org-agenda-skip-entry-if` with `'scheduled`, `'deadline`, `'timestamp`,
  `'todo`, `'regexp`/`'notregexp`, and `org-agenda-skip-subtree-if` —
  (org) Special Agenda Views.  Prot's "important and undated" block is a
  skip function over `tags-todo "*"`.
- **Block agendas** combining `agenda`, `alltodo`, `stuck`, `todo`, `tags`,
  `tags-todo`, with options per block and for the whole set — (org) Block
  agenda, (org) Setting options.
- **Stuck projects**: `C-c a #`, driven by `org-stuck-projects`; the default
  `("+LEVEL=2/-DONE" ("TODO" "NEXT" "NEXTACTION") nil "")` treats any
  level-2 heading as a project and any `TODO` as movement, so it rarely
  matches a real setup — (org) Stuck projects.
- **Limits and filters**: `org-agenda-max-entries` caps a block (Sacha's
  "top 3 per context"); `/`, `\`, `<`, `_`, `^` filter interactively by
  tag, category, effort, top headline — (org) Filtering/limiting agenda
  items.
- **Dependencies**: `org-enforce-todo-dependencies` and the `ORDERED`
  property block later siblings; `org-agenda-dim-blocked-tasks` (default
  `t`) dims or hides blocked items, which makes "next action" fall out of
  ordering — (org) TODO dependencies.

## Open questions for Jeff

1. **Project marker**: `PROJECT` keyword, `project` tag, or structure only
   (greendog and jwiegley infer "TODO with TODO children")?
2. **`DEFERRED`**: Someday/Maybe (live state) or closed-for-now (done
   state, as today)?
3. **Contexts**: are tags such as `@home`/`@work` useful to you, or is the
   file split (`TASKS`/`PROJECTS` per agenda file) already the context?
4. **Priority range**: keep `A`–`C` with `B` default, or adopt a scheme
   where new captures land mid-range or high?
5. **Scope of a first slice**: just the `g` dashboard and
   `org-stuck-projects` (built-ins only), or also evaluate `org-super-agenda`
   / `org-ql`, which jwiegley's and Sacha's views depend on?
