# Recipes for the literate Emacs config.
# Worktree mechanics live in the shared git-worktree-flow recipes,
# wired in below. Use `just wt::new`, `just wt::status`, `just wt::close`,
# etc. The project-specific `fixup` recipe below is a thin wrapper
# around `wt::fixup` that adds the literate-config sanity check.

# Shared worktree recipes (optional).
mod? wt '~/.config/just/worktree.just'

# Default: show the recipe list. Underscore-prefixed name marks
# this as a "private" recipe; `@` makes its commands silent so
# the user sees only the listing.
@_:
    just --list

# Regenerate init.el from the literate config.
tangle:
    emacs --batch \
          -l org \
          --eval '(org-babel-tangle-file "jeff-emacs-config.org")'

# Tangle, then load init.el in batch emacs to catch load-time errors.
# Uses -Q (no user init), then loads init.el inside a condition-case
# so any error is caught explicitly. Clean load -> exit 0; any error
# during load -> print the error to stderr and exit 1. just then
# reports success/failure based on the exit code.
verify-tangle: tangle
    emacs --batch -Q \
          --eval '(condition-case err (load-file "init.el") (error (princ (format "ERROR loading init.el: %S\n" err)) (kill-emacs 1)))' \
          --eval '(kill-emacs 0)'
    @echo "verify-tangle: PASS"

# Refresh info-dir.txt — a snapshot of all Info manuals visible to
# this Emacs install. Run when packages change. The file is tracked
# in git; commit after running.
#
# Implementation note: capture the absolute output path BEFORE
# (info "(dir)") runs, because that call switches to the *info*
# buffer whose default-directory is Emacs's info-data dir, not the
# shell's cwd. Without expand-file-name, write-region would land
# in /Applications/Emacs.app/.../share/info/.
info-dir-update:
    @emacs --batch \
           --eval '(package-initialize)' \
           --eval '(let ((out (expand-file-name "info-dir.txt"))) (condition-case err (progn (info "(dir)") (write-region (point-min) (point-max) out)) (error (princ (format "ERROR: %S\n" err)) (kill-emacs 1))))'
    @echo "info-dir-update: wrote info-dir.txt ($(wc -l < info-dir.txt) lines)"

# Project wrapper around `just wt::fixup` that enforces the literate-config
# invariant: jeff-emacs-config.org and init.el must commit together.
# `wt::fixup` itself targets the first commit on this branch automatically;
# this wrapper only adds the org/init.el sanity check before delegating.
#
# Workflow: edit jeff-emacs-config.org -> just verify-tangle ->
# git add (org + init.el) -> just fixup. The recipe deliberately
# doesn't stage on your behalf.
#
# It bails if jeff-emacs-config.org is staged but init.el is not —
# staged drift between the two would otherwise produce a squashed
# final commit whose org changes don't match init.el.
fixup:
    @if git diff --cached --name-only | grep -q '^jeff-emacs-config.org$' && \
        ! git diff --cached --name-only | grep -q '^init.el$'; then \
       echo "ERROR: jeff-emacs-config.org is staged but init.el is not."; \
       echo "Run 'just verify-tangle' to regenerate init.el, then 'git add init.el', then retry."; \
       exit 1; \
     fi
    @just wt::fixup

# Dump a specific Info node to info-node.txt for attachment to a session.
# Use after consulting info-dir.txt to find the right node.
# Usage: just info-node "(magit) Worktree"
# Output: info-node.txt (overwritten each call).
info-node node:
    @emacs --batch \
           --eval '(package-initialize)' \
           --eval '(let ((out (expand-file-name "info-node.txt"))) (condition-case err (progn (info "{{node}}") (write-region (point-min) (point-max) out)) (error (princ (format "ERROR: %S\n" err)) (kill-emacs 1))))'
    @echo "info-node: wrote info-node.txt ($(wc -l < info-node.txt) lines)"

# Report where the package-provided MCP stdio helper lives and whether
# the global helper target matches it. This is read-only: it does not
# install, overwrite, or remove ~/.emacs.d/emacs-mcp-stdio.sh.
mcp-stdio-helper-status:
    @emacs --batch -Q \
           --eval '(require (quote package))' \
           --eval '(package-initialize)' \
           --eval '(require (quote mcp-server-lib))' \
           --eval '(require (quote mcp-server-lib-commands))' \
           --eval '(condition-case err (let* ((source (mcp-server-lib--package-script-path)) (target (mcp-server-lib--installed-script-path)) (target-exists (and target (file-exists-p target))) (matches (and source target-exists (with-temp-buffer (insert-file-contents-literally source) (let ((source-text (buffer-string))) (erase-buffer) (insert-file-contents-literally target) (string= source-text (buffer-string))))))) (princ (format "package_source: %s\n" (or source "missing"))) (princ (format "install_target: %s\n" target)) (princ (format "target_exists: %s\n" (if target-exists "yes" "no"))) (princ (format "matches_package_helper: %s\n" (cond ((not target-exists) "n/a") (matches "yes") (t "no")))) (princ "install_command: M-x mcp-server-lib-install\n") (princ "teardown_command: M-x mcp-server-lib-uninstall\n")) (error (princ (format "ERROR: %S\n" err)) (kill-emacs 1)))'
