# Cargo feedback loop for Rust projects

**Issue:** [#5 — Discover Cargo feedback loop for Rust projects](https://github.com/jmccarrell/emacs-config/issues/5)
**Status:** research only; no active Emacs configuration has changed.

## Recommendation

Use Emacs's built-in compilation loop as the baseline:

1. Select the intended Cargo package or workspace root.
2. Run the chosen Cargo command with `project-compile` (`C-x p c`) when that
   Emacs project root is also the Cargo root.  Otherwise start `compile` with
   `default-directory` at the Cargo root.
3. Read the shared compilation transcript, repeat its last command with `g`
   in the Compilation buffer (or `M-x recompile`), and visit diagnostics with
   `C-x \`` / `M-g M-n` and `M-g M-p`.
4. Add one small Rust diagnostic regexp to the configuration before relying on
   Cargo compiler errors in this installed Emacs.  Do not add a package.

The Cargo commands should be explicit about workspace scope:

| Purpose | Single-crate root | Workspace root |
| --- | --- | --- |
| Reformat | `cargo fmt` | `cargo fmt --all` |
| Verify formatting without editing | `cargo fmt --check` | `cargo fmt --all --check` |
| Fast compiler feedback | `cargo check` | `cargo check --workspace` |
| Run tests | `cargo test` | `cargo test --workspace` |

`cargo check` is the primary tight-loop command because it performs type and
other compiler checks without final code generation.  `cargo test` is the
slower, execution-bearing confirmation step.  Formatting is intentionally a
separate command: `--check` is suitable for a non-mutating verification pass,
while `cargo fmt` deliberately writes the formatting changes.

## Root-selection boundary

`project-compile` is the right Emacs command only if `project-root` is the
Cargo root intended for the command.  Project.el's standard VC backend is
VCS-aware, not Cargo-aware, so a repository containing several Cargo
workspaces can have a project root above the desired `Cargo.toml`.

For an unambiguous workspace root, Cargo itself supplies the evidence:

```sh
cargo locate-project --workspace
```

Run the compilation from the directory containing the returned manifest (or
later teach a small helper to do that).  This also avoids Cargo's
default-member behavior being mistaken for a whole-workspace command.

No package is justified for root selection: use explicit `--workspace` while
the desired root matches the Emacs project, and use the Cargo-discovered root
when it does not.  A future helper is only justified by repeated friction in
real repositories with a VCS root different from a Cargo workspace root.

## Diagnostic-navigation evidence

Local validation used Cargo 1.97.0 and Emacs 30.2 with a dependency-free,
throwaway virtual workspace.  `cargo check` at the workspace root reported a
deliberate type error at:

```text
 --> member/src/lib.rs:2:5
```

Stock Emacs 30.2 did **not** parse that result: its
`compilation-error-regexp-alist-alist` had neither a `rust` nor a
`cargo-rust` entry, and `next-error` signalled `Past last error`.  This is a
demonstrated configuration gap, not a package gap.

Adding this narrow regexp to the Compilation buffer's regexp lists caused
`next-error` to open `member/src/lib.rs` at line 2:

```elisp
(cargo-rust
 "^[[:space:]]*-->[[:space:]]+\\([^:\n]+\\):\\([0-9]+\\):\\([0-9]+\\)"
 1 2 3)
```

The follow-on implementation should install that entry under a project-owned
name (for example, `jwm/cargo-rust`) and confirm it against Jeff's actual
Emacs build.  Keep Cargo's default human-readable messages.  Compilation mode
is regexp-based, whereas Cargo's JSON message formats need a different
consumer and are outside this low-surface-area loop.

## Concrete acceptance scenarios for issue #6

These are technical scenarios for the separate human decision; they are not a
course curriculum.

1. **Single-crate check:** from a buffer under a single-crate Cargo root,
   `C-x p c` with `cargo check` opens a compilation transcript.  After an
   intentional compiler error, `C-x \`` visits its source location.  `g`
   repeats the same command.
2. **Workspace check:** from the workspace root, `C-x p c` with
   `cargo check --workspace` reports a failing member crate and `C-x \``
   reaches that member's source file.
3. **Format boundary:** `cargo fmt --all --check` detects formatting drift
   without editing files; `cargo fmt --all` is a deliberate, separate write.
4. **Test boundary:** `cargo test --workspace` is used when executing tests is
   wanted, rather than conflating test execution with the fast `cargo check`
   loop.

## Why built-ins are enough

Emacs `compile` runs a shell command asynchronously in `default-directory`,
keeps its transcript in a Compilation buffer, and `recompile` reuses the
previous command and directory.  Compilation mode turns recognized diagnostics
into source locations, and `next-error` / `previous-error` navigate them.
`project-compile` simply runs that same loop from `project-root`.

The only observed missing piece is recognition of Rust's indented `-->`
diagnostic location in the installed Emacs.  A local regexp is smaller and
more maintainable than introducing a Cargo-mode package.  Reconsider a package
only if that regexp cannot handle real Cargo diagnostic forms, or if daily use
demonstrates a distinct command/history UX gap that a small configuration
cannot meet.

## Sources

- Local Emacs 30.2 Info manual: [Running Compilations under Emacs](https://www.gnu.org/software/emacs/manual/html_node/emacs/Compilation.html), [Compilation Mode](https://www.gnu.org/software/emacs/manual/html_node/emacs/Compilation-Mode.html), and [Working with Projects](https://www.gnu.org/software/emacs/manual/html_node/emacs/Projects.html).  The local manual establishes `compile`, `recompile`, Compilation mode, `next-error`, and project-root semantics used above.
- GNU Emacs manual: [Project File Commands](https://www.gnu.org/software/emacs/manual/html_node/emacs/Project-File-Commands.html), documenting `project-compile`.
- Cargo book: [`cargo check`](https://doc.rust-lang.org/cargo/commands/cargo-check.html), [`cargo test`](https://doc.rust-lang.org/cargo/commands/cargo-test.html), and [`cargo fmt`](https://doc.rust-lang.org/cargo/commands/cargo-fmt.html).
- Cargo reference: [Workspaces](https://doc.rust-lang.org/cargo/reference/workspaces.html), for workspace discovery and default-member behavior.
