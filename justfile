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

# Make a fixup commit for already-staged changes. Picks fixup target
# interactively via fzf from the last 50 commits on this branch.
#
# Pick a commit ON YOUR FEATURE BRANCH (typically the first commit of
# this sub-goal). Picking a commit from main works syntactically but
# `just squash` will then fail because main's commit can't be both
# the rebase base and the autosquash target.
#
# Workflow: edit jeff-emacs-config.org -> just verify-tangle ->
# git add (org + init.el) -> just fixup. The recipe deliberately
# doesn't stage on your behalf.
#
# It does bail if jeff-emacs-config.org is staged but init.el is
# not — staged drift between the two would otherwise produce a
# squashed final commit whose org changes don't match init.el.
fixup:
    @if git diff --cached --name-only | grep -q '^jeff-emacs-config.org$' && \
        ! git diff --cached --name-only | grep -q '^init.el$'; then \
       echo "ERROR: jeff-emacs-config.org is staged but init.el is not."; \
       echo "Run 'just verify-tangle' to regenerate init.el, then 'git add init.el', then retry."; \
       exit 1; \
     fi; \
     target=$(git log -n 50 --pretty=format:'%h %s' --no-merges | fzf --prompt='fixup target: ' | cut -c -7) && \
     git commit --fixup="$target"

# Squash all fixup commits in this branch via autosquash rebase
# against main. Run at sub-goal close, then push (with
# --force-with-lease, since the rebase rewrites history).
squash:
    git rebase --interactive --autosquash main

# List unsquashed fixup commits ahead of main. Empty output means
# the branch is clean and ready to push without squashing.
fixups-pending:
    @git log --oneline main..HEAD | grep ' fixup!' || echo "(no pending fixups)"

# Dump a specific Info node to info-node.txt for attachment to a session.
# Use after consulting info-dir.txt to find the right node.
# Usage: just info-node "(magit) Worktree"
# Output: info-node.txt (overwritten each call).
info-node node:
    @emacs --batch \
           --eval '(package-initialize)' \
           --eval '(let ((out (expand-file-name "info-node.txt"))) (condition-case err (progn (info "{{node}}") (write-region (point-min) (point-max) out)) (error (princ (format "ERROR: %S\n" err)) (kill-emacs 1))))'
    @echo "info-node: wrote info-node.txt ($(wc -l < info-node.txt) lines)"
