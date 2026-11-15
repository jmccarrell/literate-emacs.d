I don't like the change you made in plan-reference-repos.md.
It discards the very signal we are wanting to track: the changes our reference authors are making to their emacs configurations.

I propose a new approach:

- track the last commit of each reference repo

- the justfile workflow gets split into 3 operations:
  1. update the inventory from the current state in the file system
     - should track the last commit of existing repos
  2. for each repo:
     2.1. detect changes from a fresh pull vs the last time we analyzed
     2.2. consume those changes to inform updates to /Users/jeff/jwm/proj/emacs-config/reference-configs.md
  3. Treat the inventory as the source of truth, produce the git commands for me to execute to either:
     3.1 clone if needed
     3.2 git pull to update if needed

- if the information in the inventory file: /Users/jeff/jwm/proj/emacs-config/reference-repos.list is getting too hard to parse, consider a sqlite DB
  1. present me with a value proposition or pros and cons of moving to sqlite at this time.
  2. is it worth it?
