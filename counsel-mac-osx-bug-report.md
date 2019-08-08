# Summary

It appears to me that the `counsel` functions that invoke external processes do not reliably report the
results of those process invocations on Mac OS X. This behavior is shown on a minimally configured emacs via
`emacs -Q`.  The reproducible sequence does not show the bug behavior on 3 tested ubuntu-based releases of emacs.

# Issues Searching with counsel

I seem to be having issues searching with `counsel`. Specifically, running `counsel-grep` gathers the
inputs, but generates no results: no results buffer. I see the same behavior with other counsel file
searching functions as well.

## Steps to Reproduce

   1. start the emacs under test with no initialization, eg:
      - `emacs -Q`
   2. Load counsel
      - `M-x eval-buffer` on this
      ```
        (require 'package)
        (unless (assoc-default "melpa" package-archives)
          (add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t))
        (package-initialize)
        (package-refresh-contents)

        (unless (package-installed-p 'counsel)
          (package-install 'counsel))

        (require 'counsel)
        (ivy-mode)

        (find-library "counsel")
     ```
   3. Do a search
      - `M-x counsel-grep`
      - NB that counsel is working; see how `M-x` runs `counsel-M-x`
      - search for `counsel` which should result in many matches in the file `counsel.el`
   4. Expected vs Actual Results
      - I expect to see a result buffer full of matches
      - The results I actually see are essentially nothing; no search appears to be performed, no results buffer appears.

## Versions of Emacs Tested

### Shows the bug

   1. [Emacs for Mac OS X](https://emacsformacosx.com/) running as a Cocoa window
      - version
        - `GNU Emacs 26.1 (build 1, x86_64-apple-darwin14.5.0, NS appkit-1348.17 Version 10.10.5 (Build 14F2511)) of 2018-05-30`
      - invoked as
        - `/Applications/Emacs.app/Contents/MacOS/Emacs -Q`
   2. homebrew installed emacs running in the terminal
      - version
        - `GNU Emacs 26.2 (build 1, x86_64-apple-darwin18.5.0) of 2019-04-13`
      - invoked as
        - `/usr/local/Cellar/emacs/26.2/bin/emacs-26.2 -Q`

### Works as Expected

- ubuntu 16.04 LTS

```
GNU Emacs 24.5.1 (x86_64-pc-linux-gnu, GTK+ Version 3.18.9) of 2017-09-20 on lcy01-07, modified by Debian
```

- ubuntu 18.04 LTS

```
jmccarrell@jeff-test-1:~$ emacs --version
GNU Emacs 25.2.2
```

- ubuntu 19.04

```
jmccarrell@jeff-test-2:~$ emacs --version
GNU Emacs 26.1
```

