# 013 — Guard the `~/.emacs.d/init.el` symlink with a worktrunk pre-remove hook

*Drafted by Claude at Jeff's request ("spec the pre-remove hook"), unlike specs 001–012
which are Jeff's own briefs. Edit freely — this is a proposal, not a record of intent.*

## The ask

Make the `~/.emacs.d/init.el` symlink check mechanical instead of prose.

Workspace `CLAUDE.md` tells Claude to run `readlink ~/.emacs.d/init.el` before removing a
worktree, and to repoint with `just link` if it aims into the doomed checkout. That is the
last honor-system rule in the worktree flow: worktrunk PR #25 (dotfiles) converted branch
deletion from prose to something `wt remove` enforces, and emacs-config PR #13 confirmed —
by test — that worktrunk does *not* extend that protection to this symlink:

```
✓ Removed feat worktree & branch (same commit as main, _)
resolves? NO — DANGLING
```

No warning. The next Emacs start reads a dangling `init.el`. A `pre-remove` hook closes
the gap: a non-zero exit aborts the removal.

**PR #13 also raised the stakes.** It made a worktree the *default unit of work* rather
than something reserved for larger or parallel changes — every commit-producing change
gets one, and for Claude the preference is absolute. Worktrees are therefore created and
removed far more often than when this check was written, and the check runs on removal.
A guard worth having occasionally is now worth having on a routine path.

## Verified behavior

Tested against worktrunk v0.70.0 in throwaway repos, with a project `.config/wt.toml`
carrying a `pre-remove` hook. All four results are empirical, not from the docs.

| Scenario | Result |
|---|---|
| Symlink points **into** the worktree | `✗ pre-remove command failed: exit status: 1` — worktree **and** branch both survive |
| Symlink points elsewhere | Removal proceeds normally; symlink intact |
| `wt remove --no-hooks` | Gate bypassed, symlink left dangling |
| Unapproved hook, **non-interactive** shell | `✗ Cannot prompt for approval in non-interactive environment` — removal fails |

The last row is the one that shapes the design, and it is not obvious from the docs.

## Design decisions

### 1. The hook lives in `literate-emacs.d/.config/wt.toml`

Only that repo's worktrees can host an `init.el`; workspace (`emacs-config`) worktrees
never do, so they need no hook. Project config is git-tracked, so the guard travels to
Jeff's other machines with a normal `git pull` — matching how `worktree-path` was seeded
through the dotfiles repo rather than configured per machine.

Implementation therefore spans two repos: a PR to `literate-emacs.d` adding the file, and
a follow-up doc edit in `emacs-config`.

### 2. Abort — do not auto-repoint

The hook could just run `just link` from the main checkout and let removal proceed. It
should not. `CLAUDE.md` § Global Emacs state disclosure makes `just link` a *disclosed*
action: Claude may run it, but must state target and rollback in the same message. A hook
firing it silently during teardown is exactly the unannounced global-state change that
section exists to prevent. Aborting keeps the human decision where it already is, and
matches the "hard gate … do not fall back" treatment worktree creation gets.

### 3. Jeff pre-approves once per machine; Claude does **not** pass `-y`

Worktrunk requires approval before running project-config commands. Two ways to satisfy it:

- `wt config approvals add` — Jeff approves once, interactively, stored in `approvals.toml`.
- `wt remove -y` — skips the approval prompt entirely.

**Choose the first, and forbid the second for this purpose.** `-y` means any command in a
tracked `.config/wt.toml` executes unreviewed — including one that arrived via `git pull`
from a branch nobody read closely. Since Claude's Bash runs non-interactive, an
unapproved or *changed* hook then fails loudly rather than executing silently: the
approval requirement becomes a review checkpoint instead of an obstacle.

Cost: `approvals.toml` is per-machine state that does not travel with the repo. It joins
the existing per-machine list in `CLAUDE.md` § Multi-machine workflow, alongside the
symlink target itself.

**Consequence for the documented command.** PR #13 made `wt remove <feature> --foreground`
canonical in § Feature worktrees. Combined with this decision, the *first* `wt remove` on
any machine fails — not on the symlink, but on approval:

```
✗ Cannot prompt for approval in non-interactive environment
↳ To skip prompts in CI/CD, add --yes; to pre-approve commands, run wt config approvals add
```

That is the design working, but it reads like a broken hook if undocumented. So the
one-time `wt config approvals add` becomes an explicit **setup step** in § Multi-machine
workflow, not something discovered by hitting the failure. Note the error advertises
`--yes`; per this decision Claude does not take that route, and reports the missing
approval to Jeff instead.

### 4. `--no-hooks` goes on Claude's never-list

It bypasses the gate — verified above. This is the same rule as "if the next required step
is on the never-list and Jeff is unavailable: stop and ask; never work around it." Worth
naming explicitly, because the failure message helpfully advertises the flag:
`↳ To skip pre-remove hooks, re-run with --no-hooks`.

## Sketch

```toml
# literate-emacs.d/.config/wt.toml
pre-remove = """
test "$(readlink ~/.emacs.d/init.el)" != "{{ worktree_path }}/init.el" || {
  echo "ABORT: ~/.emacs.d/init.el points into this worktree."
  echo "Repoint first:  cd {{ repo_path }} && just link"
  exit 1
}
"""
```

Unresolved in the sketch, to settle during implementation:

- **Path-form robustness.** The comparison assumes `{{ worktree_path }}` and `readlink`
  agree on absolute-path form. It held in testing, but should be checked against a real
  `literate-emacs.d.worktrees/<feature>` path, and hardened (compare resolved dirnames)
  if it does not.
- **Symlink absent entirely** (cold machine, no `~/.emacs.d/init.el`): `readlink` yields
  empty, the comparison passes, removal proceeds. Believed correct; confirm.
- **Whether the message should name `just link`'s disclosure requirement**, or trust
  `CLAUDE.md` to carry it.
- **`pre-switch` is deliberately *not* hooked.** `wt switch` between worktrees changes
  which checkout you are standing in but leaves `~/.emacs.d/init.el` pointing wherever it
  pointed — nothing dangles, so there is nothing to guard. The mismatch it can produce
  (working in one worktree while another is live in Emacs) is real but intentional; Jeff
  repoints with `just link` when he wants the live config to follow. Recording the
  decision so it is not rediscovered as an omission.

## Verification plan

1. Real worktree in `literate-emacs.d.worktrees/`, symlink repointed at it via `just link`
   → `wt remove` aborts; worktree, branch, and symlink all intact.
2. `just link` back to the main checkout → `wt remove` succeeds; symlink still resolves.
3. Fresh clone, hook unapproved, non-interactive → removal fails with the approval error
   rather than running the hook.
4. `wt config approvals add`, then repeat 1 and 2 → same outcomes without `-y`.
5. Exactly the command § Feature worktrees documents — `wt remove <feature> --foreground`,
   no `-y` — since that is what Claude will actually run.
6. Existing `rust-cargo-compile-command` worktree untouched throughout.

## Doc updates this implies

Targets below are named against `CLAUDE.md` **as merged in PR #13**, which rewrote this
area after the first draft of this spec.

- `emacs-config/CLAUDE.md` § Feature worktrees — the paragraph beginning "This check is
  **not** obviated by worktrunk" is exactly what the hook inverts. It currently tells the
  reader the tool cannot help and the check is manual; it becomes "the hook enforces this,"
  followed by what the abort looks like and what to do about it. The `readlink` code block
  above it stays — it is still how you check *before* running removal, and it is what Jeff
  runs by hand when he is not going through `wt`.
- Same file § Multi-machine workflow — add two entries to the per-machine list:
  `approvals.toml`, and the one-time `wt config approvals add` setup step. The list already
  leads with the `~/.emacs.d/init.el` symlink target, so the guard and the thing it guards
  end up documented together.
- Same file § Feature worktrees, the `wt remove <feature> --foreground` snippet — add a
  comment that removal aborts if the symlink points into the worktree.
- `~/.claude/CLAUDE.md` § Git authority — add `--no-hooks` to the never-list, since the
  reasoning is general rather than emacs-specific.
- **No change to `skills/emacs-spec-decompose/SKILL.md`.** Its `~/.emacs.d/init.el` mention
  covers repointing when a sub-goal *creates* a worktree; the skill has no removal
  guidance, so the hook does not touch it. Stated here so review need not re-derive it.

## Out of scope

Other hook points (`post-switch` running `just tangle`, `pre-commit` running
`just verify-tangle`) are plausible but independent. This spec covers the one hazard that
is currently unguarded.
