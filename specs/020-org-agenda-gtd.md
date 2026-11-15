# 020 — An Org agenda for GTD-style project management

I manage projects in Org with my own states (`TODO NEXT DOING WAITING | DONE
CANCELLED DEFERRED`), capture templates and refile, but I have no custom agenda
commands. I like a Getting Things Done flow, and I want the agenda to show me
what to do next, which projects are stuck, and what matters most by priority.
`research/org-agenda-gtd.md` (#79) found real GTD agenda setups in
steve-purcell, jwiegley, sacha-chua and my own greendog-gtd snapshot, and a
priority view in protesilaos. I want to choose among those patterns rather
than invent new configuration.

Each agenda file splits into `* Tasks` and `* Projects`, and I don't find the
distinction helpful: what goes under each is arbitrary, and the file is
already the work stream. I want to replace it.

## Ask

1. Replace the Tasks/Projects split. The proposed layout:
   - One file per work stream, as `lab.org`, `emacs.org` and `jeff-ci.org`
     already are.
   - Top-level headings are projects, each with its next actions beneath it,
     plus one `* Misc` heading for tasks that belong to no project.
   - `todo.org` mixes several work streams; its top-level headings become
     areas (home, family and estate, finance and investing, learning and AI),
     or the larger ones move to files of their own.
   - `someday.org` takes the same layout, so moving a project in or out stays
     one refile.
   - Decide how a project is marked: a non-inherited `project` tag is
     proposed, over a `PROJECT` keyword or structure only (a TODO with TODO
     children).
2. Decide what `DEFERRED` means: Someday/Maybe as a live state, or closed for
   now as it is today.
3. Decide whether context tags (`@home`, `@work`, …) are worth adding, or
   whether my file layout already serves as the context.
4. Decide the priority range and default, and how priority shows in the
   agenda: a separate block for important undated items, sorting only, or
   both.
5. Decide whether the first slice uses only built-in Org, or also tries
   `org-super-agenda` or `org-ql`.
6. From those decisions, list the config changes, each sized to its own
   `literate-emacs.d` worktree and pull request. The starting candidates are
   `org-stuck-projects`, one GTD block agenda, a weekly-review command, and
   the refile settings from steve-purcell.

## Scope

Planning only: the outcome is the list of changes, not configuration in
`literate-emacs.d`. The plan includes restructuring my Org files under
`~/jwm/todo`: which files change, in what order, and whether
`org-refile-targets` changes with them. Capture, habits and `org-edna` stay
out unless a decision above needs them.

## Outcome

### Decided

- **States are steve-purcell's, adopted whole** (`lisp/init-org.el`), mapped
  from mine:

  | Mine | steve-purcell's |
  |---|---|
  | `TODO`, `NEXT`, `WAITING`, `DONE`, `CANCELLED` | the same |
  | `DOING` on a task | `NEXT` |
  | `DOING` on a project heading | `PROJECT` |
  | `DEFERRED` | `HOLD` |
  | (none) | `DELEGATED` |

  His sequences: `TODO NEXT | DONE`; `PROJECT | DONE CANCELLED`;
  `WAITING DELEGATED HOLD | CANCELLED`. A repeating task returns to `NEXT`.
- **Projects** are headings with the `PROJECT` keyword. A project is stuck
  until one step beneath it is `NEXT`; that is his `org-stuck-projects`,
  unchanged. A heading with no keyword appears in no agenda list.
- **Inbox** is its own file, `inbox.org`, with `#+FILETAGS: INBOX`. Capture `t`
  writes a `NEXT` item there, as in steve-purcell's config. I empty it at each
  weekly review.
- **Areas**: one agenda file per area; its top-level headings are projects plus
  one `* Misc` heading for tasks that belong to no project. The split of
  `todo.org` is on the wayfinder map (#76): `lab`, `emacs`, `invest`,
  `garage` and `coding`, with `todo.org` keeping a Misc for everything else.
- **No tags** in the agenda files except `INBOX` on `inbox.org`. No context
  tags; the file is the area, and the agenda groups and filters by it. The tags
  on headings in `someday.org` go with its contents.
- **Dashboard** `C-c a g`: steve-purcell's `g` block agenda, unchanged, with
  protesilaos's block of `[#A]` tasks that have no scheduled date or deadline
  added first, and `someday.org` left out of the whole command.
- **Priority**: `A` to `C` with `B` as the default; the rest of the agenda keeps
  the default urgency sort.
- **someday.org** stays as the Someday/Maybe list for things I haven't
  committed to, but starts this work empty: its contents move to
  `someday.org_archive`. It stays in the agenda files so refile reaches it.
  `HOLD` is for paused items I still mean to do, which stay in their area.
- **Built-in Org only**; `org-super-agenda` and `org-ql` wait until a built-in
  view falls short.
- **One agenda view**: the dashboard is the only custom view this work builds.
  There is no separate weekly-review command; when my "Personal Weekly Review"
  tickler entry fires, I open the dashboard and press `l` to see what I closed.
- **Refile** takes steve-purcell's settings with `:maxlevel 3`.
- Archive files keep their tags; nothing in this work touches them.

### Build order

Decided on the wayfinder map #75; the area split is in #76 and its
amendments. Three pull requests, in this order:

Done: item 1 in `jmccarrell/literate-emacs.d` PR #88, item 2 in
`jmccarrell/jwm-todo` PR #3, item 3 in `jmccarrell/jwm-todo` PR #4.

1. **`literate-emacs.d`: steve-purcell's states and the dashboard.**
   - His `org-todo-keywords`, `org-todo-keyword-faces`,
     `org-todo-repeat-to-state` and `org-stuck-projects`, copied.
   - Capture `t` writes `* NEXT` to `inbox.org` in `org-directory`.
   - His refile settings, with `:maxlevel 3`.
   - `C-c a g`: his `g` block agenda with protesilaos's undated `[#A]` block
     first and `someday.org` left out of the command.
   - The cheat sheet's Org section gets the states and the dashboard keys.
2. **`jwm-todo`: the files take his states.** Merged right after 1, since
   each one alone leaves states Org doesn't recognize.
   - `DOING` becomes `NEXT` on tasks; `DOING` on a project heading, and every
     heading under `* Projects`, becomes `PROJECT`; `DEFERRED` becomes `HOLD`.
   - New `inbox.org` with `#+FILETAGS: INBOX`, first in
     `org-agenda-files-list`.
   - someday.org's contents move to `someday.org_archive`; the file stays.
3. **`jwm-todo`: the area split.** Independent of 1 and 2 once they land.
   - Done items archived; "todo weekend Nov 7" broken into tasks.
   - New `invest.org`, `garage.org` and `coding.org`; project headings
     promoted to top level in each area, with `* Misc` for the rest.
   - `todo.org` keeps Misc only; `jeff-ci.org` and `tome.org` leave
     `org-agenda-files-list`, and `tome.org` is deleted.
