While working on spec 003 and 006, it was suggested in some AI chat workflow or other that a more useful connection
between AI running in an external process and emacs itself could be established.
The ability to query live emacs state, such as keymaps, loaded packages, etc. would shorten the cycle that now uses emacs in batch mode.

The goal of this spec is to explore that space.

Areas to research:
- What have other emacs devotees in our reference repos done in this regard, if anything.
- Is the concept of an MCP server relevant and applicable to this use case?
- Given the gptel interface, could we connect AI running locally or in the cloud through some other emacs layer plumbing?

## Outcome

Done; no resident agent inside Emacs is needed. Decided in "Choose whether
gptel gets tools: settle #41 against #20" (#50), which closed the resident map
#17 and its tickets #20 and #21.

- An outside agent queries live Emacs through the `live-emacs` MCP server
  (`elisp_eval` plus read-only introspection tools, PR #34), served over
  `emacsclient`. The tracer run showed Claude Code doing the whole job this way,
  with no gptel agent involved (#21).
- Claude Code sessions inside Emacs reach it through claude-code-ide's Emacs
  tools and `executeCode` (spec 017).
- gptel stays a client for short requests, with general tools chosen per
  request (#50).
