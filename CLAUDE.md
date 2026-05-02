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

## Git workflow within a feature worktree

Sub-goals tend to span multiple sessions and accumulate refinements — a typo, a follow-up binding, a tweak after live-test feedback, a Claude edit that needed a follow-up. The pattern that keeps history clean while preserving in-flight checkpoints is **fixup commits**: the first commit on the worktree is the real change, every subsequent edit is a fixup of that commit, and `git rebase --interactive --autosquash main` collapses the chain into a single clean commit at sub-goal close.

This is **Pattern A**: first real commit, then fixups. An empty-base alternative ("Pattern B") exists but isn't the default here — it's available for sub-goals where Claude is expected to make many trial-and-error edits.

### The fixup loop

1. Make the change in `jeff-emacs-config.org`.
2. `just verify-tangle` — regenerates `init.el` and load-checks it. Don't fixup until this passes.
3. `git add jeff-emacs-config.org init.el` (and any other tracked files that should land in the same commit).
4. `just fixup` — picks the target interactively via fzf. Almost always the first commit on this worktree.

The `just fixup` recipe deliberately doesn't stage on your behalf. It does check that if `jeff-emacs-config.org` is staged, `init.el` is staged too — staged drift between the two is the main hazard with the literate-config flow, since a squashed final commit could otherwise end up with org changes whose tangle output is stale.

### When to checkpoint

Natural checkpoints during sub-goal execution:

- After `just verify-tangle` passes for a logical change.
- After a verification step in TASK.md passes (live-emacs keystroke check, etc.).
- Before starting a follow-up Claude edit that might need to be reverted.

Claude should suggest `just fixup` at these moments rather than letting in-flight refinements pile up uncheckpointed.

### At sub-goal close

When the sub-goal is verified and ready to merge:

1. `just fixups-pending` — sanity check. Empty output means the chain is already clean.
2. `just squash` — autosquash rebase against main collapses the fixup chain into the target commit.
3. `git push --force-with-lease` — the rebase rewrote history; `--force-with-lease` is the safe form (refuses to overwrite if origin has commits you haven't seen).

### Pre-push hook

A pre-push hook in `.bare/hooks/pre-push` warns (without blocking) when you try to push a branch with unsquashed fixups. The hook is per-machine setup, since `.bare/hooks/` is local to each clone — install once via `just install-fixup-hook` from the workspace root. The canonical hook source is `hooks/pre-push` in the workspace repo (tracked); the install step copies it into `.bare/hooks/`.

If WIP fixups need to travel cross-machine before squashing (paused on machine A, resumed on machine B), bypass the warning with `git push --no-verify`.

## TASK.md convention

If a `TASK.md` file exists in this worktree's root directory, read it before starting any work. It describes what this worktree is currently focused on — the goal, approach, and relevant notes. This file is not tracked in git (excluded per-worktree via `.git/info/exclude`).

## Workspace context

This repo lives inside the `emacs-config` workspace folder alongside reference configurations. For the full workspace layout, see `../CLAUDE.md` (one level up from this worktree, at `emacs-config/CLAUDE.md`).
