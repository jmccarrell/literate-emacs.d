# 016 — Refresh the reference configs

The reference configs in `reference-emacs-configs/` were last refreshed on
2026-04-26. Spec 015 (PostgreSQL development in Emacs) starts with a deep
search of those repos, and I want that search to read current code. Tools such
as mise are recent enough that the checkouts I have may predate any support for
them. This refresh blocks spec 015's research step.

## Outcome

- Every repo in `reference-repos.list` is up to date with its upstream.
- A summary of what changed in each repo since the last refresh is added to
  `reference-configs.md`, and its **Last refreshed** date is updated.
- `reference-repos.list` records each repo's new SHA.

## The summary

For each repo: how many commits arrived, and what changed that matters to my
config: new or dropped packages, changed approaches, and anything touching SQL,
PostgreSQL, databases, language servers, or per-project environments (mise,
direnv). I'm also very interested in using agents in emacs.  We have a nascent
gptel configuration that I expect to deepen over the coming weeks.
Say plainly when a repo had no changes, or no changes that matter.

Also report repos that could not be refreshed (fetch failed, missing locally,
no upstream) and repos that look abandoned, so I can decide whether to keep
tracking them.

## Process

Use the existing tooling, in the order `reference-configs.md` describes:
`just ref-show-changes` for the new commits, `just ref-show-plan` for the pull
commands, then `just ref-update-inventory` once the pulls are done.

## Out of scope

- Adding new reference repos or dropping existing ones. The summary may
  recommend either; I decide separately.
- Any change to my Emacs config.
