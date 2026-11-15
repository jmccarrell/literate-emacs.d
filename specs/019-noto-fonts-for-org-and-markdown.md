# 019 — Noto fonts for org and markdown buffers

My org buffers use a proportional font since `literate-emacs.d` #80, and the
font I chose, Helvetica Neue, has no glyph for org-modern's level-3 heading
marker. I want to try the Noto Sans family to improve how org and markdown
buffers look, choosing among the patterns the reference configs actually use
rather than new configuration.

## Ask

1. Find how the Noto fonts behave in Emacs on macOS, and install the
   candidates on both Macs.
2. Find the patterns the reference configs use for proportional prose, as
   whole bundles, and compare `mixed-pitch` against `variable-pitch-mode`.
3. Compare the patterns with Noto Sans, Noto Serif and the current Helvetica
   Neue on real org and markdown files, and pick a winner.
4. List the config changes that winner needs, each sized to its own
   `literate-emacs.d` worktree and pull request.

## Scope

Planning only: the outcome is the list below, not configuration in
`literate-emacs.d`. Org and markdown buffers only; the frame's default font,
other modes, and heading sizes stay as they are.

## Outcome

Decided on the wayfinder map #62; each item names the `jmccarrell/emacs-config`
ticket that holds the detail. The evidence is in the map's research tickets
(#63, #64, #65, #71). The winner is **mixed-pitch on zenburn with Noto Sans**
(#69).

Done: Noto Sans, Noto Sans Mono, Noto Serif and Noto Sans Symbols 2 are in the
shared Brewfile (`jmccarrell/jwm-bin` #47, #48), and daily installs casks on
both Macs (`jmccarrell/jwm-dotfiles-2024` #94).

### Build order

Each item is one `literate-emacs.d` worktree and pull request. Item 3 is
independent of the others.

1. **Noto Sans as the `variable-pitch` family.** (#69, #63)
   - In Org Prose Display, `variable-pitch` becomes `"Noto Sans"`, guarded by
     `jwm/font-exists-p` as Helvetica Neue is today; `:height 1.1` stays.
   - `fixed-pitch` is unchanged. Under mixed-pitch, code and tables take the
     frame font, so a `fixed-pitch` family would reach only org-modern labels
     and checkboxes.
   - `mixed-pitch-set-height` stays off.
2. **mixed-pitch in markdown buffers, with Doom zen's face list.** (#67, #69,
   #65)
   - `mixed-pitch-mode` on `gfm-mode` buffers as well as org.
   - Add the faces Doom's `zen` module keeps monospace to
     `mixed-pitch-fixed-pitch-faces`: `org-date`, `org-footnote`,
     `org-special-keyword`, `org-property-value`, `org-tag`, `org-todo`,
     `org-done`, `font-lock-comment-face`.
   - The stock list already keeps markdown code, tables, front matter and
     checkboxes monospace. Blockquotes go monospace too. Headings stay
     proportional only while `markdown-header-scaling` is set before
     markdown-mode loads, as the config's `:custom` does today.
   - The cheat sheet's Org Display section covers markdown buffers too.
3. **Pin Noto Sans Symbols 2 for the org-modern glyphs.** (#63)
   - `set-fontset-font` for Geometric Shapes (U+25A0–U+25FF), Miscellaneous
     Symbols (U+2600–U+26FF) and Miscellaneous Symbols and Arrows
     (U+2B00–U+2BFF), so both Macs draw the heading stars, `◦` and the
     checkboxes from the same font. Noto Sans has none of them.
   - A face whose own font has the glyph still draws it: under mixed-pitch,
     org checkboxes come from the frame font.

### Passed on

- oantolin's pattern, `variable-pitch-mode` on `text-mode` with `ef-autumn` and
  `modus-themes-mixed-fonts` (#67, #69): it lost the comparison, and under
  zenburn it leaves org code and tables proportional.
- Protesilaos's fontaine pattern (#64, #67): its presets always set the frame
  font.
- minemacs's mixed-pitch writing mode (#71): obsolete, and the same mechanism
  as the winner.
- Noto Serif, and Helvetica Neue kept as is (#69).
- `mixed-pitch-set-height` (#69).
- Noto Sans Mono as `fixed-pitch` (#69): under mixed-pitch it reaches only
  labels and checkboxes.
- A font-switching command or fontaine for trying fonts live (#67): the
  comparison used a throwaway switcher on branch
  `prototype/noto-font-variants`.
