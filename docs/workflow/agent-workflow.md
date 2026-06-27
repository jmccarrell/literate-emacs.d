# Literate Emacs agent workflow

How issues move through `literate-emacs.d`, who owns each step, and how the
GitHub labels drive it. This workflow is intentionally lightweight: the durable
configuration lives in the literate org file, durable local briefs may still
live in the parent workspace's `specs/` directory, and branch-local execution
state lives in `TASK.md`.

## Label axes

An ordinary work issue can carry labels from these axes:

| Axis | Select | Meaning |
| --- | --- | --- |
| `agent:*` | exactly one | workflow state: what happens next and who owns it |
| GitHub type labels | usually one | `bug`, `enhancement`, `documentation`, or `question` |

The default GitHub labels remain the type-ish labels for now. Do not introduce a
custom `type:*` axis until there is enough issue volume to justify it.

## Specs and task files

- GitHub issues are the public backlog/spec surface when an issue exists.
- Workspace `specs/` remain durable local briefs for exploratory or multi-step
  Emacs work that starts outside GitHub.
- `TASK.md` remains branch-local execution context. It should link back to the
  GitHub issue or workspace spec that it implements, and it should be removed
  before the branch is merged.

## State machine

```text
             agent:needs-info <--------------------+
                    ^                              |
                    | missing context              |
                    |                              |
new issue -> agent:triage -> agent:refine -> agent:ready
                 |              |              |
                 | invalid      | spec ready   | Jeff approves
                 v              v              v
              closed       waiting gate    agent:implement
                                                 |
                                                 | execution error
                                                 v
                                           agent:blocked
```

## States, owners, entry and exit

- `agent:triage` - Triage Agent. Validate that the issue is real and in scope,
  choose the appropriate type-ish label, and decide whether it is ready to spec.
  Move to `agent:refine` when clear enough, or `agent:needs-info` when it lacks
  required context.

- `agent:needs-info` - blocked on Jeff. Any agent can move an issue here when it
  cannot proceed without missing context. The issue comment must state exactly
  what is missing. When Jeff answers, move it back to the state that can use the
  new information, usually `agent:refine`.

- `agent:refine` - Refinement Agent. Write an execution spec into the issue body
  using `docs/workflow/execution-spec-template.md`. For small documentation-only
  issues, the spec can be correspondingly small, but it still needs scope,
  acceptance criteria, and verification.

- `agent:ready` - waiting for Jeff. The spec is complete and ready for approval.
  Nothing gets implemented merely because a spec exists; approval moves the
  issue to `agent:implement`.

- `agent:implement` - Coding Agent. Implement the approved spec in a branch or
  worktree, open a PR to `main`, and link the PR to the issue. If implementation
  hits a conflict, failing verification, or missing prerequisite, move to
  `agent:blocked` with the concrete blocker.

- `agent:blocked` - blocked during execution. Needs Jeff or a follow-up issue to
  unblock. Move back to `agent:implement` once the blocker is resolved.

## Conventions

- Keep exactly one `agent:*` label on each open ordinary work issue.
- A closed issue carries zero `agent:*` labels. The `agent-label-lifecycle`
  workflow enforces this on close while leaving archival labels like `bug`,
  `enhancement`, `documentation`, and `question` in place.
- The `agent:*` label answers "what happens next?" A closed issue has no next
  action, so there is no `agent:done` label.
- The implementation agent must preserve the literate invariant: Emacs Lisp
  changes go in `jeff-emacs-config.org`, and the matching tangled `init.el` is
  committed with it.
