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

(defun jwm/personal-mac-p ()
  (and (eq 'darwin system-type)
       (file-exists-p "/j/pdata/.gitignore")))

(defun jwm/sift-mac-p ()
  (and (eq 'darwin system-type)
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

(when (window-system)
  (when (member "Monaco" (font-family-list))
    (setq jwm/preferred-font
          (cond ((jwm/personal-mac-p) "Hack-14")
                 (t "Monaco-12")))
    (set-frame-font jwm/preferred-font t t)))
