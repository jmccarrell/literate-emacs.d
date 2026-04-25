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
