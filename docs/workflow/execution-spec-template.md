# Execution spec template

The Refinement Agent writes this into the issue body during `agent:refine`, then
moves the issue to `agent:ready`. The completed spec is the contract the Coding
Agent executes against. Keep it concrete: every line should be something an
executor can act on or a reviewer can check.

---

## Spec

**Summary.** One sentence: what this issue makes true when it is done.

**Why / context.** The problem and the forces. Link the driving GitHub issue,
workspace spec, prior PR, package manual, or reference config note.

**Scope.**

- In: the bounded set of changes this issue covers.
- Out: explicitly excluded work, with links to the issue or spec that owns it
  when applicable.

**Affected paths.** The files or directories this will touch:

- `jeff-emacs-config.org`
- `init.el`
- `emacs-cheat-sheet.org`
- `docs/...`

**Implementation steps.** Ordered and concrete enough to execute without
re-deriving the design:

1. ...
2. ...
3. ...

**Acceptance criteria.** Checkboxes a reviewer can tick:

- [ ] ...
- [ ] ...

**Verification commands.** Exact commands and manual checks that must pass.
Paste-able shell commands belong in fenced blocks:

```bash
just verify-tangle
git diff --check
```

For live Emacs checks, prefer keystrokes over command names:

- `C-h f <function>`
- `C-h v <variable>`
- `C-h k <key sequence>`

**Risk / rollback.** What can go wrong and how to back out. For configuration
changes, this is usually reverting the PR and re-tangling. For global Emacs
state outside this repo, include the exact teardown command or file removal
instruction.

**Dependencies.** Blocked by `#NNN`; blocks `#NNN`. Link parent workspace specs
when the issue implements a slice of a broader brief.

---

## Literate config requirements

- `jeff-emacs-config.org` is the source of truth.
- Do not edit `init.el` by hand. Regenerate it from the org file.
- Any commit that changes Emacs Lisp in `jeff-emacs-config.org` must include the
  matching tangled `init.el`.
- Run `just verify-tangle` for behavior changes that touch the literate config.
- Docs-only and workflow-only changes that do not touch `jeff-emacs-config.org`
  or `init.el` do not require `just verify-tangle`; `git diff --check` is enough
  unless the spec adds another verification step.

## Global Emacs state disclosure

Anything under `~/.emacs.d/` or another non-worktree, non-git-managed Emacs path
is Jeff-side state. Before a spec asks an agent or Jeff to create, modify,
remove, install, or regenerate that state, it must name:

- the path,
- the provenance,
- the purpose,
- the teardown path,
- whether the change needs to be replicated on other machines.
