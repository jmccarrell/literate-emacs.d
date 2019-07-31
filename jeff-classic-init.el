(defconst emacs-start-time (current-time))

(unless noninteractive
  (message "Loading %s..." load-file-name))

(setq message-log-max 16384)

(require 'package)
(add-to-list 'package-archives
             '("melpa" . "http://melpa.org/packages/") t)
(package-initialize)

;; (unless (package-installed-p 'use-package)
;;   (package-install 'use-package))
;; (setq use-package-verbose t)
;; (setq use-package-always-ensure t)
;; (require 'use-package)
;; (use-package auto-compile
;;   :config (auto-compile-on-load-mode))
;; (setq load-prefer-newer t)

(eval-and-compile
  ;; (mapc #'(lambda (path)
  ;;           (add-to-list 'load-path
  ;;                        (expand-file-name path user-emacs-directory)))
  ;;       '("jwm-elisp" "site-lisp" "override" "lisp" "lisp/use-package" ""))

  (require 'cl)

  (defvar use-package-verbose t)
  (defvar use-package-always-ensure t)
  ;;(defvar use-package-expand-minimally t)
  (require 'use-package))

(require 'bind-key)
(require 'diminish nil t)

;;;
;;; jwm: leave the custom settings in settings.el
;;;  it is good enough for jwiegley
(setq custom-file (expand-file-name "settings.el" user-emacs-directory))
(load custom-file)

;;; Enable disabled commands

(put 'downcase-region             'disabled nil)   ; Let downcasing work
(put 'erase-buffer                'disabled nil)
(put 'eval-expression             'disabled nil)   ; Let ESC-ESC work
(put 'narrow-to-page              'disabled nil)   ; Let narrowing work
(put 'narrow-to-region            'disabled nil)   ; Let narrowing work
(put 'set-goal-column             'disabled nil)
(put 'upcase-region               'disabled nil)   ; Let upcasing work
;; (put 'company-coq-fold            'disabled nil)
;; (put 'TeX-narrow-to-group         'disabled nil)
;; (put 'LaTeX-narrow-to-environment 'disabled nil)

;;; jeffs functions
;;; query functions for the host we are running on
(defun jwm::entelo-host-p ()
  (file-exists-p "/e/src/reputedly"))

(defun jwm::sift-host-p ()
  (file-exists-p (expand-file-name "~/code/java/build.gradle")))

;;; jeffs settings

(when (eq 'darwin system-type)
  ;; mirror the mac user gesture for switching frames
  (bind-key "M-`" 'other-frame)
  ;; prevent my thumb from triggering this menu on the trackpad when in open laptop mode
  ;;  ie, when I am working on the train
  (bind-key [C-down-mouse-1] 'ignore))

;; Answering just 'y' or 'n' will do
(defalias 'yes-or-no-p 'y-or-n-p)

;; get rid of all of the backup files
(setq backup-before-writing nil)
(setq make-backup-files nil)
;; Keep all backup and auto-save files in one directory
;; (setq backup-directory-alist '(("." . "~/.emacs.d/backups")))
;; (setq auto-save-file-name-transforms '((".*" "~/.emacs.d/auto-save-list/" t)))
;; (setq auto-save-list-file-prefix
;;       (expand-file-name "~/tmp/emacs/emacs-saves"))

;; revert buffers automatically when underlying files are changed externally
(global-auto-revert-mode t)

;; prefer utf-8 encoding in all cases.
(setq locale-coding-system 'utf-8)
(set-terminal-coding-system 'utf-8)
(set-keyboard-coding-system 'utf-8)
(set-selection-coding-system 'utf-8)
(prefer-coding-system 'utf-8)

(setq inhibit-startup-message t)
;; needed for emacs23
(setq inhibit-splash-screen t)

;; complete things without hesitation
(setq completion-auto-help nil)
(setq completion-ignore-case t)

;; some global key bindings I happen to like.
(bind-keys
 ("C-x y" . revert-buffer)
 ("C-M-g" . goto-line))

;;
;; org mode
;;
;; org mode wants these default global bindings set up.
(bind-keys
 ("C-c l" . org-store-link)
 ("C-c c" . org-capture)
 ("C-c a" . org-agenda)
 ("C-c b" . org-iswitchb))

;; set up org mode
(setq org-directory
      (cond ((jwm::sift-host-p) "/s/notes/org")
            (t "~/Dropbox/org")))

;; The default place to put notes for capture mode
(setq org-default-notes-file
      (concat org-directory
              (cond ((jwm::sift-host-p) "/sift.org")
                    (t "/todo.org"))))

;; my agenda files
;;  code shamelessly stolen from Sacha Chua's config
(setq org-agenda-files
      (delq nil
            (mapcar (lambda (x) (and (file-exists-p x) x))
                    `("~/Dropbox/org/notes.org",
                      org-default-notes-file))))

;; capture template.
;;  support capture directly to my entelo org file
(setq org-capture-templates
      '(("t" "Todo" entry (file+headline org-default-notes-file "Tasks")
         "* TODO %?\n %t\n  %i\n  %a")
        ("j" "Journal" entry (file+datetree "~/Dropbox/org/journal.org")
         "* %?\nEntered on %U\n  %i\n  %a")))

;; org language support
(org-babel-do-load-languages
 'org-babel-load-languages
 ;; order these by most frequently used
 '((ruby . t)
   (sql . t)
   ;; ob-sh package seems to have disappeared
   ;; (sh . t)
   (python . t)
   (emacs-lisp . t)))

;; my task states
(setq org-todo-keywords
      '((sequence "TODO(t)" "NEXT(n!)" "DOING(g!)" "WAITING(w@/!)" "|" "DONE(d!)" "CANCELLED(c@)" "DEFERRED(D@)")))

;; I prefer 2 levels of headlines for org refile targets
;;  this matches well with my TASKS/PROJECTS high level
;; further, I prefer the refiling to be per-buffer, not across all org-agenda-files
;;  to preserve context.  most often, I use the file as context.
(setq org-refile-targets '((nil . (:maxlevel . 2))))

;; jwm: I don't like org mode for txt files.
;; (add-to-list 'auto-mode-alist '("\\.txt$" . org-mode))

;; follow this pattern from jwiegley
(defun save-org-mode-files ()
  (dolist (buf (buffer-list))
    (with-current-buffer buf
      (when (eq major-mode 'org-mode)
        (if (and (buffer-modified-p) (buffer-file-name))
            (save-buffer))))))

(run-with-idle-timer 25 t 'save-org-mode-files)

;;; no longer needed with kill-visual-line
;; kill the whole line when at the beginning of it
;;(setq kill-whole-line t)

;; use the gnome/X cut buffers for killing and yanking
(setq select-enable-clipboard t)
;; enable visual feedback on selections
(setq-default transient-mark-mode t)

;; always end a file with a newline
(setq require-final-newline t)

;; tab handling
;; prefer spaces to tabs
(setq-default indent-tabs-mode nil)
;; bbatsov recommends this, so try it
;;  http://emacsredux.com/blog/2016/01/31/use-tab-to-indent-or-complete/
(setq tab-always-indent 'complete)

;; try highlight line mode out for size
(hl-line-mode)

;; set a high fill column
(setq-default fill-column 108)

;; blink the cursor 10 times, then stop
(blink-cursor-mode 10)

(setq-default indicate-empty-lines t)

;; Don't count two spaces after a period as the end of a sentence.
;; Just one space is needed.
(setq sentence-end-double-space nil)

;; delete the region when typing, just like as we expect nowadays.
(delete-selection-mode t)

(show-paren-mode t)
(column-number-mode t)

(global-visual-line-mode)
(diminish 'visual-line-mode)

;; turn on which-function mode enough so we can use it for bookmarks
;; following Howard Abrams here.
(setq which-func-unknown "")
(which-function-mode -1)

(setq uniquify-buffer-name-style 'forward)

;; enable the week of the year in calendar.
(setq calendar-week-start-day 1
      calendar-intermonth-text
      '(propertize
        (format "%2d"
                (car
                 (calendar-iso-from-absolute
                  (calendar-absolute-from-gregorian (list month day year)))))
        'font-lock-face 'font-lock-function-name-face))

;; -i gets alias definitions from .bash_profile
;; jwm: but when I turn this on, I get:
;; bash: cannot set terminal process group (-1): Inappropriate ioctl for device
;; bash: no job control in this shell
;; so turn it off
;; (setq shell-command-switch "-ic")

;; Don't beep at me
(setq visible-bell t)

;; prefer xterm-color
;; begin-jwm: xterm-color config as of 20170102.1525
;; xterm-color config from: https://github.com/atomontage/xterm-color
;; comint install
(require 'xterm-color)
(progn (add-hook 'comint-preoutput-filter-functions 'xterm-color-filter)
       (setq comint-output-filter-functions (remove 'ansi-color-process-output comint-output-filter-functions)))

;; comint uninstall
;; (progn (remove-hook 'comint-preoutput-filter-functions 'xterm-color-filter)
;;        (add-to-list 'comint-output-filter-functions 'ansi-color-process-output))

;; For M-x shell, also set TERM accordingly (xterm-256color)

;; You can also use it with eshell (and thus get color output from system ls):

(require 'eshell)

(add-hook 'eshell-mode-hook
          (lambda ()
            (setq xterm-color-preserve-properties t)))

(add-to-list 'eshell-preoutput-filter-functions 'xterm-color-filter)
(setq eshell-output-filter-functions (remove 'eshell-handle-ansi-color eshell-output-filter-functions))

;;  Don't forget to setenv TERM xterm-256color
;; end-jwm: xterm-color config as of 20161104.1949

;;; jeffs colors
(set-face-foreground 'font-lock-builtin-face "Peru")
(set-face-foreground 'font-lock-comment-face "DeepSkyBlue1")
(set-face-foreground 'font-lock-comment-delimiter-face "RoyalBlue2")
(set-face-foreground 'font-lock-constant-face  "DarkGoldenrod1")
;; inherited from font-lock-string-face  (set-face-foreground 'font-lock-doc-face "")
(set-face-foreground 'font-lock-function-name-face "Gold")
(set-face-foreground 'font-lock-keyword-face "Orchid")
(set-face-foreground 'font-lock-preprocessor-face "Tan")
(set-face-foreground 'font-lock-string-face "LightCoral")
(set-face-foreground 'font-lock-type-face "PaleGreen")
(set-face-foreground 'font-lock-variable-name-face "LightSalmon1")
(set-face-foreground 'font-lock-warning-face "Seashell")
(set-face-background 'font-lock-warning-face "Tomato")
;;; end jeffs colors

;;; frame settings under window system
;;; preferences when under a window system, which these days is pretty much os x
(when window-system
  (setq default-frame-alist
        (list '(menu-bar-lines . 1)
              '(tool-bar-lines . 0)
              '(vertical-scroll-bars . nil)
              '(width . 130)
              '(height . 60)
              ;; after many years of setting my own colors
              ;;  evolution happens, so rely on themes.
              ;; ;; '(foreground-color . "white")
              ;; ;; '(foreground-color . "#839496")  ;; foreground from solarized-emacs
              ;; ;; I think the solarized foreground is a little too quiet;
              ;; ;;  it corresponds about to grey-44 in the standard colors in list-colors-display
              ;; ;; so bring it up a notch or two
              ;; '(foreground-color . "grey54")  ;; foreground from solarized-emacs
              ;; ;; '(background-color . "black")
              ;; '(background-color . "#002b36")  ;; background from solarized-emacs
              ;; ;; '(cursor-color . "DarkOrange")
              ;; '(cursor-color . "DarkOrange3")  ;; tone down cursor some with solarized colors
              ))
  ;;; (add-to-list 'default-frame-alist '(font . "lucidasanstypewriter-14"))
  (cond ((and (>= emacs-major-version 23) (eq 'darwin system-type))
         (message "jwm: display height %d" (display-pixel-height))
         (cond ((jwm::entelo-host-p)
                (message "jwm: detected jeff entelo laptop.")
                (add-to-list 'default-frame-alist '(font . "Monaco-12")))
               ((>= (display-pixel-height) 1100)
                (message "jwm: detected jeff personal laptop.")
                (add-to-list 'default-frame-alist '(font . "Monaco-14")))
               (t
                (message "jwm: default font Monaco 12 chosen for monitor size.")
                (add-to-list 'default-frame-alist '(font . "Monaco-12")))
               ))
        ((eq 'gnu/linux system-type)
         (message "jwm: display height %d" (display-pixel-height))
         (cond ((>= (display-pixel-height) 1800)
                (message "jwm: detected high res monitor.")
                (add-to-list 'default-frame-alist '(font . "Ubuntu Mono-16")))
               (t
                (message "jwm: default monitor size chosen.")
                (add-to-list 'default-frame-alist '(font . "Ubuntu Mono-11")))
               ))
        (t
         ;; default to changing nothing
         t)
        )

  ;; these are lifted directly from Howard Abrams
  (defun ha/text-scale-frame-change (fn)
    (let* ((current-font-name (frame-parameter nil 'font))
           (decomposed-font-name (x-decompose-font-name current-font-name))
           (font-size (string-to-int (aref decomposed-font-name 5))))
      (aset decomposed-font-name 5 (int-to-string (funcall fn font-size)))
      (set-frame-font (x-compose-font-name decomposed-font-name))))

  (defun ha/text-scale-frame-increase ()
    (interactive)
    (ha/text-scale-frame-change '1+))

  (defun ha/text-scale-frame-decrease ()
    (interactive)
    (ha/text-scale-frame-change '1-))

  (bind-keys
   ("s-C-+" . ha/text-scale-frame-increase)
   ("A-C-+" . ha/text-scale-frame-increase)
   ("s-C-=" . ha/text-scale-frame-increase)
   ("A-C-=" . ha/text-scale-frame-increase)
   ("s-C--" . ha/text-scale-frame-decrease)
   ("A-C--" . ha/text-scale-frame-decrease))
  )

;;; on OS X, set binding for meta to be command key, next to space bar
;;;  disable meaning of option key, so it is passed into emacs.
;;;  I use these semantics so that, e.g., option-v gives me the square root character.
;;;
;;; I have had this code much higher in this init file; however, I run into eval order
;;;  issues.  When I leave it here late in the sequence, it seems to do what I want.

;;; circa Feb 2017, I want to move away from entering the special characters from the keyboard
;;;  and back toward using the keys at the bottom of the keyboard for meta keys.
;;; so this has to go.
;; (when (and window-system (eq 'ns window-system))
;;   (set-variable (quote mac-option-modifier) 'none))

;;; now invert the bindings of meta and super on the mac
;;;  so that meta is closest to the space bar (command key on the mac keyboard)
;;;          super is to the left of meta     (option/alt key on the mac keyboard)
;;;  and leave right option unbound to insert accented characters.
;;;
;;; possible mac variables to bind
;;      mac-command-modifier
;; mac-control-modifier         mac-function-modifier
;; mac-option-modifier  mac-right-command-modifier
;; mac-right-control-modifier   mac-right-option-modifier
(when (and window-system (eq 'ns window-system))
  (message "setting mac meta/super key bindings")
  (set-variable (quote mac-option-modifier) 'super)
  (set-variable (quote mac-command-modifier) 'meta)
  (set-variable (quote mac-right-option-modifier) 'none))

(defun jwm::prog-mode-hook ()
  (superword-mode t))
(add-hook 'prog-mode-hook #'jwm::prog-mode-hook)

;; more programming mode supplemental functions
(defun jwm::c-comment-region (start end)
  "Comment out a region of C code using /*** and ***/ each on a line."
  (interactive "r")
  (goto-char start)
  (insert "/***\n")
  (goto-char (+ end 5))
  (insert "***/\n")
)

(defun jwm::c-ifdef-region (start end)
  "Comment out a region of C code using #if 0."
  (interactive "r")
  (goto-char start)
  (insert "#if 0\n")
  (goto-char (+ end 6))
  (insert "#endif\n")
)


;;; Configure libraries

;; ag config dervied from danielmai's config
(use-package ag
  :commands ag)

;; a better ace-jump-mode; first derived from jwiegley
;;  then I followed sacha's pattern using key-chord.
(use-package avy
  :bind (("C-c w" . avy-org-refile-as-child))
  :config
  (progn
    ;; use avy across all visible frames
    ;;  https://github.com/abo-abo/avy/blob/master/doc/Changelog.org#allow-all-operations-to-work-across-frames
    (setq avy-all-windows 'all-frames))
  (avy-setup-default))

;; bats-mode
(use-package bats-mode)

;; bookmarks, as Howard Abrams uses them.
;;  minus the C-c b binding
;;  N.B. ha/add-bookmark depends on which-function-mode
(use-package bookmark
  :init (setq bookmark-save-flag 1)
  :config
  (defun ha/add-bookmark (name)
    (interactive
     (list (let* ((filename  (file-name-base (buffer-file-name)))
                  (project   (projectile-project-name))
                  (func-name (which-function))
                  (initial   (format "%s::%s:%s " project filename func-name)))
             (read-string "Bookmark: " initial))))
    (bookmark-set name))
  :bind  (
          ;; ("C-c b m" . ha/add-bookmark)
          ("C-x r m" . ha/add-bookmark)
          ("C-x r b" . helm-bookmarks)))

;; derived from Howard Abrams config.
(use-package company
  :ensure t
  :diminish company-mode
  :init
  (add-hook 'after-init-hook 'global-company-mode)
  :bind ("C-:" . company-complete)  ; In case I don't want to wait
  )

;; try bbatsov's crux
(use-package crux
  ;; jwm: this defadvice throws warnings, so ignore it for now.
  ;; :init
  ;; (progn
  ;;   (crux-with-region-or-buffer crux-cleanup-buffer-or-region)
  ;;   )
  :bind
  (
   ("C-c n" . crux-cleanup-buffer-or-region)
   ;; ("C-S-RET" . crux-smart-open-line-above)
   ("M-o" . crux-smart-open-line)
   ("C-c d" . crux-duplicate-current-line-or-region)
   ("C-c M-d" . crux-duplicate-and-comment-current-line-or-region)
   ("C-c C-r" . crux-rename-file-and-buffer)
   ))

;; try direx from Howard Abrams config
;; The [[https://github.com/m2ym/direx-el][direx]] package is a tree-based variation of dired, and it gives
;; an /ide-like/ look and feel. Not sure of its useful-ness.

(use-package direx
  :ensure t
  ;; :bind (("C-c p X" . ha/projectile-direx)
  ;;        :map direx:direx-mode-map
  ;;        ("q" . kill-buffer-and-window))
  :init
  (defun kill-buffer-and-window (&optional buffer)
    "Kills the buffer and closes the window it is in."
    (interactive)
    (kill-buffer buffer)
    (delete-window))

  (defun ha/projectile-direx (prefix)
    "Start direx in the top-level of a project in a buffer window
          that spans the entire left side of the frame."
    (interactive "P")
    (let ((file-name (file-name-nondirectory (buffer-file-name)))
          (buffer (direx:find-directory-reuse-noselect (projectile-project-root)))
          (window (ha/split-main-window 'left 30)))
      (select-window window)
      (direx:maybe-goto-current-buffer-item buffer)
      (switch-to-buffer buffer)
      (search-forward file-name))))

;; The following helper function creates a window at the top-level,
;; ignoring other windows in the frame.

(defun ha/split-main-window (direction size)
  "Split the main window in the DIRECTION where DIRECTION is a
  symbol with possible values of 'right, 'left, 'above or 'below
  and SIZE is the final size of the windows, if the window is split
  horizontally (i.e. DIRECTION 'below or 'above) SIZE is assumed to
  be the target height otherwise SIZE is assumed to be target width."
  (let* ((new-window (split-window (frame-root-window) nil direction))
         (horizontal (member direction '(right left))))
    (save-excursion
      (select-window new-window)
      (enlarge-window (- size (if horizontal
                                  (window-width)
                                (window-height)))
                      horizontal))
    new-window))


;; elpy; derived from Howard Abrams config
(use-package elpy
  :ensure t
  :commands elpy-enable
  :init (with-eval-after-load 'python (elpy-enable))

  :config
  ;; (electric-indent-local-mode -1)
  (delete 'elpy-module-highlight-indentation elpy-modules)
  (delete 'elpy-module-flymake elpy-modules)
  )

;; a better ruby mode
(use-package enh-ruby-mode
  :init (progn
          ;; prefer 2-space indentation style used at Entelo
          (setq enh-ruby-deep-indent-paren nil)
          (add-to-list 'auto-mode-alist
                       '("\\(?:\\.rb\\|ru\\|rake\\|thor\\|jbuilder\\|gemspec\\|podspec\\|/\\(?:Gem\\|Rake\\|Cap\\|Thor\\|Vagrant\\|Guard\\|Pod\\)file\\)\\'" . enh-ruby-mode))))

;; try expand-region, with Howard Abrams customization of it
;;  this is directly from Howards config
(use-package expand-region
  :ensure t
  :config
  (defun ha/expand-region (lines)
    "Prefix-oriented wrapper around Magnar's `er/expand-region'.

     Call with LINES equal to 1 (given no prefix), it expands the
     region as normal.  When LINES given a positive number, selects
     the current line and number of lines specified.  When LINES is a
     negative number, selects the current line and the previous lines
     specified.  Select the current line if the LINES prefix is zero."
    (interactive "p")
    (cond ((= lines 1)   (er/expand-region 1))
          ((< lines 0)   (ha/expand-previous-line-as-region lines))
          (t             (ha/expand-next-line-as-region (1+ lines)))))

  (defun ha/expand-next-line-as-region (lines)
    (message "lines = %d" lines)
    (beginning-of-line)
    (set-mark (point))
    (end-of-line lines))

  (defun ha/expand-previous-line-as-region (lines)
    (end-of-line)
    (set-mark (point))
    (beginning-of-line (1+ lines)))

  ;; jwm: however, I can't seem to get C-= from my mac keyboard.
  ;;   so prefer C-c =
  :bind ("C-@" . ha/expand-region))

;; this is Howard Abrams flycheck config
(use-package flycheck
  :ensure t
  :init
  (add-hook 'after-init-hook 'global-flycheck-mode)
  :config
  (setq-default flycheck-disabled-checkers '(emacs-lisp-checkdoc)))

;; helm config derived from danielmai's config
;;  I don't use the Hyper key, so change the "H-w" binding to something I can live with.
;;  jwm: I choose M-i
;; the next thing I need to do is add the bindings that support moving between i-search and helm-swoop
(use-package helm
  :diminish helm-mode
  :init (progn
          (require 'helm-config)
          (use-package helm-projectile
            :ensure t
            :commands helm-projectile
            ;; this rebinding from tuhdo's helm- projectile tutorial
            ;;  https://tuhdo.github.io/helm-projectile.html
            ;; however, I don't see the stated benefit of getting the list of
            ;;  projects from helm-projectile.
            ;; so disable this for now.
            ;;  :init (setq projectile-switch-project-action 'helm-projectile)
            ;; :bind ("C-c p h" . helm-projectile)
            )
          (use-package helm-ag :defer 10  :ensure t)
          (setq helm-locate-command "mdfind -interpret -name %s %s"
                helm-ff-newfile-prompt-p nil
                helm-M-x-fuzzy-match t)
          (helm-mode)
          (use-package helm-swoop
            :ensure t
            :bind ("M-i" . helm-swoop))
          )
  :bind (("C-c h" . helm-command-prefix)
         ("C-x b" . helm-mini)
         ("C-`" . helm-resume)
         ("M-x" . helm-M-x)
         ("C-h <SPC>" . helm-all-mark-rings)
         ("C-x C-f" . helm-find-files)))

(use-package helm-make
  :commands (helm-make helm-make-projectile))

;; from bbatsov's configuration
(use-package imenu-anywhere
  :ensure t
  :bind (("C-c i" . imenu-anywhere)
         ("s-i" . imenu-anywhere)))

;; from howard
;;  to start it up, use M-x inf-ruby
(use-package inf-ruby
  :init
  (add-hook 'enh-ruby-mode-hook 'inf-ruby-minor-mode))

;; jwm
;; fix jedi company init errors by removing jedi for now.
;;
;; derived from Howard Abrams config
;; (use-package jedi
;;   :ensure t
;;   :init
;;   (add-to-list 'company-backends 'company-jedi)
;;   (use-package company-jedi
;;     :init
;;     (setq company-jedi-python-bin "python")))

;; derived from Howard Abrams config
(use-package js2-mode
  :ensure t
  :init
  (setq js-basic-indent 2)
  (setq-default js2-basic-indent 2
                js2-basic-offset 2
                js2-auto-indent-p t
                js2-cleanup-whitespace t
                js2-enter-indents-newline t
                js2-indent-on-enter-key t
                js2-global-externs (list "window" "module" "require" "buster" "sinon" "assert" "refute" "setTimeout" "clearTimeout" "setInterval" "clearInterval" "location" "__dirname" "console" "JSON" "jQuery" "$"))

  ;; (add-hook 'js2-mode-hook
  ;;           (lambda ()
  ;;             (push '("function" . ?ƒ) prettify-symbols-alist)))

  (add-to-list 'auto-mode-alist '("\\.js$" . js2-mode))
  (add-to-list 'auto-mode-alist '("\\.es6$" . js2-mode))
  )

;; try key-chord; derived from sacha's config.
(use-package key-chord
  :init
  (progn
    ;; (fset 'key-chord-define 'my/key-chord-define)
    (setq key-chord-one-key-delay 0.16)
    (key-chord-mode 1)
    ;; k can be bound too
    ;; (key-chord-define-global "uu"     'undo)
    ;; (key-chord-define-global "jr"     'my/goto-random-char-hydra/my/goto-random-char)
    ;; (key-chord-define-global "kk"     'my/org/body)
    (key-chord-define-global "jj"     'avy-goto-word-1)
    (key-chord-define-global "jk"     'avy-goto-word-2)
    ;; (key-chord-define-global "yy"    'my/window-movement/body)
    ;; (key-chord-define-global "jw"     'switch-window)
    (key-chord-define-global "jl"     'avy-goto-line)
    ;; (key-chord-define-global "j."     'join-lines/body)
                                        ;(key-chord-define-global "jZ"     'avy-zap-to-char)
    ;; (key-chord-define-global "FF"     'find-file)
    ;; (key-chord-define-global "qq"     'my/quantified-hydra/body)
    ;; (key-chord-define-global "hh"     'my/key-chord-commands/body)
    (key-chord-define-global "xx"     'er/expand-region)
    ;; (key-chord-define-global "  "     'my/insert-space-or-expand)
    ;; (key-chord-define-global "JJ"     'my/switch-to-previous-buffer)))
    ))

(use-package macrostep
  :bind ("C-c e m" . macrostep-expand))

(use-package magit
  :defer t
  :bind ("C-x g" . magit-status))

;; (use-package nxml-mode
;;   :commands nxml-mode
;;   :init
;;   (defalias 'xml-mode 'nxml-mode)
;;   :config
;;   (defun my-nxml-mode-hook ()
;;     (bind-key "<return>" #'newline-and-indent nxml-mode-map))

;;   (add-hook 'nxml-mode-hook 'my-nxml-mode-hook)

;;   (defun tidy-xml-buffer ()
;;     (interactive)
;;     (save-excursion
;;       (call-process-region (point-min) (point-max) "tidy" t t nil
;;                            "-xml" "-i" "-wrap" "0" "-omit" "-q" "-utf8")))

;;   (bind-key "C-c M-h" #'tidy-xml-buffer nxml-mode-map)

;;   (require 'hideshow)
;;   (require 'sgml-mode)

;;   (add-to-list 'hs-special-modes-alist
;;                '(nxml-mode
;;                  "<!--\\|<[^/>]*[^/]>"
;;                  "-->\\|</[^/>]*[^/]>"

;;                  "<!--"
;;                  sgml-skip-tag-forward
;;                  nil))

;;   (add-hook 'nxml-mode-hook 'hs-minor-mode)

;;   ;; optional key bindings, easier than hs defaults
;;   (bind-key "C-c h" #'hs-toggle-hiding nxml-mode-map))

;; I like rendering my org mode files as html with twitter bootstrap
;;  [[https://github.com/marsmining/ox-twbs][ox-twbs]]
(use-package ox-twbs
  :defer 5)

(use-package projectile
  ;; leave the modeline on so I can see what project I am in.
  ;; diminish projectile mode to work around https://github.com/bbatsov/projectile/issues/1183
  :diminish (projectile-mode . "Pjtl")
  :commands projectile-global-mode
  :defer 5
  :bind-keymap ("C-c p" . projectile-command-map)
  :config
  (use-package helm-projectile
    :config
    (setq projectile-completion-system 'helm)
    (helm-projectile-on))
  (projectile-global-mode)
  (bind-key "s s"
            #'(lambda ()
                (interactive)
                (helm-do-grep-1 (list (projectile-project-root)) t))
            'projectile-command-map)
  (bind-key "s p" 'helm-do-ag-project-root 'projectile-command-map)
  (bind-key "s a" 'helm-do-ag 'projectile-command-map))

;; a lighter weight session manager
;;  https://github.com/thierryvolpiatto/psession
(use-package psession
  :ensure t
  :config (psession-mode 1))

;; copied from senny's init.el: https://github.com/senny/emacs.d/blob/master/init.el#L165
(use-package rbenv
  :ensure t
  :defer t
  :init (setq rbenv-show-active-ruby-in-modeline nil)
  :config (progn
            (global-rbenv-mode)
            (add-hook 'enh-ruby-mode-hook 'rbenv-use-corresponding)))

(use-package robe
  :ensure t
  :defer t
  :config (add-hook 'enh-ruby-mode-hook 'robe-mode))

;; initialize straight from the docs:
;;  http://ensime.github.io/editors/emacs/scala-mode/#installation
(use-package scala-mode
  :interpreter
  ("scala" . scala-mode))

;; jwm
;; I prefer helm-swoop to smartscan.
;;
;; smartscan; derived from Sacha's config
;; (use-package smartscan
;;   :defer t
;;   :config (global-smartscan-mode t))

;; smartparens; derived from Howard's config
;;  well, I started with Howards config.
;; this is now a jwm creation.
(use-package smartparens
  :commands (smartparens-mode show-smartparens-mode)
  :config
  (sp-use-smartparens-bindings))

(use-package terraform-mode
  :ensure t)

(use-package try)

(use-package undo-tree
  :disabled nil
  :config
  (progn
    (global-undo-tree-mode)))

;; try visual regexp, again following Howard Abrams
;;
;; The [[https://github.com/benma/visual-regexp.el][Visual Regular Expressions]] project highlights the matches
;; while you try to remember the differences between Perl's regular
;; expressions and Emacs'...

;; Begin with =C-c r= then type the regexp. To see the highlighted
;; matches, type =C-c a= before you hit 'Return' to accept it.
(use-package visual-regexp
  :ensure t
  :init
  (use-package visual-regexp-steroids :ensure t)

  :bind (("C-c r" . vr/replace)
         ("C-c q" . vr/query-replace)))

;; ;; if you use multiple-cursors, this is for you:
;; :config (use-package  multiple-cursors
;;           :bind ("C-c m" . vr/mc-mark)))

(use-package wgrep
  :ensure t)

;; try winner mode; most of my emacs configs use it.
(use-package winner
  :ensure t
  :init (winner-mode 1))

(use-package which-key
  :config
  :diminish which-key-mode
  :config
  (which-key-mode 1))

(use-package yaml-mode
  :mode ("\\.ya?ml\\'" . yaml-mode))

(use-package yasnippet
  :defer t
  :diminish yas-minor-mode
  :config
  (setq yas-snippet-dirs (concat user-emacs-directory "snippets"))
  (yas-global-mode))

;; prefer zenburn to solarized.
(use-package zenburn-theme
  :init
  (load-theme 'zenburn t))

(use-package ztree
  :defer t)


;;; Post initialization

(when window-system
  (let ((elapsed (float-time (time-subtract (current-time)
                                            emacs-start-time))))
    (message "Loading %s...done (%.3fs)" load-file-name elapsed))

  (add-hook 'after-init-hook
            `(lambda ()
               (let ((elapsed (float-time (time-subtract (current-time)
                                                         emacs-start-time))))
                 (message "Loading %s...done (%.3fs) [after-init]"
                          ,load-file-name elapsed)))
            t))

;;; init.el ends here
