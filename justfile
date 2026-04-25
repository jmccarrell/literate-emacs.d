# Recipes for the literate Emacs config.
#
# Run `just --list` to see all recipes.
# Run `just tangle` after editing jeff-emacs-config.org.
# Run `just verify` to tangle and then load the result in batch
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
# Uses -Q (no user init), then explicitly loads the just-tangled init.el.
# Exits 0 on clean load; non-zero on error.
verify: tangle
    emacs --batch -Q \
          -l init.el \
          --eval '(kill-emacs 0)'
