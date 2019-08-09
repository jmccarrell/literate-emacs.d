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
       (file-exists-p "/j/pdata/.gitignore")))

(defun jwm/sift-mac-p ()
  (and (jwm/mac-p)
       (file-exists-p (expand-file-name "~/code/java/build.gradle"))))

(setq user-full-name "Jeff McCarrell"
      user-mail-address (cond
                         ((jwm/sift-mac-p) "jmccarrell@siftscience.com")
                         (t "jeff@mccarrell.org")))

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

;; always end a file with a newline
(setq require-final-newline t)

;; Hollerith cards have had their day. Norming to 80 characters seems like a poor use of screen real estate
;; to me. I can't form a particular argument for 108, other than: it larger than 72 and seems to fit better.
(setq-default fill-column 108)

;; delete the region when typing, just like as we expect nowadays.
(delete-selection-mode t)

;; highlight the matching parenthesis
(show-paren-mode t)

;; Answering just 'y' or 'n' will do
(defalias 'yes-or-no-p 'y-or-n-p)

;; revert buffers automatically when underlying files are changed externally
(global-auto-revert-mode t)

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

(when (jwm/mac-p)
  (setq mac-command-modifier 'meta)
  (setq mac-option-modifier 'super)
  (setq mac-right-option-modifier 'none)

  ;; mirror the mac user gesture for switching frames
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

;; ag config derived from danielmai's config
(use-package ag
  :commands ag)

(use-package helm
  :diminish helm-mode
  :bind (("C-c h" . helm-command-prefix)
         ("C-x b" . helm-mini)
         ("C-`" . helm-resume)
         ("M-x" . helm-M-x)
         ("C-x C-f" . helm-find-files)
         ("C-x C-r" . helm-recentf))
  :init
  (require 'helm-config)
  :config
  (setq helm-locate-command "mdfind -interpret -name %s %s"
        helm-ff-newfile-prompt-p nil
        helm-M-x-fuzzy-match t)
  (helm-mode))
(use-package helm-projectile
  :after helm-mode
  :commands helm-projectile
  :bind ("C-c p h" . helm-projectile))
(use-package helm-ag
  :ensure t
  :after helm-mode)
(use-package helm-swoop
  :ensure t
  :after helm-mode
  :bind ("s-w" . helm-swoop))

(use-package projectile
  :diminish projectile-mode
  :bind-keymap ("C-c p" . projectile-command-map)
  :init
  (setq projectile-completion-system 'ivy)
  :config
  (bind-key "s p" 'helm-do-ag-project-root 'projectile-command-map)
  (bind-key "s a" 'helm-do-ag 'projectile-command-map)
  (projectile-mode +1))

(use-package ivy
  :diminish (ivy-mode . "")
  :config
  (ivy-mode 1)
  ;; add ‘recentf-mode’ and bookmarks to ‘ivy-switch-buffer’.
  (setq ivy-use-virtual-buffers t))

(use-package swiper
  :config
  (global-set-key "\C-s" 'swiper))

(use-package crux
  :bind
  (
   ("C-c n" . crux-cleanup-buffer-or-region)
   ;; ("C-S-RET" . crux-smart-open-line-above)
   ("M-o" . crux-smart-open-line)
   ("C-c d" . crux-duplicate-current-line-or-region)
   ("C-c M-d" . crux-duplicate-and-comment-current-line-or-region)
   ("C-c C-r" . crux-rename-file-and-buffer)))

(use-package magit
  :defer t
  :bind ("C-x g" . magit-status))

(bind-keys
 ;; org mode wants these default global bindings set up.
 ("C-c l" . org-store-link)
 ("C-c c" . org-capture)
 ("C-c a" . org-agenda)
 ("C-c b" . org-iswitchb))

;; I prefer dropbox; too bad my work does not.
(setq org-directory
      (cond ((jwm/sift-mac-p) "/s/notes/org")
            (t "~/Dropbox/org")))

;; The default place to put notes for capture mode
(setq org-default-notes-file
      (concat org-directory
              (cond ((jwm/sift-mac-p) "/sift.org")
                    (t "/todo.org"))))

;; my agenda files
;;  code shamelessly stolen from Sacha Chua's config
(setq org-agenda-files
      (delq nil
            (mapcar (lambda (x) (and (file-exists-p x) x))
                    `("~/Dropbox/org/notes.org",
                      org-default-notes-file))))

;; capture template.
(setq org-capture-templates
      '(("t" "Todo" entry (file+headline org-default-notes-file "Tasks")
         "* TODO %?\n %t\n  %i\n  %a")
        ("j" "Journal" entry (file+datetree "~/Dropbox/org/journal.org")
         "* %?\nEntered on %U\n  %i\n  %a")))

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
