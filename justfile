# Recipes for the literate Emacs config.

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

# Install the packages this config expects (the jwm/required-packages manifest).
#
# Because init.el sets use-package-always-ensure nil, loading the config never
# installs anything — so on a fresh machine (e.g. a provisioned VM) run this once
# to populate ~/.emacs.d/elpa, then the first interactive Emacs is package-ready.
# Idempotent: already-installed packages are skipped.
#
# Load init.el inside a condition-case: on a bare box, loading the full config aborts
# partway (e.g. org-babel hard-requires ob-restclient before it's installed). That's
# fine here — the package archives + `jwm/required-packages' are defined near the top,
# before any such failure, which is all `package-install' below needs.
#
# Then WARM THE NATIVE-COMP CACHE: native-compile every installed package now, so the
# first interactive Emacs has nothing left to JIT-compile. Without this, the first
# launch async-compiles ~half the packages, and during that window some deps resolve
# inconsistently — e.g. marginalia's compat-shimmed `seconds-to-string' briefly hits
# the 1-arg native and errors ("wrong-number-of-arguments (1 . 1) 3"). Self-heals on
# the 2nd launch; warming here makes the 1st launch clean too.
install-packages:
    emacs --batch \
          --eval '(condition-case e (load-file "init.el") (error (princ (format "init.el partial load (bootstrap, expected pre-install): %S\n" e))))' \
          --eval '(package-refresh-contents)' \
          --eval '(dolist (p jwm/required-packages) (unless (package-installed-p p) (package-install p)))' \
          --eval '(when (native-comp-available-p) (native-compile-async package-user-dir (quote recursively)) (while (or comp-files-queue (and (fboundp (quote comp-async-runnings)) (> (comp-async-runnings) 0))) (sleep-for 1)))'
    @echo "install-packages: done"

# Point ~/.emacs.d/init.el at THIS checkout's init.el.
#
# Idempotent and imperative: run it from whichever checkout you want
# live, and it repoints the symlink there regardless of prior state.
#   main checkout:      just link   -> ~/.emacs.d/init.el -> main/init.el
#   a feature worktree: just link   -> ~/.emacs.d/init.el -> worktree/init.el
# Revert after a merge by running `just link` again from the main checkout.
# Also covers cold start on a new machine (creates ~/.emacs.d if absent).
emacs-d := join(home_directory(), ".emacs.d")

link:
    mkdir -p {{emacs-d}}
    ln -sfn {{justfile_directory()}}/init.el {{emacs-d}}/init.el
    @echo "linked {{emacs-d}}/init.el -> {{justfile_directory()}}/init.el"

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
