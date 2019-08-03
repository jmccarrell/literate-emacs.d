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

;; ;; initialize packages
;; (package-initialize)
;; (eval-and-compile
;;   (require 'cl)

;;   (defvar use-package-verbose t)
;;   (defvar use-package-always-ensure t)
;;   (require 'use-package))

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
  (setq mac-right-option-modifier 'none))

(bind-keys
 ;; long time bindings I have preferred
 ("C-x y" . revert-buffer)
 ("C-M-g" . goto-line)

 ;; org mode wants these default global bindings set up.
 ("C-c l" . org-store-link)
 ("C-c c" . org-capture)
 ("C-c a" . org-agenda)
 ("C-c b" . org-iswitchb)

 ;; perhaps turn these of when/if I bring in Howards font size functions

 ("s-C-+" . ha/text-scale-frame-increase)
 ("A-C-+" . ha/text-scale-frame-increase)
 ("s-C-=" . ha/text-scale-frame-increase)
 ("A-C-=" . ha/text-scale-frame-increase)
 ("s-C--" . ha/text-scale-frame-decrease)
 ("A-C--" . ha/text-scale-frame-decrease))

(use-package which-key
  :config
  :diminish which-key-mode
  :config

  ;; prefer to show the entire command name with no truncation.
  ;;  some of those projectile command names exceed the default value of 27, eg
  ;;  projectile-toggle-between-implementation-and-test
  (setq which-key-max-description-length nil)
  (which-key-mode 1))
