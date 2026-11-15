# Rust language support baseline for Emacs 30

Research for [issue 4](https://github.com/jmccarrell/emacs-config/issues/4).
This records a recommendation only; it does not change the Emacs
configuration.

## Recommendation

Use the built-in `rust-ts-mode` when the Rust tree-sitter grammar is available,
and the built-in Eglot client with `rust-analyzer` for the Core Rust Loop. Keep
Cargo project discovery and formatter policy project-owned. The initial
configuration should add only the Rust grammar recipe/remap and an
`(rust-ts-mode rust-mode)` Eglot hook. Use Eglot's formatting command as the
initial formatting interface, which lets `rust-analyzer` honor the project's
Rustfmt policy; decide whether format-on-save is useful only after it has been
exercised in real Cargo projects. Do not add `rust-mode`, `lsp-mode`, `rustic`,
`eglot-x`, or a Rust-specific completion framework in the first slice.

This is an inference from the sources below and the active configuration: it
already uses grammar-conditional tree-sitter remaps, built-in Eglot, and
formatter-on-save integrations for Go and Python. Eglot 1.17.30 bundled with
the installed Emacs maps both `rust-ts-mode` and `rust-mode` to
`rust-analyzer` by default, so no additional server-program entry is needed
for the default case. Rust should not copy Go's external `go-mode` or its
`goimports` save hook: Emacs 30 already supplies the Rust tree-sitter mode,
and Rustfmt policy belongs to each Cargo Project. Nor should it copy Python's
Ruff/Flymake/PET layers: rust-analyzer and Cargo own the corresponding Rust
language and toolchain boundaries for this baseline.

## What the baseline provides

### Syntax and structural editing

Emacs 30 ships `rust-ts-mode`, a tree-sitter major mode for Rust. The local
source confirms that it auto-associates `.rs` files when `treesit-ready-p`
finds the Rust grammar, and provides tree-sitter fontification, indentation,
Imenu entries, and defun navigation. Tree-sitter parses source for
fontification; it is not a substitute for project-aware diagnostics or symbol
navigation. The [Emacs Lisp manual's parser-based font-lock
section](https://www.gnu.org/software/emacs/manual/html_node/elisp/Parser_002dbased-Font-Lock.html)
explains this split.

The grammar is a per-machine prerequisite, not a package dependency in the
configuration repository. The existing grammar bootstrap pattern therefore
fits: declare the official
[tree-sitter-rust grammar](https://github.com/tree-sitter/tree-sitter-rust)
recipe, add `rust` to the required grammar list, and remap `rust-mode` to
`rust-ts-mode` only when the grammar is ready.

The local Emacs source adds the `.rs` association only when its Rust grammar is
ready. The active configuration has no separate `rust-mode` package, so the
first slice must not present a grammar-absent fallback as working Rust support:
the preflight must install the grammar before `.rs` files are associated with
`rust-ts-mode`.

### Project intelligence

Eglot is the built-in LSP client. Its normal integration supplies
documentation through ElDoc, diagnostics through Flymake, definitions and
references through Xref, buffer navigation through Imenu, completion through
`completion-at-point`, and server-supplied code actions/formatting. See the
[Eglot manual](https://joaotavora.github.io/eglot/). Its local default server
table maps `(rust-ts-mode rust-mode)` to `rust-analyzer`.

For ordinary Cargo projects, open a file under the crate or workspace root and
start Eglot once for that project (or enable `eglot-ensure` from both Rust
mode hooks). Eglot reuses a server per Emacs project and starts it at the
project root. This handles both a course's single crate and a standard Cargo
workspace without special Emacs-side workspace configuration. Cargo itself
defines workspaces as managed packages sharing a root `Cargo.lock` and target
directory, and searches parent directories for a workspace manifest; see the
[Cargo workspace reference](https://doc.rust-lang.org/cargo/reference/workspaces.html).

`rust-analyzer` must be installed as an executable visible to Emacs, and it
needs Rust standard-library sources. The official installation guide names
`rustup component add rust-analyzer` and `rustup component add rust-src`; it
also says only latest stable standard-library sources are officially
supported. See [rust-analyzer installation](https://rust-analyzer.github.io/book/installation.html).

Do not initially set `linkedProjects`, feature overrides, target overrides,
or custom Cargo commands. rust-analyzer's defaults already refresh Cargo
metadata after manifest changes, run build scripts, check on save, and use
`cargo check`; these defaults are the right starting point for conventional
Cargo projects. The [rust-analyzer configuration
reference](https://rust-analyzer.github.io/book/configuration.html) documents
those defaults. If rust-analyzer and an interactive Cargo command contend for
`Cargo.lock`, `cargo.targetDir` is a documented remediation, with duplicated
artifacts as its cost—not an initial default.

### Formatting

Treat formatting as project policy. `cargo fmt` formats the current crate's
binary and library files using rustfmt, per the [Cargo fmt
reference](https://doc.rust-lang.org/cargo/commands/cargo-fmt.html). A project
can provide `rustfmt.toml` or `.rustfmt.toml`; the initial Emacs integration
must honor that file rather than impose personal options.

Start with `eglot-format-buffer`, which asks the language server to format the
current buffer, rather than invoking `cargo fmt` for a whole crate or workspace
on every save. rust-analyzer documents integrated Rustfmt formatting; the
[Rust Edition Guide's rustfmt style-edition guidance](https://doc.rust-lang.org/nightly/edition-guide/rust-2024/rustfmt-style-edition.html)
also recommends a project `style_edition` when editor formatting and CI must
agree. `cargo fmt` remains the project-level validation command. A later
format-on-save hook must first prove that it preserves this project-owned policy
and is acceptably fast for both acceptance projects.

### Local preflight

The installed Emacs 30.2 has `rust-ts-mode` and Eglot's default Rust mapping,
but no Rust grammar is available in the configured tree-sitter directory.
Rustfmt is installed through the stable toolchain. The `rust-analyzer` command
currently resolves to a rustup proxy, but exits with "Unknown binary
`rust-analyzer`"; the installed component list contains neither `rust-analyzer`
nor `rust-src`. Before enabling Eglot, the user-owned toolchain must therefore
provide both components. This is a preflight condition for the configuration,
not a request to manage the toolchain from Emacs.

## First implementation slice

The first implementation should be deliberately small and verifiable:

1. Add Rust to the existing grammar bootstrap/remap pattern.
2. Enable `eglot-ensure` for both `rust-mode` and `rust-ts-mode`.
3. Expose `eglot-format-buffer` as the first Rust formatting command, without
   imposing personal Rustfmt settings or a format-on-save hook.
4. Verify the same flow in a single-crate course exercise and a Cargo
   workspace: open a Rust file, confirm mode and Eglot connection, navigate
   to a definition and reference, inspect a Flymake diagnostic, format a
   change, and confirm `cargo fmt -- --check` is clean.

The implementation should start with rust-analyzer's normal `cargo check`
diagnostics. After that loop is demonstrated, a separate decision can enable
Clippy via Eglot initialization options. The [rust-analyzer editor
guide](https://rust-analyzer.github.io/book/other_editors.html) shows the
Eglot `:check (:command "clippy")` option and calls Eglot the minimal client
for Emacs 29+.

This research does not create the implementation ticket. The first
implementation ticket must name [issue 4](https://github.com/jmccarrell/emacs-config/issues/4)
as its parent evidence and link this artifact, so the later configuration
decision remains traceable to its recommendation.

## Demonstrated gaps that justify additional packages

Add a package only after observing one of these gaps in the two acceptance
projects:

| Observed gap | Smallest justified follow-up |
| --- | --- |
| Standard Eglot/LSP functionality is insufficient because a needed workflow depends on rust-analyzer LSP extensions. | Investigate `eglot-x` as an explicit, experimental extension; Eglot deliberately does not implement those extensions. |
| `rust-analyzer` cannot resolve the selected toolchain's standard-library sources. | Correct the Rust toolchain/`rust-src` prerequisite; do not add an Emacs package. |
| A project needs nondefault feature/target/check behavior. | Add project-scoped `eglot-workspace-configuration`, backed by that project's Cargo requirements. |
| The course needs interactive debugging. | Resolve the already-deferred debugger decision separately; it is not a language-support baseline concern. |
| Formatting conflicts with CI. | Fix the project-owned rustfmt/style-edition configuration first. |

## Boundaries

- This does not prescribe Rust toolchain installation or manage global Rust
  state; those are user-owned prerequisites.
- It does not configure inline AI completion, autonomous edits, or a
  Rust-specific gptel directive. AI support remains a post-Core-Rust-Loop
  follow-up.
- It does not make debugger integration a prerequisite.
- It does not replace the project-facing Cargo feedback-loop investigation in
  issue 5.

## Sources

- Local Emacs 30.2 sources: `rust-ts-mode.el` and `eglot.el` from
  `/Applications/Emacs.app/Contents/Resources/lisp/progmodes/`, inspected
  2026-07-13.
- [GNU Emacs Lisp Reference Manual: Parser-based Font Lock](https://www.gnu.org/software/emacs/manual/html_node/elisp/Parser_002dbased-Font-Lock.html)
- [Eglot manual](https://joaotavora.github.io/eglot/)
- [rust-analyzer: Installation](https://rust-analyzer.github.io/book/installation.html)
- [rust-analyzer: Other Editors (Emacs)](https://rust-analyzer.github.io/book/other_editors.html)
- [rust-analyzer: Configuration](https://rust-analyzer.github.io/book/configuration.html)
- [Cargo Book: Workspaces](https://doc.rust-lang.org/cargo/reference/workspaces.html)
- [Cargo Book: cargo fmt](https://doc.rust-lang.org/cargo/commands/cargo-fmt.html)
- [Rust Edition Guide: rustfmt style edition](https://doc.rust-lang.org/nightly/edition-guide/rust-2024/rustfmt-style-edition.html)
