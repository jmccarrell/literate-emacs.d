---
name: emacs-spec-intake
description: "Receive and frame a spec from `specs/` in literate-emacs.d before any implementation begins. Use this skill whenever a new file appears in `specs/`, when Jeff references a spec by number ('work on 003', 'let's tackle 004'), or when Jeff asks me to act on intent that should have a spec. The skill produces a framing-back chat message — what I understand the ask to be, what I see in the current state, what's ambiguous — before any tracked-file edits or worktree requests. Use even when the spec looks unambiguous; framing is a strong default and the cost of an unnecessary framing message is small. Do NOT use for generic project planning, work outside the Emacs config, or specs that have already been framed and signed off (those are decomposition territory)."
---

# Spec intake for the Emacs config

This skill governs the **first** phase of working on a spec: reading it, locating prior state, recognizing the shape, and framing my understanding back to Jeff before doing anything else.

The strongest signal that intake matters: spec 002 exists. "I don't like the change you made" is what happens when implementation runs ahead of alignment. Intake is the gate that prevents this.

## What intake produces

A chat message with three parts:

1. **What I understand the ask to be.** A one-paragraph paraphrase of the spec's intent in my own words. Not a quote — paraphrasing forces actual understanding.
2. **What I see in the current state.** What's already in the codebase, prior specs, prior implementations that this spec is reacting to or building on. Locating this state up front is what prevents pushback later.
3. **What's ambiguous or open.** The questions I'd want answered before proposing a decomposition. Could be scope, priority, or judgment calls I'd otherwise make alone.

What intake does **not** produce:

- Edits to tracked files
- Worktree requests
- Research write-ups (decomposition's job)
- Sub-goal proposals (decomposition's job)

## Workflow

### Step 0 — Confirm sync state

Before reading the spec, run a read-only sync check. Jeff works across multiple machines (see AGENTS.md § Multi-machine workflow); planning a sub-goal against a stale view of the codebase is worse than 15 seconds of `git fetch`.

```sh
cd /Users/jeff/jwm/proj/literate-emacs.d && git fetch && git status -sb
# plus any active config worktree: git -C ../literate-emacs.d.worktrees/<feature> status -sb
```

Report drift back to Jeff. If it is behind, recommend `git pull --ff-only` before proceeding. **Do not block** — Jeff decides whether to sync first or proceed against current state. The point is to surface drift, not to gate the workflow.

### Step 1 — Read the spec and its context

Read the spec itself. Then read referenced material:

- If the spec cites a prior spec by number ("I don't like the change in 001"), read that spec.
- If the prior spec was partially implemented, locate the implementation: `git log` of the relevant repo, current code state, any TASK.md still around in a worktree.
- If the spec uses pronouns or phrases that assume prior context ("the change you made", "that approach"), find what they refer to before framing.

### Step 2 — Recognize the shape

Read `docs/workflow/spec-shapes.md`. Use the recognition section to identify which shape this spec is — broad exploratory, narrow directive, pushback/redesign, or extension/refinement.

If the spec doesn't cleanly fit any shape, note that. It may be a new shape worth adding to `spec-shapes.md` later.

### Step 3 — Locate prior state per shape

Use the shape's framing-emphasis guidance from `spec-shapes.md` to drive what to look for. As orientation:

- **Broad exploratory** — usually little prior state; this is the start of new work.
- **Narrow directive** — grep the codebase for what the spec names. Often widens the scope.
- **Pushback/redesign** — find what was implemented in response to the parent spec. The diff is the most important thing to surface.
- **Extension/refinement** — find the in-flight plan being extended (chat history, open worktree's TASK.md, prior decomposition).

### Step 4 — Frame back

Default: write the three-part chat message and wait for Jeff's sign-off.

Skip framing only when the spec is genuinely unambiguous: a single-sentence directive with clear scope and no prior state to reconcile. Even then, prefer a one-line "I'll proceed to decomposition unless you'd like me to frame this back first" over silently moving on. The cost of an unnecessary framing message is small; the cost of skipping a needed one is spec 002.

### Step 5 — Wait

Do not move to investigation, decomposition, or worktree creation until Jeff signs off on the framing. Sign-off is usually short ("yes," "go," "looks right") but can include corrections that loop back to step 4.

When Jeff signs off, the next phase is decomposition — covered by `emacs-spec-decompose`.

## What to avoid

- **Implementing during intake.** No code changes, no `git add`, no worktree requests.
- **Skipping prior-state location.** This is what causes spec 002. If a spec references prior work, find it before framing.
- **Restating the spec verbatim.** Quoting back the spec doesn't prove understanding. Paraphrase.
- **Hiding ambiguity.** If something is open, list it. Don't make the judgment call silently.
- **Researching deeply.** Intake is fast — read the spec, find the prior state, frame back. Substantive investigation belongs to decomposition.
