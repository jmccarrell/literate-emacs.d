# Literate Emacs configuration

Jeff's Emacs configuration, written in literate style. The org file is the source of
truth; `init.el` is generated from it by org-babel tangle. This repo also holds the
specs that drive changes, research notes, and the tooling for the reference configs
(other people's Emacs configs) that investigations are grounded in.

The checkout lives at `~/jwm/proj/literate-emacs.d` (origin
`git@github.com:jmccarrell/literate-emacs.d.git`), with feature worktrees beside it in
`~/jwm/proj/literate-emacs.d.worktrees/<feature>/`.

## Key files

- `jeff-emacs-config.org`: the literate config, the source of truth.
- `init.el`: **generated**, tangled from the org file
  (`#+PROPERTY: header-args:emacs-lisp :tangle "init.el"`).
- `emacs-cheat-sheet.org`: reference cheat sheet.
- `emacs-2026-landscape.org`: the roadmap.
- `README.org`: symlink to `jeff-emacs-config.org`.
- `info-dir.txt`: snapshot of every Info manual visible to Jeff's Emacs.
- `CONTEXT.md`: the glossary for this repo's work.
- `specs/`: numbered briefs from Jeff. `docs/workflow/spec-shapes.md` catalogs their shapes.
- `research/`: research notes.
- `reference-configs.md`, `reference-repos.list`, `reference.just`: the reference configs
  (see § Reference configs).
- `.claude/skills/`: `emacs-spec-intake` and `emacs-spec-decompose`.

## init.el is generated

Do not edit `init.el` directly. All Emacs Lisp changes go in `jeff-emacs-config.org`
inside `#+BEGIN_SRC emacs-lisp` blocks, then get tangled.

## Conventions

- Emacs Lisp functions and variables use the `jwm/` prefix.
- Packages are managed with `use-package`.
- Commit messages: lowercase, short imperative phrases ("add yaml mode", "adjust font size").

## Git workflow: org and init.el commit together

`jeff-emacs-config.org` and `init.el` must always commit together, so the tracked
`init.el` matches the org it was tangled from. A commit whose org changes don't match its
tangled `init.el` is the main hazard of a literate config.

1. Edit `jeff-emacs-config.org`.
2. `just verify-tangle`: regenerates `init.el` and load-checks it in batch `-Q`. Don't
   commit until it passes.
3. `git add jeff-emacs-config.org init.el`, plus any other files that belong in the commit.
4. `git commit`.

## Tangling and verifying

The `justfile` (in the main checkout and every worktree) tangles and load-checks from the
shell. Use it instead of `M-x org-babel-tangle` when scripting, or when a quick syntax check
is more useful than starting Emacs.

```sh
just --list
just tangle          # regenerate init.el from jeff-emacs-config.org
just verify-tangle   # tangle, then load init.el in batch -Q to catch errors
```

`just tangle` is byte-identical to interactive `M-x org-babel-tangle`. In a TASK.md's
tangle steps, give `just tangle` as the primary path and `M-x org-babel-tangle` as the
alternate.

## Specs and TASK.md

Numbered files in `specs/` capture Jeff's intent before implementation: what to do, why,
and sometimes corrections to an earlier proposal. They are tracked and persist as history.
Specs come in recognizable shapes (broad exploratory, narrow directive, pushback,
extension); read `docs/workflow/spec-shapes.md` when handed one.

Specs are upstream of TASK.md. A spec is the ask: it sets scope and stays. A `TASK.md` is
the plan of record for one branch implementing one slice of a spec: its Goal restates one
sub-goal, and its Why links back to `specs/NNN-….md`. One broad spec can produce several
TASK.md files across several branches.

`TASK.md` is tracked on the feature branch and removed before the branch is merged, so it
never reaches `main`. If a branch or worktree has a `TASK.md`, read it before any work there.
Before starting work, look in `specs/` for a relevant spec. If multi-step work has none, say
so: it may be worth writing one first.

## GitHub issue workflow

When work starts from a GitHub issue, honor its `agent:*` label as the workflow state. The
state machine and execution spec template are in `docs/workflow/agent-workflow.md` and
`docs/workflow/execution-spec-template.md`. Link a branch's `TASK.md` back to the issue or
spec it implements.

## Feature worktrees

Every edit lands in a worktree and a PR, docs and `.gitignore` included: main checkouts are
read-only for agents. Worktree operations go through worktrunk (`wt`); see
`~/.claude/CLAUDE.md` § Worktrunk, and § Git authority for what agents may run.

```sh
cd ~/jwm/proj/literate-emacs.d
wt switch --create <feature>         # creates ../literate-emacs.d.worktrees/<feature>
wt remove <feature> --foreground     # after killing its buffers
wt list
```

Prefer `--foreground` on removal in scripted or agent use: `wt remove` otherwise returns
before removal finishes, and the symlink follow-up below depends on it being complete.

### Before removing a worktree

`readlink ~/.emacs.d/init.el` must not point into the worktree being removed. If it does,
repoint it first with `just link` from the main checkout, so the symlink never dangles.

A `pre-remove` hook in `.config/wt.toml` enforces this (`specs/013-…`): a non-zero exit
aborts the removal with worktree and branch intact. Do what its message says and retry;
never use `--no-hooks`. The hook guards only branches that carry `.config/wt.toml`, so run
the `readlink` check anyway.

The first `wt remove` on a machine fails with `Cannot prompt for approval in
non-interactive environment`. That is worktrunk's approval gate for the project hook, not a
broken hook. Jeff approves it once per machine with `wt config approvals add`; never pass
`--yes`, since the approval is the review of a command that may have arrived by `git pull`.

### The ~/.emacs.d/init.el symlink

`~/.emacs.d/init.el` is a symlink, by default to this checkout's `init.el`. To test a
worktree live without merging, run `just link` from it; a fresh Emacs then loads that
worktree's `init.el`. Run `just link` from the main checkout to point back, before removing
the worktree. The worktree's `init.el` starts identical to its branch point, so tangle there
before restarting Emacs.

Agents may run `just link` themselves, provided the same message states the new target and
the rollback command.

### Before implementing a sub-goal

In the message that starts implementation:

1. Create the worktree (`wt switch --create <feature>`) and say so. No implementation edits
   happen in the main checkout. If creation fails, stop and report.
2. If the change should be testable live, run `just link` from the worktree with disclosure
   (target and rollback); otherwise leave the symlink alone and say so.
3. If the sub-goal adds packages, note that `M-x package-refresh-contents` is expected before
   tangling.

### Meta-doc edits

Documentation-only edits (landscape, cheat sheet, this file) follow the same flow: worktree
plus PR. Small doc tweaks may ride on a related open branch, and cheat-sheet edits coupled to
a config block commit with that change.

## Global Emacs state

Disclose non-routine changes to global Emacs state before making them. Anything under
`~/.emacs.d/` or another Emacs location outside a worktree and outside git is Jeff's state.
Routine package installs from archives already configured in the config need no extra
reporting.

For files outside the worktree, tell provenance apart first. Package-provided files from
packages Jeff uses are fine. Agent-authored files, ad hoc shell output, symlink changes,
generated caches, installs from arbitrary URLs, `package-vc`, git checkouts and
unconfigured archives need disclosure before running: the path, provenance, purpose,
teardown, and what replicating it on Jeff's other machines takes. Read these locations
freely, but don't create, change, remove or regenerate non-routine global artifacts without
Jeff's approval of that specific write in chat; prefer tracked source, or a documented
command for Jeff to run. `just link` is the standing exception, with disclosure.

## Multi-machine workflow

Jeff works on this config on more than one machine. Sync by fetching and pulling normally.
At the start of planning or implementation, run the read-only check and report drift; Jeff
runs any pull himself.

```sh
cd ~/jwm/proj/literate-emacs.d && git fetch && git status -sb
# plus any active worktree: git -C ../literate-emacs.d.worktrees/<feature> status -sb
```

Per-machine state that doesn't travel: the `~/.emacs.d/init.el` symlink target, worktrunk's
hook approval, and the `reference-emacs-configs/` cache.

## Info-node grounding

Any investigation that may touch Emacs or package docs starts by reading `info-dir.txt`, so
the analysis rests on Jeff's actual install rather than general knowledge. Refresh it after
installing or removing packages:

```sh
just info-dir-update
git add info-dir.txt && git commit -m "info-dir: refresh after package changes"
```

For a specific node, `just info-node "(magit) Worktree"` writes `info-node.txt` in the
checkout (not committed; overwritten each call). `"(MANUAL) Top"` gives a manual's contents.
When proposing node fetches, say which nodes and why each.

## Verification steps

When writing verification steps in a TASK.md or in chat:

- **Match depth to behavior change.** For changes with no expected visible effect (removing
  unused declarations, byte-identical refactors, doc-only edits), `just verify-tangle` alone
  is enough. For changes Jeff would notice (packages, bindings, modes), keep the fuller flow.
- **Prefer keystrokes over typed commands**: `C-h v <var>`, `C-h f <fn>`, `C-h k <keys>`.
- **Isolate preconditions.** Each check is provable by one command with an unambiguous
  failure, or lists what else must hold. When a test depends on the symlink or tangle state,
  add a step-0 check (`readlink ~/.emacs.d/init.el`, or a grep of the checkout's `init.el`).

## Reference configs

`reference-emacs-configs/` (gitignored) is a local cache of other people's Emacs configs,
used as ground truth during investigations. Treat it as read-only: never commit to or modify
those clones.

- `reference-repos.list`: the registry, one line per repo: `name url last-known-sha`. The SHA
  is the upstream commit last analyzed; `-` means none captured yet.
- `reference-configs.md`: the synthesis: what each tracked repo is for, which are active
  references, and what has been taken from each. Roadmap files link to it instead of
  repeating surveys.
- `reference.just` (imported by the `justfile`):
  - `just ref-list`: print the registry.
  - `just ref-add NAME URL`: register a repo, SHA `-`.
  - `just ref-show-plan`: print the `git` commands that align the cache with the registry and
    upstream. Doesn't run them.
  - `just ref-show-changes`: per repo, list upstream commits since its last-known SHA.
  - `just ref-update-inventory`: record each clone's current HEAD in the registry.

Before an investigation, read `reference-configs.md` to pick the relevant repos; if a needed
one isn't tracked, `just ref-add` it, clone it per `ref-show-plan`, run
`ref-update-inventory`, and add a section to `reference-configs.md`. On a new machine, run
`just ref-show-plan`, execute what it prints, then `just ref-update-inventory`.
