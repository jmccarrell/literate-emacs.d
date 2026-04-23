# Literate Emacs Configuration

## What this is

Jeff's Emacs configuration, written in literate programming style. The org file is the source of truth; `init.el` is generated from it via org-babel tangle.

## Repo structure

This is a **bare git repo with worktrees**. The top-level directory contains `.bare/` (the bare repo) and worktree directories (e.g., `main/`). All work happens inside a worktree, never at the top level.

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

## TASK.md convention

If a `TASK.md` file exists in this worktree's root directory, read it before starting any work. It describes what this worktree is currently focused on — the goal, approach, and relevant notes. This file is not tracked in git (excluded per-worktree via `.git/info/exclude`).

## Workspace context

This repo lives inside the `emacs-config` workspace folder alongside reference configurations. For the full workspace layout, see `../CLAUDE.md` (one level up from this worktree, at `emacs-config/CLAUDE.md`).
