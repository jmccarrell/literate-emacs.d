---
name: emacs-spec-decompose
description: "Investigate and decompose a framed spec into independently-verifiable sub-goals before implementation. Use this skill after `emacs-spec-intake` has framed a spec and Jeff has signed off, or when Jeff says 'plan it', 'decompose this', 'OK go ahead', or similar after framing. The skill runs investigations (info-dir, reference configs, web search, codebase grep), proposes a decomposition of sub-goals, and identifies which change the config (org + init.el) and which are doc-only edits. Hand-off downstream is to the worktree + TASK.md workflow documented in AGENTS.md. Do NOT use for the initial framing of a new spec (that's intake), or for sub-goal implementation itself (that's the downstream loop)."
---

# Spec decomposition for the Emacs config

This skill governs the **second** phase of working on a spec: doing the investigation the spec asks for, proposing a decomposition into sub-goals, and handing off to the downstream worktree + TASK.md loop.

This skill assumes the spec has already been framed via `emacs-spec-intake` and Jeff has signed off. If framing has not happened, go back to intake first.

## What decomposition produces

A chat message with three parts:

1. **Findings from investigation.** Brief — bullets or a short paragraph per source. Reference configs that handle similar problems, blog posts or docs that inform the approach, what I found in the codebase via grep.
2. **Proposed sub-goals.** Numbered list. Each sub-goal is a discrete unit of work, independently verifiable, with rough dependencies named. For each: whether it is a **config change** (org + init.el) or a **doc-only edit** (justfile, doc, reference-configs.md).
3. **What I'd start with.** A recommendation on which sub-goal to tackle first. Usually the lowest-risk and quickest-to-verify — gives Jeff a chance to course-correct before bigger changes land.

What decomposition does **not** produce:

- Worktree creation (see AGENTS.md § Feature worktrees)
- TASK.md drafts (downstream of worktree creation)
- Implementation
- More than ~6 sub-goals (if the count climbs higher, the decomposition is too fine-grained or the spec needs to be split)

## Workflow

### Step 1 — Read the shape playbook

Read `docs/workflow/spec-shapes.md` if not already in context. Use the **investigation** and **decomposition emphasis** sections from the matching shape to drive the rest of this workflow.

### Step 2 — Investigate per shape

Right investigation depends on the shape. As orientation (`spec-shapes.md` is the source of truth):

- **Broad exploratory** — substantive research. Cheap-and-local first: `info-dir.txt` for what's documented, `reference-configs.md` for which tracked repos to consult, `just info-node "(MANUAL) NODE"` for specific manuals. Reference configs next. Web search last.
- **Narrow directive** — usually just a thorough grep of the codebase to bound scope. Sometimes a quick reference-config check if the directive touches a package others use.
- **Pushback/redesign** — read the parent spec's implementation in detail (`git log`, current code). Identify the smallest revert that puts the codebase in a state where the new direction can build cleanly.
- **Extension/refinement** — usually no fresh investigation; the in-flight plan already carries the context.

When proposing info-node fetches or reference-config reads, name *which* nodes/repos and *why each one* — discovery should be explicit, not blind.

### Step 3 — Propose sub-goals

Each sub-goal:

- Is independently verifiable. A failure points at one change.
- Names whether it's a **config change** (touches `jeff-emacs-config.org`) or a **doc-only edit** (justfile, `reference-configs.md`, AGENTS.md, etc.).
- Has a one-line goal and a rough sketch of approach.
- Is small enough that a TASK.md for it would fit on a screen.

Order by dependency where possible. Lead with the lowest-risk, fastest-to-verify sub-goal.

If the decomposition exceeds ~6 sub-goals, that's a signal the spec is too broad and should be split — surface that to Jeff rather than proceeding with a bloated plan.

### Step 4 — Recommend a starting point

State which sub-goal I'd start with and why. Usually the lowest-risk first — gives Jeff a checkpoint to confirm direction before committing to bigger changes.

### Step 5 — Hand off downstream

Once Jeff approves the decomposition and picks a sub-goal to start:

- **literate-emacs.d config changes** — every sub-goal gets its own feature worktree, created with `wt switch --create <feature>` from the `literate-emacs.d` checkout (then repoint the `~/.emacs.d/init.el` symlink if the sub-goal changes `init.el`); see AGENTS.md § Feature worktrees. I write the **branch-tracked** TASK.md inside it: its Goal is the sub-goal, its Why links to the spec. During execution, after `just verify-tangle` passes, stage `jeff-emacs-config.org` and `init.el` together and commit — they must always land in the same commit. Remove TASK.md before the branch is merged. Git details live in AGENTS.md § Git workflow.
- **Doc-only edits** — AGENTS.md § Meta-doc edits: a worktree and a PR, same as config changes. The old fast path (direct edits in the main checkout plus a hand-pasted commit) is retired.
- **Investigations that don't change config** — e.g. extending `reference-configs.md` with a new survey. No worktree needed; the result lands as a doc edit.

Decomposition stops at the handoff. Implementation is downstream.

## What to avoid

- **Investigating before intake.** If the spec hasn't been framed and signed off, go back to intake.
- **Over-decomposing narrow specs.** A one-paragraph directive with clear scope often produces one or two sub-goals, not five.
- **Under-decomposing broad specs.** If the result is a single sub-goal that says "implement AI integration," the decomposition didn't happen. Force smaller units.
- **Inventing scope.** If the spec didn't ask for X and X isn't an obvious dependency, don't add X to the sub-goals. Surface it as a question instead.
- **Starting implementation.** Decomposition produces a plan, not code.
