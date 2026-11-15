# Git worktrees in the current Emacs setup

**Question.** What support already exists in Jeff's config and reference
configs, and what would make the `<repo>.worktrees/` convention faster to use
from Emacs?

**Scope.** This is a local-first snapshot of the active literate config,
installed package sources, and the cached reference configurations.  It does
not change Emacs configuration.

## Current configuration

The configuration already has three useful layers, but they are not joined
into a worktree-specific workflow:

1. **Magit is installed and available at `C-x g`.**  The configuration only
   binds `magit-status`; it adds no worktree policy of its own
   ([`jeff-emacs-config.org`](../literate-emacs.d/jeff-emacs-config.org#L1248-L1260)).
   Installed Magit includes the `magit-worktree` transient: create a worktree
   from an existing branch, create a branch and worktree, move, delete, and
   visit another worktree ([`magit-worktree.el`](file:///Users/jeff.mccarrell/.emacs.d/elpa/magit-20251215.2222/magit-worktree.el#L128-L141)).
   It opens a newly created or selected worktree directly in Magit status
   ([same source](file:///Users/jeff.mccarrell/.emacs.d/elpa/magit-20251215.2222/magit-worktree.el#L143-L172)).

2. **Projectile provides project switching.**  `C-c p p` (and `s-p`) invokes
   `projectile-switch-project`; global Projectile records project roots and
   removes stale paths once per session
   ([`jeff-emacs-config.org`](../literate-emacs.d/jeff-emacs-config.org#L955-L981)).
   Each Git worktree has its own `.git` file and is therefore a distinct
   Projectile project.  This is effective after a worktree has been visited,
   but it is a flat list rather than a repo-to-worktree browser.

3. **Dired and Consult cover file/buffer navigation.**  `C-x C-j` jumps from
   a file to Dired; Dired has `dired-dwim-target` enabled
   ([`jeff-emacs-config.org`](../literate-emacs.d/jeff-emacs-config.org#L914-L951)).
   `C-x b` is remapped to `consult-buffer`, while Consult exposes
   current-project buffers/files as sources.  That makes the active worktree
   pleasant once selected, but does not discover sibling worktrees
   ([`jeff-emacs-config.org`](../literate-emacs.d/jeff-emacs-config.org#L1148-L1196);
   [`consult.el`](file:///Users/jeff.mccarrell/.emacs.d/elpa/consult-20260421.1105/consult.el#L240-L263)).

The config also has a careful **teardown** workflow.  Before removing a
worktree, `jwm/kill-buffers-under-dir` closes its unmodified file buffers;
after removal, `jwm/kill-buffers-of-missing-files` recovers any stale buffers.
Both deliberately leave modified buffers alone
([`jeff-emacs-config.org`](../literate-emacs.d/jeff-emacs-config.org#L486-L536)).

## Magit's directory policy is the missing connection

In installed Magit, `Z` in a Magit status buffer opens `magit-worktree`.
The transient presents create, move, delete, and visit commands.  For creation,
Magit calls `magit-read-worktree-directory-function`, which defaults to a
*flat sibling* directory policy.  Magit deliberately supports a custom
function and supplies nested and offsite alternatives
([`magit-worktree.el`](file:///Users/jeff.mccarrell/.emacs.d/elpa/magit-20251215.2222/magit-worktree.el#L33-L45),
[`magit-worktree.el`](file:///Users/jeff.mccarrell/.emacs.d/elpa/magit-20251215.2222/magit-worktree.el#L64-L124)).

That hook is exactly the right, narrow seam for the convention:

```
~/code/k8s/                         # primary checkout
~/code/k8s.worktrees/RND-1234-foo/  # branch worktree
```

A small `jwm/magit-read-worktree-directory` reader can derive the primary
repository name from `magit-toplevel`, offer `<repo>.worktrees/` as the base,
and prefill a slash-safe branch name.  It should use `read-directory-name`, so
the final location remains visible and editable before Magit executes Git.

## Reference configurations

Only two active cached references contain directly relevant worktree signals:

- Steve Purcell sets `magit-diff-visit-prefer-worktree` in his Magit setup,
  ensuring that a diff/revision visit lands in the checked-out file rather
  than a blob/revision buffer
  ([`init-git.el`](../reference-emacs-configs/steve-purcell-dotemacs/lisp/init-git.el#L15-L20)).
  This is a small, useful companion setting when each branch is a separate
  worktree.
- Oleh Krehel's Magit customizations bind visits explicitly to
  `magit-diff-visit-worktree-file`, reinforcing the same principle: ordinary
  editing should return to a real working tree
  ([`ora-magit.el`](../reference-emacs-configs/abo-abo-dotemacs/modes/ora-magit.el#L74-L80),
  [`ora-magit.el`](../reference-emacs-configs/abo-abo-dotemacs/modes/ora-magit.el#L315-L320)).

No cached reference implements a `<repo>.worktrees/` catalog or a project
switcher that understands this layout.  Magit's own worktree support is more
complete than any reference-local customization found here.

## Recommended daily workflow

1. In any file of a repository, invoke `C-x g`, then `Z`.
   - `c` creates a branch plus worktree.
   - `b` checks out an existing branch in a worktree.
   - `g` selects and opens an existing registered worktree.
   - `k` removes one.
2. Add the custom directory reader above, so `b` and `c` propose
   `<repo>.worktrees/<branch-slug>` automatically.
3. Use the resulting Magit status buffer as the handoff: `RET` visits files;
   `C-x b` / Consult then filters buffers in the selected worktree; `C-x C-j`
   reaches Dired when file-oriented navigation is better.
4. Before `k` (or external `git worktree remove`), run
   `M-x jwm/kill-buffers-under-dir` against that root.  Use
   `M-x jwm/kill-buffers-of-missing-files` only for an already-removed tree.

## Follow-up implementation slice

Keep this intentionally small and native: configure the Magit directory
reader and `magit-diff-visit-prefer-worktree`, then add a single command that
lists the *registered* worktrees (`git worktree list --porcelain`) for the
current repo and opens the selected one in Magit.  Do not make Projectile
scan `.worktrees` trees: Git's registry is authoritative, avoids stale
directories, and works even if the storage layout changes.

The only decision before implementation is whether creation should make
`<repo>.worktrees/` automatically (`make-directory ... t`) or require the
container directory to already exist.  Automatic creation is the smoother
match for a stable personal convention; it is a local filesystem write, so it
should be explicit in the implementation proposal.
