# Literate Emacs Configuration

## What this is

Jeff's Emacs configuration, written in literate programming style. The org file is the source of truth; `init.el` is generated from it via org-babel tangle.

## Repo structure

This is a **bare git repo with worktrees**. The top-level directory contains `.bare/` (the bare repo) and worktree directories (e.g., `main/`). All work happens inside a worktree, never at the top level.

The bare-root layout is governed by the `git-worktree-flow` skill — apply that skill for the generic worktree mechanics (session-start sync, starting a feature, fixup loop, close, pre-push hook, sandbox path-translation). This `justfile` wires the shared `wt::*` recipes via `mod wt '~/.config/just/worktree.just'`. The rest of *this* document covers literate-config-specific concerns and emacs-config-specific deviations from the worktree flow.

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

## Git workflow within a feature worktree — literate-config layer

The fixup-loop / close / pre-push pattern is owned by the `git-worktree-flow` skill (`just wt::fixup`, `just wt::close`, the pre-push hook). This section covers only the literate-config-specific layer on top.

**The literate invariant:** `jeff-emacs-config.org` and `init.el` must commit together. A squashed commit whose org changes don't match its tangled `init.el` is the main hazard of the literate-config flow.

`just fixup` in this `justfile` is the project-specific wrapper that enforces it: if `jeff-emacs-config.org` is staged but `init.el` is not, the recipe bails before delegating to `just wt::fixup`. Always use `just fixup` (not `just wt::fixup` directly) for changes that touch the literate config.

**The literate fixup loop:**

1. Edit `jeff-emacs-config.org`.
2. `just verify-tangle` — regenerates `init.el` and load-checks it in batch `-Q`. Don't fixup until this passes.
3. `git add jeff-emacs-config.org init.el` (and any other files that should land in the same commit).
4. `just fixup` — bails on org/init.el asymmetry, otherwise delegates to `wt::fixup` (which targets the first real commit on the branch).

For all the rest — when to checkpoint, sub-goal close (`just wt::close` removes `TASK.md` then autosquashes), pre-push warning, `--force-with-lease` push — see the `git-worktree-flow` skill.

## TASK.md convention

If a `TASK.md` file exists in this worktree's root directory, read it before starting any work. It describes what this worktree is currently focused on — the goal, approach, and relevant notes. The file is **tracked on the feature branch** (committed alongside the work it describes; travels cross-machine via the branch) and **removed by `just wt::close`** before the squash, so it never reaches `main`. See the `git-worktree-flow` skill's TASK.md convention for the full rationale.

## Workspace context

This repo lives inside the `emacs-config` workspace folder alongside reference configurations. For the full workspace layout, see `../CLAUDE.md` (one level up from this worktree, at `emacs-config/CLAUDE.md`).
