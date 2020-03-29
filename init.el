(defconst emacs-start-time (current-time))

(unless noninteractive
  (message "Loading %s..." load-file-name))

(defconst jwm/emacs-directory (concat (getenv "HOME") "/.emacs.d"))

(defun jwm/emacs-subdirectory (d) (expand-file-name d jwm/emacs-directory))

;; initialize some directories if needed
(let* ((subdirs '("elisp" "backups"))
       (fulldirs (mapcar (lambda (d) (jwm/emacs-subdirectory d)) subdirs)))
  (dolist (dir fulldirs)
    (when (not (file-exists-p dir))
      (message "Make directory: %s" dir)
      (make-directory dir))))

(setq custom-file (expand-file-name "settings.el" jwm/emacs-directory))
(when (file-exists-p custom-file)
  (load custom-file t))

(defun jwm/mac-p ()
  (and (eq 'ns (window-system))
       (eq 'darwin system-type)))

(defun jwm/personal-mac-p ()
  (and (jwm/mac-p)
       (file-exists-p (concat (getenv "HOME") "/jdocs"))))

(defun jwm/sift-mac-p ()
  (and (jwm/mac-p)
       (file-exists-p (expand-file-name "~/code/java/build.gradle"))))

(setq user-full-name "Jeff McCarrell"
      user-mail-address (cond
                         ((jwm/sift-mac-p) "jmccarrell@siftscience.com")
                         (t "jeff@mccarrell.org")))

(when (window-system)
  (server-start))

(require 'package)

(unless (assoc-default "org" package-archives)
  (add-to-list 'package-archives '("org" . "https://orgmode.org/elpa/") t))
(unless (assoc-default "melpa" package-archives)
  (add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t))

(package-initialize)

(unless (package-installed-p 'use-package)
  (package-install 'use-package))

(setq use-package-verbose t)
(setq use-package-always-ensure t)

(require 'use-package)

(require 'cl)

(use-package dash
  :config (eval-after-load "dash" '(dash-enable-font-lock)))

(use-package s)

(use-package f)

(setq inhibit-startup-message t)
;; needed for emacs23
(setq inhibit-splash-screen t)
(setq initial-scratch-message "")

;; Don't beep at me
(setq visible-bell t)

;; get rid of all of the backup files
(setq backup-before-writing nil)
(setq make-backup-files nil)

;; screen real estate is for text, not widgets
(when (window-system)
  (tool-bar-mode 0)
  (when (fboundp 'horizontal-scroll-bar-mode)
    (horizontal-scroll-bar-mode -1))
  (scroll-bar-mode -1))

;; prefer utf-8 encoding in all cases.
(let ((lang 'utf-8))
  (set-language-environment lang)
  (prefer-coding-system lang))

(setq-default indent-tabs-mode nil)
(setq tab-width 2)

(setq-default tab-always-indent 'complete)

;; Hollerith cards have had their day. Norming to 80 characters seems like a poor use of screen real estate
;; to me. I can't form a particular argument for 108, other than: it is larger than 72 and seems to fit
;; better.
(setq-default fill-column 108)
(auto-fill-mode)
(global-visual-line-mode)
(diminish 'visual-line-mode)

(defun jwm/shell-is-zsh-p ()
  (string-suffix-p "zsh" shell-file-name))

(when (jwm/shell-is-zsh-p)
  (setq shell-command-switch "-conorcs"))

;; always end a file with a newline
(setq require-final-newline t)

;; delete the region when typing, just like as we expect nowadays.
(delete-selection-mode t)

;; highlight the matching parenthesis
(show-paren-mode t)

;; Answering just 'y' or 'n' will do
(defalias 'yes-or-no-p 'y-or-n-p)

;; revert buffers automatically when underlying files are changed externally
(global-auto-revert-mode t)

;; no disabled functions
(setq disabled-command-function nil)

(use-package zenburn-theme
  :init (load-theme 'zenburn t))

(defun jwm/font-exists-p (f)
  (and (window-system)
       (member f (font-family-list))))

(when (window-system)
  (let ((preferred-font
         (cond
          ((and (jwm/font-exists-p "Hack") (jwm/mac-p)) "Hack-14")
          (t "Monaco-12"))))
      (message "setting Jeff preferred font %s" preferred-font)
      (set-frame-font preferred-font t t)))

(use-package whitespace
  :bind ("C-c T w" . whitespace-mode)
  :init
  (setq whitespace-line-column nil
        whitespace-display-mappings '((space-mark 32 [183] [46])
                                      (newline-mark 10 [9166 10])
                                      (tab-mark 9 [9654 9] [92 9])))
  :config
  (set-face-attribute 'whitespace-space       nil :foreground "#666666" :background nil)
  (set-face-attribute 'whitespace-newline     nil :foreground "#666666" :background nil)
  (set-face-attribute 'whitespace-indentation nil :foreground "#666666" :background nil)
  :diminish whitespace-mode)

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
  ;;   so prefer C-@
  :bind ("C-@" . ha/expand-region))

(use-package ace-window
  :bind (("M-o" . ace-window))
  :config
  (setq aw-dispatch-always t)
  (setq aw-keys '(?a ?s ?d ?f ?g ?h ?j ?k ?l)))

(when (jwm/mac-p)
  (setq mac-command-modifier 'meta)
  (setq mac-option-modifier 'super)
  (setq mac-right-option-modifier 'none)

  ;; mirror the mac user gesture for switching emacs frames
  ;;  this supports my habit of using two emacs frames side by side.
  (bind-key "M-`" 'other-frame)

  ;; prevent my thumb from triggering this menu on the trackpad when in open laptop mode
  ;;  ie, when I am working on the train
  (bind-key [C-down-mouse-1] 'ignore))

(bind-keys
 ;; long time bindings I have preferred
 ("C-c u" . revert-buffer)
 ("C-M-g" . goto-line)

 ;; perhaps turn these on when/if I bring in Howards font size functions
 ;; ("s-C-+" . ha/text-scale-frame-increase)
 ;; ("A-C-+" . ha/text-scale-frame-increase)
 ;; ("s-C-=" . ha/text-scale-frame-increase)
 ;; ("A-C-=" . ha/text-scale-frame-increase)
 ;; ("s-C--" . ha/text-scale-frame-decrease)
 ;; ("A-C--" . ha/text-scale-frame-decrease)
 )

(use-package which-key
  :config
  :diminish which-key-mode
  :config

  ;; prefer to show the entire command name with no truncation.
  ;;  some of those projectile command names exceed the default value of 27, eg
  ;;  projectile-toggle-between-implementation-and-test
  (setq which-key-max-description-length nil)
  (which-key-mode 1))

(defvar jwm/run-whitespace-cleanup-on-save-p nil
  "run whitespace-cleanup on buffer-save. set to t where desired in file or directory local scopes.")

(defun jwm/save-buffer-whitespace-cleanup-hook ()
  "run whitespace-cleanup when enabled by jwm/run-whitespace-cleanup-on-save-p."
  (when jwm/run-whitespace-cleanup-on-save-p
    (whitespace-cleanup)))

(add-hook 'before-save-hook 'jwm/save-buffer-whitespace-cleanup-hook)

(use-package dired
  :ensure nil
  :config
  ;; dired - reuse current buffer by pressing 'a'
  ;; (put 'dired-find-alternate-file 'disabled nil)

  ;; always delete and copy recursively
  ;; (setq dired-recursive-deletes 'always)
  ;; (setq dired-recursive-copies 'always)

  ;; if there is a dired buffer displayed in the next window, use its
  ;; current subdir, instead of the current subdir of this dired buffer
  (setq dired-dwim-target t)

  ;; enable some really cool extensions like C-x C-j (dired-jump)
  (require 'dired-x))

;; ag config derived from danielmai's config
(use-package ag
  :commands ag)

(use-package projectile
  :init
  (setq projectile-completion-system 'ivy)
  :config
  (define-key projectile-mode-map (kbd "s-p") 'projectile-command-map)
  (define-key projectile-mode-map (kbd "C-c p") 'projectile-command-map)
  (projectile-mode +1))

(use-package swiper
  :config
  (global-set-key "\C-s" 'swiper))

(use-package counsel-projectile
  :config
  (counsel-projectile-mode))

(use-package projectile
  :ensure t
  :diminish projectile-mode
  :commands (projectile-mode projectile-switch-project)
  :bind (("C-c p p" . projectile-switch-project)
         ("C-c p s s" . projectile-ag)
         ("C-c p s r" . projectile-ripgrep))
  :config
  (setq projectile-keymap-prefix (kbd "C-c p"))
  (projectile-global-mode t)
  (setq projectile-enable-caching t)
  (setq projectile-switch-project-action 'projectile-dired))

(use-package ivy
  :diminish (ivy-mode . "")
  :config
  (ivy-mode 1)
  ;; add ‘recentf-mode’ and bookmarks to ‘ivy-switch-buffer’.
  (setq ivy-use-virtual-buffers t)
  ;; show both the index and count of matching items
  (setq ivy-count-format "%d/%d "))

(use-package swiper
  :config
  (global-set-key "\C-s" 'swiper))

(use-package avy
  :bind* ("C-." . avy-goto-char-timer)
  :config
  (avy-setup-default))

(use-package magit
  :defer t
  :bind ("C-x g" . magit-status))

(bind-keys
 ;; org mode wants these default global bindings set up.
 ("C-c l" . org-store-link)
 ("C-c c" . org-capture)
 ("C-c a" . org-agenda)
 ("C-c b" . org-iswitchb))

(setq org-directory
      (cond ((jwm/sift-mac-p) "~/sift/todo")
            (t "~/jwm/todo")))

;; The default place to put notes for capture mode
(setq org-default-notes-file
      (concat org-directory
              (cond ((jwm/sift-mac-p) "/sift.org")
                    (t "/todo.org"))))

;; where I store periodic reminders, ie, ticklers in GTD-talk
(defvar jwm/org-tickler-file (concat org-directory "/tickler.org"))

(setq org-agenda-files (jwm/emacs-subdirectory "org-agenda-files-list"))

;; capture template.
(setq org-capture-templates
      '(("t" "Todo" entry (file+headline org-default-notes-file "Tasks")
         "* TODO %?\n %t\n  %i\n  %a\n")
        ("T" "Tickler" entry (file+headline jwm/org-tickler-file "Tickler")
         "* %i%?\n %U\n")
        ("j" "Journal" entry (file+datetree "~/pdata/journal.org")
         "* %?\nEntered on %U\n  %i\n  %a\n")))

;; Jeff task states
(setq org-todo-keywords
      '((sequence
         "TODO(t)"
         "NEXT(n!)"
         "DOING(g!)"
         "WAITING(w@/!)"
         "|" "DONE(d!)"
         "CANCELLED(c@)"
         "DEFERRED(D@)")))

;; I prefer 2 levels of headlines for org refile targets
;;  this matches well with my TASKS/PROJECTS high level
;; further, I prefer the refiling to be per-buffer, not across all org-agenda-files
;;  to preserve context.  most often, I use the file as context.
(setq org-refile-targets '((nil . (:maxlevel . 2))))

(defun save-org-mode-files ()
  (dolist (buf (buffer-list))
    (with-current-buffer buf
      (when (eq major-mode 'org-mode)
        (if (and (buffer-modified-p) (buffer-file-name))
            (save-buffer))))))

(run-with-idle-timer 25 t 'save-org-mode-files)

(use-package ob-restclient)

(org-babel-do-load-languages
 'org-babel-load-languages
 '((python . t)
   (C . t)
   (calc . t)
   (java . t)
   (ruby . t)
   (lisp . t)
   (scheme . t)
   (shell . t)
   (sqlite . t)
   (js . t)
   (restclient . t)))

(defun my-org-confirm-babel-evaluate (lang body)
  "Do not confirm evaluation for these languages."
  (not (or (string= lang "C")
           (string= lang "java")
           (string= lang "python")
           (string= lang "emacs-lisp")
           (string= lang "sqlite"))))
(setq org-confirm-babel-evaluate 'my-org-confirm-babel-evaluate)

(setq org-babel-python-command "python3")

(use-package yasnippet
  :config
  (use-package yasnippet-snippets)
  (yas-reload-all)
  (add-hook 'prog-mode-hook #'yas-minor-mode)
  (add-hook 'org-mode-hook #'yas-minor-mode))

(use-package auto-yasnippet
  :after yasnippet
  :bind (("s-w" . aya-create)
         ("s-y" . aya-expand)))

(use-package crux
  :bind
  (
   ("C-c n" . crux-cleanup-buffer-or-region)
   ;; ("C-S-RET" . crux-smart-open-line-above)
   ;; ("M-o" . crux-smart-open-line)
   ("C-c d" . crux-duplicate-current-line-or-region)
   ("C-c M-d" . crux-duplicate-and-comment-current-line-or-region)
   ("C-c C-r" . crux-rename-file-and-buffer)))

(use-package js2-mode
  :init
  (setq js-basic-indent 2)
  (setq-default js2-basic-indent 2
                js2-basic-offset 2
                js2-auto-indent-p t
                js2-cleanup-whitespace t
                js2-enter-indents-newline t
                js2-indent-on-enter-key t
                js2-global-externs (list "window" "module" "require" "buster" "sinon" "assert" "refute" "setTimeout" "clearTimeout" "setInterval" "clearInterval" "location" "__dirname" "console" "JSON" "jQuery" "$"))
  (add-to-list 'auto-mode-alist '("\\.js$" . js2-mode))
  (add-to-list 'auto-mode-alist '("\\.es6$" . js2-mode)))

(use-package json-mode)

(setq  python-shell-interpreter "python3")

(use-package elpy
  :init
  (elpy-enable))

(use-package atomic-chrome
  :init
  (ignore-errors
    (atomic-chrome-server-start)))

;;; Post initialization

(let ((elapsed (float-time (time-subtract (current-time)
                                          emacs-start-time))))
  (message "Loading %s...done (%.3fs)" load-file-name elapsed))

(add-hook 'after-init-hook
          `(lambda ()
             (let ((elapsed (float-time (time-subtract (current-time)
                                                       emacs-start-time))))
               (message "Loading %s...done (%.3fs) [after-init]"
                        ,load-file-name elapsed)))
          t)
