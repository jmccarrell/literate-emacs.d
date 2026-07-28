# TASK: migrate from projectile to built-in project.el

**Why:** [literate-emacs.d#25](https://github.com/jmccarrell/literate-emacs.d/issues/25).
The 2026-07 projectile MELPA snapshot removed `projectile-global-mode`,
breaking startup. Jeff's actual projectile surface (switch project, command
map, zombie cleanup) is fully covered by Emacs 30's built-in project.el.

## Goal

Remove projectile entirely; rely on project.el on the standard `C-x p`
prefix. Decisions: built-in bindings only (no `C-c p` / `s-p` re-binds);
known-project list grows organically (no bulk seeding); search stays
`consult-ripgrep`.

## Changes

- `jeff-emacs-config.org`: `use-package projectile` → minimal
  `use-package project` (`:ensure nil`, `project-forget-zombie-projects`
  at startup); projectile dropped from `jwm/required-packages`; inline
  prose/comments updated (which-key, worktree section, consult rg note).
- `emacs-cheat-sheet.org`: project.el tables replace projectile ones;
  counsel-projectile section and top-level Projectile bindings section
  deleted.
- `emacs-2026-landscape.org`: table row → Shipped; new Shipped bullet;
  Future bullet removed.
- `init.el`: retangled.

## Verification

- [ ] `just verify-tangle` exits clean.
- [ ] `grep -i projectile init.el` → no matches.
- [ ] Fresh Emacs: no use-package/void-function error at startup.
- [ ] `C-x p f` finds files in this repo; after visiting a second repo,
      `C-x p p` offers both.
- [ ] `C-h v project--list` shows no dead paths after a restart.

## Jeff-side commands (after merge)

Delete the installed package and refresh the Info snapshot:

```sh
rm -rf ~/.emacs.d/elpa/projectile-*
cd /Users/jeff/jwm/proj/emacs-config/literate-emacs.d
just info-dir-update
git add info-dir.txt && git commit -m "info-dir: refresh after projectile removal"
```

(Or from Emacs: `M-x package-delete RET projectile RET`.)

Remove this TASK.md before merging the branch.
