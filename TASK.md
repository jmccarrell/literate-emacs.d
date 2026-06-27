# V1 LLM-assisted Python buffer editing

## Goal

Add a review-first `gptel-rewrite` workflow for selected regions in Python
buffers, using the existing `gptel` backends and current Python tooling.

## Why

This is the first implementation slice from the AI / LLM integration work:
`gptel` chat already exists, but code editing in live buffers should start with
a small, explicit, reviewable command before broader project-editing agents or
inline completion.

## Approach

- Configure `gptel-rewrite` from the existing `gptel` package.
- Bind `C-c g r` for region rewrite.
- Keep rewrite results review-first by leaving `gptel-rewrite-default-action`
  nil.
- Add a Python-specific rewrite directive for `python-mode` and
  `python-ts-mode`.
- Add `gptel-context` bindings for adding and clearing optional context.
- Document the new keys in `emacs-cheat-sheet.org`.

## Verification

- Run `just verify-tangle`.
- Confirm `init.el` contains the generated `gptel-rewrite` and
  `gptel-context` blocks.
- In live Emacs, test `C-h f gptel-rewrite` and
  `C-h v gptel-rewrite-default-action`.
- In a Python buffer, select a function, run `C-c g r`, inspect diff/ediff,
  accept the rewrite, save, and confirm Ruff/Eglot behavior remains normal.
