# 012 — Pivot gptel to a capable cloud coding model (Groq)

Specs 003, 006, and 007 took the AI/LLM work toward **local** models: an
Ollama-backed Qwen MLX default and a Gemma 4 fallback, sized for this MacBook.
I've changed direction. I don't want local AI or Ollama. What I want from the
gptel interface is a **very capable model that Emacs can talk to to help me write
code** — favoring capability and a clean cloud setup over running a model on this
laptop.

The provider is **Groq** (the fast-inference cloud — the same provider I already
use successfully for Whisper transcription; not xAI's "Grok"). gptel reaches it
through Groq's OpenAI-compatible API via `gptel-make-openai`.

## Goal

- gptel's default backend is **Groq**, with `openai/gpt-oss-120b` as the default
  coding model and `qwen/qwen3.6-27b` as a selectable lighter alternate. (Groq
  has deprecated the Llama / older Qwen models; target gpt-oss.)
- **Anthropic Claude** stays as a selectable cloud backend.
- The two **local Ollama backends are removed entirely** from the config.

## Machine constraint

I can only reach Groq and Anthropic from my **personal machine**, not my work
machine. Both cloud backends must be wired only when `jwm/personal-mac-p` is true
(Mac *and* `~/jdocs` present). On the work machine the config must still tangle
and load cleanly; gptel simply has no cloud backend configured there.

## Key handling

Use a **dedicated Groq API key** for this gptel use case so usage and billing are
tracked separately. Stored in auth-source under host `api.groq.com`. Creating the
key is a manual step on my side.

## Supersedes

This supersedes the local-model direction of specs **006** (Gemma4 runs locally)
and **007** (prefer Apple MLX models). Those specs stay as history; the local
backends they motivated are being retired.

## Execution

Capture the implementation as GitHub issues on `jmccarrell/literate-emacs.d`,
driven by the repo's agent issue workflow (`docs/workflow/agent-workflow.md`):
each issue carries an execution spec in its body and waits at `agent:ready` for my
approval before any code is written.

Refactor the existing LLM docs to match this direction as part of the work:
the gptel block in `jeff-emacs-config.org`, the AI section of
`emacs-cheat-sheet.org`, and the AI/LLM sections of `emacs-2026-landscape.org`.
