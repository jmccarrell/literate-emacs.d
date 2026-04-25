# Recipes for the literate Emacs config.
#
# Run `just --list` to see all recipes.
# Run `just tangle` after editing jeff-emacs-config.org.
# Run `just verify-tangle` to tangle and then load the result in batch
# emacs (-Q) to catch syntax/load errors fast.

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

# Dump a specific Info node to /tmp for attachment to a session.
# Use after consulting info-dir.txt to find the right node.
# Usage: just info-node "(magit) Worktree"
# Output: /tmp/info-node.txt (overwritten each call).
#
# /tmp/info-node.txt is absolute, so no expand-file-name dance needed.
info-node node:
    @emacs --batch \
           --eval '(package-initialize)' \
           --eval '(condition-case err (progn (info "{{node}}") (write-region (point-min) (point-max) "/tmp/info-node.txt")) (error (princ (format "ERROR: %S\n" err)) (kill-emacs 1)))'
    @echo "info-node: wrote /tmp/info-node.txt ($(wc -l < /tmp/info-node.txt) lines)"
