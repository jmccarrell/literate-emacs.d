# Literate Emacs Configuration

## What this is

Jeff's Emacs configuration, written in literate programming style. The org file is the source of truth; `init.el` is generated from it via org-babel tangle.

## Key files

- `jeff-emacs-config.org` -- the literate config (source of truth)
- `init.el` -- **generated file**, tangled from the org file (`#+PROPERTY: header-args:emacs-lisp :tangle "init.el"`)
- `emacs-cheat-sheet.org` / `.md` -- reference cheat sheet
- `README.org` -- symlink to `jeff-emacs-config.org`

## Important: init.el is generated

Do NOT edit `init.el` directly. All Emacs Lisp changes go in `jeff-emacs-config.org` inside `#+BEGIN_SRC emacs-lisp` blocks. The user tangles the org file from Emacs to regenerate `init.el`.

## Conventions

- Emacs Lisp functions/variables use the `jwm/` prefix
- Commit messages: lowercase, short imperative phrases (e.g., "add yaml mode", "adjust font size")
- Package management via `use-package`

## Git workflow: org and init.el commit together

**The literate invariant:** `jeff-emacs-config.org` and `init.el` must always
commit together, so the tracked `init.el` always matches the org it was tangled
from. A commit whose org changes don't match its tangled `init.el` is the main
hazard of a literate config.

The loop:

1. Edit `jeff-emacs-config.org`.
2. `just verify-tangle` — regenerates `init.el` and load-checks it in batch `-Q`.
   Don't commit until this passes.
3. `git add jeff-emacs-config.org init.el` (plus any other files that belong in
   the same commit).
4. `git commit`.

## TASK.md convention

If a `TASK.md` file exists in the repo root (or a feature worktree's root), read it before starting any work. It describes what's currently being worked on — the goal, approach, and relevant notes. It is branch-tracked and should be removed before the branch is merged, so it never reaches `main`.

## GitHub issue workflow

When work starts from a GitHub issue, honor the `agent:*` label as the workflow
state pointer. The state machine and execution spec template live in
[`docs/workflow/agent-workflow.md`](docs/workflow/agent-workflow.md) and
[`docs/workflow/execution-spec-template.md`](docs/workflow/execution-spec-template.md).

GitHub issues are the public backlog/spec surface when an issue exists. The
parent workspace's `specs/` directory remains the durable home for local briefs
that start outside GitHub, and `TASK.md` remains branch-local execution context.
If both exist, link the branch `TASK.md` back to the issue or workspace spec that
it implements.

## Workspace context

This repo lives inside the `emacs-config` workspace folder alongside reference configurations. For the full workspace layout, see `../CLAUDE.md` (one level up, at `emacs-config/CLAUDE.md`).
