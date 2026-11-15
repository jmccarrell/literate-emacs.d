I want the capability to open a shell in the directory of an existing emacs buffer.

I'm sure the capability exists, but I don't know what the current modern configurations do for this mechanism.

Research best practices and present me with a plan.

## Outcome

Implemented Stage 1 in `literate-emacs.d/main` as `add eshell toggle from buffer`.

- `C-x C-z` toggles Eshell.
- `C-u C-x C-z` toggles Eshell and changes it to the current buffer's directory.
- The Stage 1 implementation also hardened Eshell for daily use with a compact native prompt and core Eshell commands for existing shell muscle memory (`ll`, `la`, `lt`, `lsd`, `path`, and `path -l`).

Deferred follow-on stages:

- Stage 2, Eshell editing-key rebinding, is permanently deferred. It changes in-Eshell editing muscle memory more than desired.
- Stage 3, Eshell history isearch, is wait-and-see. The current Eshell binding for `C-s` is `consult-line`, and taking over `C-s` for Eshell history search would remove the only currently working `consult-line` keybinding inside Eshell.
