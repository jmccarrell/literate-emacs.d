# Worktree management

## Goal

Make Magit's native Git-worktree workflow default to Jeff's
`<repo>.worktrees/<branch-slug>` convention and make registered worktrees
quick to reopen from Emacs.

## Why

Implements the focused follow-up in
`../research/worktree-management.md`.

## Approach

1. Add small, testable helpers for deriving the convention's container path
   and parsing `git worktree list --porcelain` output.
2. Configure Magit's directory reader and worktree-preferred diff visits.
3. Add an interactive `jwm/` selector that opens a Git-registered worktree in
   Magit.

## Verification

- Run the ERT worktree-management tests.
- Run `just verify-tangle`.
- Exercise `C-x g Z c` and the selector in a live Emacs session.
