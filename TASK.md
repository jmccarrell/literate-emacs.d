# Rust language baseline

## Goal

Make Rust tree-sitter support a working, explicit outcome in Emacs, then
provide the built-in Eglot and formatting baseline for ordinary Cargo projects.

## Why

Implements the first slice recommended by workspace issue #4 and
`research/rust-emacs-language-baseline.md`.

## Approach

- Add the official `tree-sitter-rust` recipe and make `rust` a required
  grammar.
- Associate `.rs` files with built-in `rust-ts-mode` only when the grammar is
  installed.
- Start built-in Eglot in Rust buffers and expose `eglot-format-buffer` on
  `C-c r f`; do not add format-on-save or third-party Rust packages.
- Document the per-machine Rust toolchain and grammar setup in the cheat sheet.

## Verification

- `just verify-tangle` passes and `init.el` is committed with the Org source.
- In a live Emacs using this worktree: run `rustup component add rust-analyzer
  rust-src`, then `M-x jwm/ensure-treesit-grammars`; after restarting Emacs,
  `(treesit-ready-p 'rust t)` is non-nil and a `.rs` file uses `rust-ts-mode`.
- In a Cargo project, Eglot connects to `rust-analyzer` and `C-c r f` formats
  the buffer; `cargo fmt -- --check` passes.

## Cleanup

Remove this file before merging the feature branch.
