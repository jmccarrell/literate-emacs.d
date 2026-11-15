# Spec shapes

Specs in `specs/` come in a handful of recognizable shapes. The shape determines what to investigate, what to surface in framing, and how to decompose into sub-goals. This file is meant to evolve — when a new spec doesn't cleanly match any existing shape, add a new one here rather than forcing a fit.

Skills that consume this file:

- `emacs-spec-intake` — uses the recognition + framing-emphasis sections
- `emacs-spec-decompose` — uses the investigation + decomposition-emphasis sections

Anyone reading a spec without those skills installed should still read this file — the playbooks are project knowledge, not skill methodology.

## Recognizing the shape

Three quick reads of the spec text:

1. Does it cite or contradict a prior spec? → **pushback** (rejecting prior outcome) or **extension** (building on prior plan).
2. Is the scope a single concrete change with clear edges? → **narrow directive**.
3. Is the scope an area where Jeff wants research before any plan? → **broad exploratory**.

If none fit cleanly, note the mismatch in chat, apply the closest shape, and after implementation edit this file to add the new shape.

---

## Broad exploratory

**Recognize by:** "I want to work on [area]", "this is a big goal", "identify useful smaller sub-goals", "start planning". The spec sets a direction, not a destination.

**Example:** `specs/003-local-ai-in-emacs-1.md` (AI/LLM integration).

**Framing emphasis (intake):** state what I understand the scope to be, name the high-level constraints, list what *kind* of investigation I'd do. Do not propose sub-goals yet — that's decomposition's job.

**Investigation (decomposition):** substantive. Cheap-and-local first: `info-dir.txt` for what's documented locally, `reference-configs.md` for which tracked repos are relevant, then `just info-node "(MANUAL) NODE"` for specific manuals. Reference configs next. Web search last.

**Decomposition emphasis:** 3–6 sub-goals, ordered by dependency, easiest first. Be explicit about which sub-goals are research-only vs. config-changing. Lead with a sub-goal that gives Jeff a quick checkpoint before bigger changes land.

---

## Narrow directive

**Recognize by:** a single concrete action stated in 1–2 sentences. "Remove X." "Add Y." "Change Z to W." No reference to prior specs.

**Example:** `specs/004-remove-local-elpa-mirror.md`.

**Framing emphasis (intake):** confirm scope by grepping the codebase for what the spec names. Surface anything that might widen the scope (related code in justfile, README, dependent packages, doc references).

**Investigation (decomposition):** thorough grep. Sometimes a quick reference-config check if the directive touches a package other configs use.

**Decomposition emphasis:** usually one or two sub-goals. Do not over-decompose — narrow specs do not need ceremony. The hardest part is bounding the change correctly.

---

## Pushback / redesign

**Recognize by:** "I don't like X", "I propose a new approach", explicit reference to a previous spec or implementation outcome being rejected.

**Example:** `specs/002-improve-reference-repo-tracking.md` (rejecting outcomes from spec 001).

**Framing emphasis (intake):** read both the parent spec and what was actually implemented in response to it. State the diff: what to revert, what to keep. Surface where the new direction conflicts with already-merged work — those are the riskiest places.

**Investigation (decomposition):** read the parent spec's implementation in detail (`git log` of relevant repo, current code state). Identify the smallest revert that puts the codebase in a state where the new direction can build cleanly.

**Decomposition emphasis:** typically a mix of "revert/replace X" + "implement new Y" sub-goals. The first sub-goal is often the revert, since the new approach builds on a clean state. Watch for partial reverts that leave dead code paths.

---

## Extension / refinement

**Recognize by:** "I like the direction, however ...", "make the plan be ...", "also do ...". Builds on an in-progress plan rather than starting fresh.

**Example:** `specs/001-plan-reference-repos.md` (adding constraints to a plan already in flight).

**Framing emphasis (intake):** state the in-flight plan, then state the modification. Confirm which parts of the prior plan still stand and which are being changed.

**Investigation (decomposition):** usually none — the in-flight plan already carries context. Thread the extension into existing sub-goals.

**Decomposition emphasis:** sub-goals are deltas to the in-flight plan. Often no fresh worktree needed; the extension lands in whatever worktree was already open.

---

## When no shape fits

1. Note the mismatch in chat.
2. Apply the closest shape, but be explicit about where the spec breaks the pattern.
3. After implementation, edit this file to add the new shape (or refine an existing one).
