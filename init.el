;;; init.el --- Jeff McCarrell's literate Emacs configuration -*- lexical-binding: t; -*-

(defconst emacs-start-time (current-time))

(unless noninteractive
  (message "Loading %s..." load-file-name))

(when (eq system-type 'darwin)
  (with-eval-after-load 'comp
    (add-to-list 'native-comp-driver-options "-mmacosx-version-min=11"))
  (with-eval-after-load 'comp-run
    (require 'comp)))

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

(setq user-full-name "Jeff McCarrell"
      user-mail-address (cond
                         (t "jeff@mccarrell.org")))

(when (window-system)
  (server-start))

(require 'package)

;; Use the UK MirrorService mirror for GNU ELPA; keep the archive
;; named "gnu" so package priorities and dependencies still work.
;; package.el can refresh this mirror over HTTP; the HTTPS endpoint
;; currently fails in Emacs even though curl can fetch it.
(setq package-archives
      (cons '("gnu" . "http://www.mirrorservice.org/sites/elpa.gnu.org/packages/")
            (assoc-delete-all "gnu" package-archives)))
;; Use MELPA's official MirrorService mirror too; the direct
;; melpa.org HTTPS endpoint fails from Emacs on this network.
(setq package-archives
      (cons '("melpa" . "http://www.mirrorservice.org/sites/melpa.org/packages/")
            (assoc-delete-all "melpa" package-archives)))
;; Drop the built-in NonGNU archive: elpa.nongnu.org has the same
;; GnuTLS pull failure here, and the configured non-built-ins are
;; available from MELPA/GNU/Org.
(setq package-archives (assoc-delete-all "nongnu" package-archives))
(unless (assoc-default "org" package-archives)
  (add-to-list 'package-archives '("org" . "https://orgmode.org/elpa/") t))

;; Prefer MELPA when a package appears in multiple archives; keep
;; Org and GNU available as lower-priority fallbacks.
(setq package-archive-priorities
      '(("melpa" . 30)
        ("org" . 20)
        ("gnu" . 5)))

(package-initialize)

(setq use-package-verbose t)
;; Startup should never block on package archive network access.
;; Install missing packages explicitly with package.el commands.
(setq use-package-always-ensure nil)

;; Explicit install manifest. Because always-ensure is nil, loading this
;; config never installs anything — packages are installed out-of-band with
;; `just install-packages', e.g. when provisioning a fresh machine. A plain
;; defvar (not `package-selected-packages') on purpose: that variable is a
;; delayed-init custom var, so a stale value in the custom-file (settings.el)
;; is applied after init and would clobber it. External archive packages only
;; (no built-ins); keep in sync with the use-package forms below. Packages
;; loaded via `require' or a nested use-package (e.g. yasnippet-snippets, inside
;; yasnippet's :config) aren't auto-derived — add them here by hand.
(defvar jwm/required-packages
  '(ace-window auto-yasnippet avy cape consult corfu crux diminish
    docker dockerfile-mode edit-indirect embark embark-consult envrc
    expand-region flymake-ruff ghostel go-mode gptel js2-mode json-mode
    jsonnet-mode just-mode just-ts-mode magit marginalia markdown-mode
    mcp-server-lib mise ob-restclient orderless outline-indent pet
    reformatter terraform-mode textsize vertico wgrep which-key
    wrap-region yaml-mode yasnippet yasnippet-snippets zenburn-theme)
  "External packages this config expects; installed by `just install-packages'.")
;; Packages not in any archive, installed from source by `package-vc-install'.
;; Each entry is a `package-vc-selected-packages' spec.
(defvar jwm/required-vc-packages
  '((claude-code-ide :url "https://github.com/manzaltu/claude-code-ide.el")
    (llm-tool-collection :url "https://github.com/skissue/llm-tool-collection"))
  "Source packages this config expects; installed by `just install-packages'.")
(require 'use-package)

(defun jwm/warm-native-comp ()
  "Native-compile installed packages + the lisp this config has loaded.
Intended for headless provisioning; blocks until compilation completes."
  (when (native-comp-available-p)
    (let ((files (directory-files-recursively package-user-dir "\\.el\\'")))
      (dolist (entry load-history)
        (let* ((f (car entry))
               (base (and (stringp f) (string-suffix-p ".elc" f)
                          (file-name-sans-extension f)))
               (src (and base (seq-find #'file-exists-p
                                        (list (concat base ".el")
                                              (concat base ".el.gz"))))))
          (when src (push src files))))
      (native-compile-async (delete-dups files))
      ;; native-compile-async doesn't fill its queue instantly — settle first.
      (sleep-for 3)
      ;; Emacs 31 renamed comp-async-runnings to comp--async-runnings.
      (let ((runnings (seq-find #'fboundp '(comp--async-runnings
                                            comp-async-runnings))))
        (while (or comp-files-queue
                   (and runnings (> (or (funcall runnings) 0) 0)))
          (sleep-for 1))))))

(setq inhibit-startup-message t)
;; needed for emacs23
(setq inhibit-splash-screen t)
(setq initial-scratch-message "")

;; Don't beep at me
(setq visible-bell t)

;; get rid of all of the backup files; that is what revision control is for.
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

(use-package eshell
  :ensure nil
  :commands eshell
  :bind ("C-x C-z" . jwm/eshell-toggle)
  :preface
  (defvar jwm/eshell-toggle-window-configuration nil
    "Window configuration before toggling to Eshell.")

  (defun jwm/eshell-prompt-path ()
    "Return a compact current directory for the Eshell prompt."
    (let* ((path (directory-file-name (abbreviate-file-name (eshell/pwd))))
           (parts (split-string path "/" t))
           (last-part (car (last parts)))
           (parent-part (cadr (reverse parts)))
           (tail (if (and last-part parent-part (string= last-part "main"))
                     (format "%s/%s" parent-part last-part)
                   last-part)))
      (cond
       ((<= (length path) 32) path)
       ((and parent-part (string= last-part "main")) tail)
       ((string-prefix-p "~/" path)
        tail)
       ((> (length parts) 2)
        (format "/.../%s" tail))
       (t path))))

  (defun jwm/eshell-prompt ()
    "Return a compact Eshell prompt."
    (concat (jwm/eshell-prompt-path)
            (unless (eshell-exit-success-p)
              (format " [%d]" eshell-last-command-status))
            (if (= (file-user-uid) 0) " # " " $ ")))

  (defun jwm/eshell-toggle (&optional make-cd)
    "Toggle Eshell.
With a prefix argument, cd Eshell to the current buffer's directory."
    (interactive "P")
    (if (eq major-mode 'eshell-mode)
        (jwm/eshell-toggle-return)
      (jwm/eshell-toggle-goto make-cd)))

  (defun jwm/eshell-toggle-return ()
    "Return from Eshell to the saved window configuration."
    (interactive)
    (if (window-configuration-p jwm/eshell-toggle-window-configuration)
        (progn
          (set-window-configuration jwm/eshell-toggle-window-configuration)
          (setq jwm/eshell-toggle-window-configuration nil)
          (bury-buffer "*eshell*"))
      (bury-buffer)))

  (defun jwm/eshell-toggle-goto (make-cd)
    "Switch to Eshell, optionally changing to the current buffer directory."
    (let* ((origin-directory (file-name-as-directory
                              (expand-file-name
                               (or default-directory
                                   (bound-and-true-p list-buffers-directory)))))
           (eshell-buffer (get-buffer "*eshell*"))
           (cd-command (and make-cd
                            (format "cd %s" (shell-quote-argument origin-directory)))))
      (setq jwm/eshell-toggle-window-configuration (current-window-configuration))
      (if eshell-buffer
          (switch-to-buffer-other-window eshell-buffer)
        (let ((default-directory origin-directory))
          (eshell)))
      (when (or cd-command make-cd)
        (goto-char (point-max)))
      (when cd-command
        (insert cd-command)
        (eshell-send-input))))
  :config
  (setq eshell-prompt-function #'jwm/eshell-prompt)

  (defun eshell/ll (&rest args)
    "List files in long form, preserving shell muscle memory."
    (apply #'eshell/ls "-lF" args))

  (defun eshell/la (&rest args)
    "List all files in long form, preserving shell muscle memory."
    (apply #'eshell/ls "-laF" args))

  (defun eshell/lt (&rest args)
    "List all files in long time order, preserving shell muscle memory."
    (apply #'eshell/ls "-laFtr" args))

  (defun eshell/lsd (&rest args)
    "List directories in long form."
    (let ((targets args))
      (unless targets
        (dolist (file (directory-files default-directory nil directory-files-no-dot-files-regexp))
          (when (file-directory-p file)
            (push file targets)))
        (setq targets (nreverse targets)))
      (when targets
        (apply #'eshell/ls "-ldF" targets))))

  (defun eshell/path (&rest args)
    "Print PATH entries one per line.
 The -l option is accepted for shell muscle memory."
    (dolist (arg args)
      (unless (string= arg "-l")
        (user-error "Unsupported path option: %s" arg)))
    (dolist (entry (split-string (or (getenv "PATH") "") path-separator t))
      (eshell-print (concat entry "\n"))))

  (dolist (command '(eshell/ll eshell/la eshell/lt eshell/lsd))
    (put command 'eshell-no-numeric-conversions t)
    (put command 'eshell-filename-arguments t)))

;; always end a file with a newline
(setq require-final-newline t)

;; delete the region when typing, just like as we expect nowadays.
(delete-selection-mode t)

;; highlight the matching parenthesis
(show-paren-mode t)

;; Answering just 'y' or 'n' will do (use-short-answers is Emacs 28+)
(setq use-short-answers t)

;; revert buffers automatically when underlying files are changed externally
(global-auto-revert-mode t)

;; no disabled functions
(setq disabled-command-function nil)

(defun jwm/kill-buffers-of-missing-files ()
  "Kill unmodified file buffers whose backing file no longer exists.
Skips modified buffers and remote (TRAMP) files."
  (interactive)
  (let ((n 0))
    (dolist (buf (buffer-list))
      (let ((file (buffer-file-name buf)))
        (when (and file
                   (not (file-remote-p file))
                   (not (file-exists-p file))
                   (not (buffer-modified-p buf)))
          (kill-buffer buf)
          (setq n (1+ n)))))
    (message "Killed %d buffer(s) visiting missing files" n)))

(defun jwm/kill-buffers-under-dir (dir)
  "Kill unmodified file buffers whose file lives under DIR.
Use this on a worktree root *before* `git worktree remove'."
  (interactive "DKill file buffers under directory: ")
  (let ((root (file-name-as-directory (expand-file-name dir)))
        (n 0))
    (dolist (buf (buffer-list))
      (let ((file (buffer-file-name buf)))
        (when (and file
                   (string-prefix-p root (expand-file-name file))
                   (not (buffer-modified-p buf)))
          (kill-buffer buf)
          (setq n (1+ n)))))
    (message "Killed %d buffer(s) under %s" n root)))

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

(use-package textsize
  :init (textsize-mode)
  :config
  (customize-set-variable 'textsize-monitor-size-thresholds
                          '((0 . 2) (400 . 5) (650 . 6)))
  (customize-set-variable 'textsize-pixel-pitch-thresholds
                          '((0 . 3) (0.22 . -6))))

(defun jwm/dump-frame-textsize-metrics ()
  "Dump selected frame metrics from the currently selected frame to the *Message* buffer.
Intended to be helpful for debugging the choices textsize makes for a given monitor/display."
  (interactive)
  (let ((f (selected-frame)))
    (message "emacs frame geometry: X Y WIDTH HEIGHT: %s" (frame-monitor-attribute 'geometry f))
    (message "emacs monitor size WIDTH HEIGHT mm: %s" (frame-monitor-attribute 'mm-size f))
    (message "textsize monitor size  mm: %d" (textsize--monitor-size-mm f))
    (message "textsize monitor size pix: %d" (textsize--monitor-size-px f))
    (message "pixel pitch %.02f" (textsize--pixel-pitch f))
    (message "textsize default points %d" textsize-default-points)
    (message "textsize frame offset %d"
             (or (frame-parameter f 'textsize-manual-adjustment) 0))
    (message "pixel pitch adjustment %d"
             (textsize--threshold-offset textsize-pixel-pitch-thresholds
                                         (textsize--pixel-pitch f)))
    (message "monitor size adjustment %d"
             (textsize--threshold-offset textsize-monitor-size-thresholds
                                         (textsize--monitor-size-mm f)))
    (message "text size chosen: %d" (textsize--point-size f))
    (message "default-font: WIDTHxHEIGHT %dx%d" (default-font-width)(default-font-height))
    (message "resultant text area in chars WIDTHxHEIGHT %dx%d"
             (frame-width f)(frame-height f))
    (message "default face font %s" (face-attribute 'default :font))
    )
  nil)

(defun jwm/adjust-textsize-frame-offset (arg)
  "Supply a per-frame, persistent integer offset (positive or negative) to the textsize font size calculation.
In effect, adjusts the pixel size of the frame font up or down by the prefix value."
  (interactive "P")
  (let ((f (selected-frame))
        (offset arg))
    (textsize-modify-manual-adjust f offset)))

(use-package diminish
  :init (diminish 'visual-line-mode))

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

;; M-[ is ESC[ — the terminal CSI introducer that every escape sequence
;; starts with — so binding it shadows focus/bracketed-paste/etc. in a
;; terminal (garbage like "[I]" and "[200~foo[201~"). Only bind it in
;; graphical frames; the others below aren't escape-sequence introducers.
(when (display-graphic-p)
  (global-set-key (kbd "M-[") 'insert-pair))
(global-set-key (kbd "M-{") 'insert-pair)
;; (global-set-key (kbd "M-<") 'insert-pair)
(global-set-key (kbd "M-'") 'insert-pair)
;; (global-set-key (kbd "M-`") 'insert-pair)
(global-set-key (kbd "M-\"") 'insert-pair)

(use-package wrap-region
  :ensure   t
  :config
  (wrap-region-global-mode t)
  (wrap-region-add-wrappers
   '(("(" ")")
     ("[" "]")
     ("{" "}")
     ("<" ">")
     ("'" "'")
     ("\"" "\"")
     ("‘" "’"   "q")
     ("“" "”"   "Q")
     ("*" "*"   "b"   org-mode)                 ; bolden
     ("*" "*"   "*"   org-mode)                 ; bolden
     ("/" "/"   "i"   org-mode)                 ; italics
     ("/" "/"   "/"   org-mode)                 ; italics
     ("~" "~"   "c"   org-mode)                 ; code
     ("~" "~"   "~"   org-mode)                 ; code
     ("=" "="   "v"   org-mode)                 ; verbatim
     ("=" "="   "="   org-mode)                 ; verbatim
     ("_" "_"   "u" '(org-mode markdown-mode))  ; underline
     ("**" "**" "b"   markdown-mode)            ; bolden
     ("*" "*"   "i"   markdown-mode)            ; italics
     ("`" "`"   "c" '(markdown-mode ruby-mode)) ; code
     ("`" "'"   "c"   lisp-mode)                ; code
     ))
  :diminish wrap-region-mode)

(use-package which-key
  :ensure nil  ; built-in since Emacs 30
  :diminish which-key-mode
  :config
  ;; prefer to show the entire command name with no truncation;
  ;;  some command names exceed the default value of 27.
  (setq which-key-max-description-length nil)
  (which-key-mode 1))

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

(use-package project
  :ensure nil  ; built-in
  :config
  ;; Prune known projects whose directories no longer exist, once
  ;; per session at startup, so the `project-switch-project' list
  ;; stays free of dead paths. Guarded so batch runs (e.g. `just
  ;; verify-tangle') never touch the real project list on disk.
  (unless noninteractive
    (project-forget-zombie-projects)))

(use-package savehist
  :ensure nil
  :init (savehist-mode))

(use-package recentf
  :ensure nil  ; built-in
  :custom
  (recentf-max-saved-items 200)
  (recentf-max-menu-items 25)
  (recentf-auto-cleanup 'mode)
  (recentf-exclude
   '("/\\.git/" "/elpa/" "/tmp/" "\\.gz\\'"
     "COMMIT_EDITMSG\\'" "-autoloads\\.el\\'"
     "/\\(?:ssh\\|sudo\\):"))
  :init
  (recentf-mode 1))

(use-package vertico
  :init (vertico-mode)
  :custom
  (vertico-cycle t)
  (vertico-resize t))

(use-package vertico-directory
  :ensure nil  ; ships with vertico
  :after vertico
  :bind (:map vertico-map
              ("RET"   . vertico-directory-enter)
              ("DEL"   . vertico-directory-delete-char)
              ("M-DEL" . vertico-directory-delete-word)))

(use-package orderless
  :custom
  (completion-styles '(orderless basic))
  (completion-category-defaults nil)
  (completion-category-overrides '((file (styles partial-completion)))))

(use-package marginalia
  :init (marginalia-mode))

(use-package corfu
  :if (package-installed-p 'corfu)
  :custom
  (corfu-auto t)            ; popup appears automatically as you type
  (corfu-auto-delay 0.6)    ; ...after this idle delay
  (corfu-auto-prefix 2)     ; ...once 2 chars are typed
  (corfu-cycle t)           ; wrap around the candidate list
  :config
  (global-corfu-mode)
  (corfu-popupinfo-mode))   ; show docstring beside the candidate

(use-package cape
  :if (package-installed-p 'cape)
  :custom
  (cape-dabbrev-min-length 5)
  :init
  (add-to-list 'completion-at-point-functions #'cape-dabbrev)
  (add-to-list 'completion-at-point-functions #'cape-file))

(use-package dabbrev
  :ensure nil  ; built-in
  :custom
  (dabbrev-case-fold-search nil)
  (dabbrev-case-replace nil))

(use-package consult
  :bind (;; C-x bindings (buffer list, remapped)
         ([remap switch-to-buffer]              . consult-buffer)
         ([remap switch-to-buffer-other-window] . consult-buffer-other-window)
         ([remap switch-to-buffer-other-frame]  . consult-buffer-other-frame)
         ;; yanking
         ("M-y" . consult-yank-pop)
         ;; go-to (M-g) map
         ([remap goto-line] . consult-goto-line)
         ("M-g i"           . consult-imenu)
         ;; search (M-s) map
         ("M-s j" . consult-git-grep)
         ("M-s l" . consult-line)
         ("M-s r" . consult-ripgrep)
         ("M-s f" . consult-find)
         ;; swiper muscle memory
         ("C-s"   . consult-line))
  :config
  ;; defer previews until asked; avoids opening many large files
  ;; as you arrow through candidates.
  (consult-customize
   consult-ripgrep consult-git-grep consult-grep
   consult-bookmark consult-recent-file consult-xref
   :preview-key "M-."))

;; Press M-? on a symbol (or selected region) to search the
;; project for it. Adapted from steve-purcell's init-minibuffer.el.
(defun jwm/consult-ripgrep-at-point (&optional dir initial)
  "Run `consult-ripgrep' seeded with the symbol or region at point."
  (interactive
   (list current-prefix-arg
         (if (use-region-p)
             (buffer-substring-no-properties (region-beginning) (region-end))
           (when-let* ((s (symbol-at-point)))
             (symbol-name s)))))
  (consult-ripgrep dir initial))

(when (executable-find "rg")
  (global-set-key (kbd "M-?") #'jwm/consult-ripgrep-at-point))

(use-package wgrep
  :after grep)

(use-package embark
  :bind (("C-."   . embark-act)
         ("C-h B" . embark-bindings))  ; inspect bindings for a prefix
  :init
  (setq prefix-help-command #'embark-prefix-help-command))

(use-package embark-consult
  :after (embark consult)
  :hook (embark-collect-mode . consult-preview-at-point-mode))

(use-package avy
  :bind* ("C-;" . avy-goto-char-timer)
  :config
  (avy-setup-default))

(defun jwm/worktree-container-directory (primary-worktree)
  "Return the `.worktrees' sibling directory for PRIMARY-WORKTREE."
  (let* ((worktree (directory-file-name
                    (expand-file-name primary-worktree)))
         (parent (file-name-directory worktree))
         (name (file-name-nondirectory worktree)))
    (expand-file-name (concat name ".worktrees/") parent)))

(defun jwm/magit-read-worktree-directory (prompt branch)
  "Read a new worktree directory using Jeff's sibling convention.
BRANCH supplies the slash-safe default leaf name."
  (let* ((primary-worktree (caar (magit-list-worktrees)))
         (container (jwm/worktree-container-directory primary-worktree))
         (leaf (and branch (string-replace "/" "-" branch))))
    (make-directory container t)
    (read-directory-name prompt container nil nil leaf)))

(defun jwm/git-worktree-paths-from-porcelain (output)
  "Return registered worktree paths from Git porcelain OUTPUT."
  (let (paths)
    (dolist (line (split-string output "\n" t))
      (when (string-prefix-p "worktree " line)
        (push (file-name-as-directory (substring line 9)) paths)))
    (nreverse paths)))

(defun jwm/git-worktree-paths ()
  "Return the worktrees registered for the current Git repository."
  (with-temp-buffer
    (unless (zerop (process-file "git" nil t nil "worktree" "list" "--porcelain"))
      (user-error "Could not list Git worktrees"))
    (jwm/git-worktree-paths-from-porcelain (buffer-string))))

(defun jwm/magit-switch-worktree ()
  "Select a Git-registered worktree and show its Magit status buffer."
  (interactive)
  (require 'magit)
  (let ((worktree (completing-read "Visit worktree: "
                                   (jwm/git-worktree-paths) nil t)))
    (magit-status-setup-buffer worktree)))

(use-package magit
  :defer t
  :bind ("C-x g" . magit-status)
  :init
  (setq magit-diff-visit-prefer-worktree t
        magit-read-worktree-directory-function
        #'jwm/magit-read-worktree-directory))

(bind-keys
 ;; org mode wants these default global bindings set up.
 ("C-c l" . org-store-link)
 ("C-c c" . org-capture)
 ("C-c a" . org-agenda))

(setq org-directory
      (let ((root (locate-dominating-file
                   default-directory "org-agenda-files-list")))
        (if root
            (abbreviate-file-name (directory-file-name root))
          "~/jwm/todo")))

;; The default place to put notes for capture mode
(setq org-default-notes-file
      (concat org-directory
              (cond (t "/todo.org"))))

;; where I store periodic reminders, ie, ticklers in GTD-talk
(defvar jwm/org-tickler-file (concat org-directory "/tickler.org"))

(defvar jwm/org-agenda-files-list
  (expand-file-name "org-agenda-files-list" org-directory)
  "File naming the files `org-agenda' scans, one path per line.")

(setq org-agenda-files jwm/org-agenda-files-list)

;; capture template.
(setq org-capture-templates
      '(("t" "Todo" entry (file+headline org-default-notes-file "Tasks")
         "* TODO %?\n %i\n  %a\n")
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
;; Allow refiling into any of my current projects,
;;  as named by org-agenda-files.
(setq org-refile-targets '((org-agenda-files . (:maxlevel . 2))))

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
   (sql . t)
   (sqlite . t)
   (js . t)
   (restclient . t)))

;; -X so ~/.psqlrc output cannot land in the result table.  "postgres",
;; not "postgresql": C-c ' hands the engine to `sql-set-product'.
(setq org-babel-default-header-args:sql
      '((:engine . "postgres") (:cmdline . "-X")))

(defun my-org-confirm-babel-evaluate (lang body)
  "Do not confirm evaluation for these languages."
  (not (or (string= lang "C")
           (string= lang "java")
           (string= lang "python")
           (string= lang "emacs-lisp")
           (string= lang "sql")
           (string= lang "sqlite"))))
(setq org-confirm-babel-evaluate 'my-org-confirm-babel-evaluate)

(use-package markdown-mode
  :mode (("\\.md\\'"       . gfm-mode)
         ("\\.markdown\\'" . gfm-mode))
  :custom
  ;; render fenced code blocks using the language's native font-lock
  (markdown-fontify-code-blocks-natively t)
  ;; progressively larger fonts for h1..h6
  (markdown-header-scaling t)
  ;; no extra space between ``` and the language name
  (markdown-spaces-after-code-fence 0)
  ;; pandoc is flexible if we ever want `C-c C-c p` preview
  (markdown-command "pandoc --from=gfm --to=html5 --standalone"))

(use-package edit-indirect)

(defvar-keymap jwm/ai-map
  :doc "AI commands: gptel and claude-code-ide.")
(keymap-global-set "C-x c" jwm/ai-map)
(with-eval-after-load 'which-key
  (which-key-add-key-based-replacements "C-x c" "AI"))

(use-package gptel
  :commands (gptel gptel-send gptel-menu gptel-abort)
  :bind (:map jwm/ai-map
              ("g" . gptel)
              ("s" . gptel-send)
              ("m" . gptel-menu)
              ("x" . gptel-abort))
  :init
  (defvar jwm/gptel-anthropic-host "api.anthropic.com"
    "Auth-source host for the Anthropic API key.")

  (defvar jwm/gptel-groq-host "api.groq.com"
    "Auth-source host for the Groq API key.")

  (defvar jwm/gptel-claude-model 'claude-sonnet-4-5-20250929
    "Selectable Claude model for gptel.")

  (defvar jwm/gptel-groq-default-model 'openai/gpt-oss-120b
    "Default Groq coding model for gptel.")

  (defvar jwm/gptel-groq-alt-model 'qwen/qwen3.6-27b
    "Alternate (lighter) Groq model for gptel.")

  (defun jwm/gptel-auth-source-password (host)
    "Return the first auth-source password for HOST."
    (require 'auth-source)
    (or (auth-source-pick-first-password :host host)
        (user-error "No auth-source password found for %s" host)))

  :config
  (setq gptel-default-mode 'org-mode
        gptel-include-reasoning nil)
  ;; Cloud backends are only reachable on the personal machine.
  (when (jwm/personal-mac-p)
    (gptel-make-anthropic "Claude"
      :stream t
      :key (lambda ()
             (jwm/gptel-auth-source-password jwm/gptel-anthropic-host))
      :models (list jwm/gptel-claude-model))
    (setq gptel-model jwm/gptel-groq-default-model)
    (setq gptel-backend
          (gptel-make-openai "Groq"
            :host jwm/gptel-groq-host
            :endpoint "/openai/v1/chat/completions"
            :stream t
            :key (lambda ()
                   (jwm/gptel-auth-source-password jwm/gptel-groq-host))
            :models (list jwm/gptel-groq-default-model
                          jwm/gptel-groq-alt-model)))))

(use-package gptel-rewrite
  :ensure nil  ; ships with gptel
  :commands (gptel-rewrite)
  :bind (:map jwm/ai-map ("r" . gptel-rewrite))
  :init
  (with-eval-after-load 'which-key
    (which-key-add-key-based-replacements "C-x c r" "rewrite region"))
  :custom
  (gptel-rewrite-default-action nil)
  :config
  (defun jwm/gptel-python-rewrite-directive ()
    "Return a Python-specific directive for `gptel-rewrite'."
    (when (derived-mode-p 'python-mode 'python-ts-mode)
      (concat
       "You are editing Python code in an Emacs buffer. "
       "Make the smallest focused change that satisfies the request. "
       "Preserve behavior unless the user explicitly asks for a behavior change. "
       "Do not introduce new dependencies unless the user asks for them. "
       "Return only the replacement code for the selected region.")))

  (add-hook 'gptel-rewrite-directives-hook
            #'jwm/gptel-python-rewrite-directive))

(use-package gptel-context
  :ensure nil  ; ships with gptel
  :commands (gptel-context-add gptel-context-remove-all)
  :bind (:map jwm/ai-map
              ("a" . gptel-context-add)
              ("A" . gptel-context-remove-all))
  :init
  (with-eval-after-load 'which-key
    (which-key-add-key-based-replacements
      "C-x c a" "add gptel context"
      "C-x c A" "clear gptel context")))

(use-package llm-tool-collection
  :after gptel
  :config
  ;; A tool carries several tags; register each one once.
  (dolist (tool (seq-uniq
                 (seq-mapcat #'llm-tool-collection-get-tag
                             '(filesystem editing introspection))))
    (apply #'gptel-make-tool tool)))

(use-package mcp-server-lib
  :commands (mcp-server-lib-install
             mcp-server-lib-uninstall
             mcp-server-lib-start
             mcp-server-lib-stop
             mcp-server-lib-register-tool)
  :init
  (defvar jwm/mcp-live-emacs-server-id "live-emacs"
    "MCP server identifier for this Emacs session's tools.")

  (defvar jwm/mcp-live-emacs-tools-registered nil
    "List of `live-emacs' MCP tool IDs registered in this session.")

  (defun jwm/mcp-live-emacs--json-false (value)
    "Return VALUE as a JSON boolean value."
    (if value t :json-false))

  (defun jwm/mcp-live-emacs--first-doc-line (symbol)
    "Return the first documentation line for SYMBOL, or nil."
    (when (symbolp symbol)
      (let ((doc (documentation symbol t)))
        (when (stringp doc)
          (car (split-string doc "\n" t))))))

  (defun jwm/mcp-live-emacs--register-tool (handler &rest properties)
    "Register HANDLER with PROPERTIES once for this Emacs session."
    (require 'mcp-server-lib)
    (when (eq jwm/mcp-live-emacs-tools-registered t)
      (setq jwm/mcp-live-emacs-tools-registered '("emacs_state_summary")))
    (let ((id (plist-get properties :id)))
      (unless (member id jwm/mcp-live-emacs-tools-registered)
        (apply #'mcp-server-lib-register-tool handler properties)
        (add-to-list 'jwm/mcp-live-emacs-tools-registered id))))

  (defun jwm/mcp-live-emacs-state-summary ()
    "Return read-only JSON metadata about the current Emacs session."
    (require 'json)
    (let* ((window (selected-window))
           (buffer (and (window-live-p window)
                        (window-buffer window)))
           (project-root
            (when (and buffer
                       (fboundp 'project-current)
                       (fboundp 'project-root))
              (with-current-buffer buffer
                (let ((project (project-current nil)))
                  (when project
                    (expand-file-name (project-root project))))))))
      (with-current-buffer (or buffer (current-buffer))
        (json-encode
         `(("buffer" . ,(buffer-name))
           ("major_mode" . ,(symbol-name major-mode))
           ("file" . ,buffer-file-name)
           ("default_directory" . ,default-directory)
           ("project_root" . ,project-root)
           ("emacs_version" . ,emacs-version)
           ("read_only" . t))))))

  (defun jwm/mcp-live-emacs-key-binding (key)
    "Return read-only JSON metadata about KEY's active binding.

MCP Parameters:
  key - Emacs key sequence accepted by `kbd', for example C-x c g"
    (require 'json)
    (condition-case err
        (let* ((key-vector (kbd key))
               (command (key-binding key-vector t))
               (command-symbol (and (symbolp command) command))
               (command-name
                (cond
                 ((symbolp command) (symbol-name command))
                 ((null command) nil)
                 (t (prin1-to-string command))))
               (command-type
                (cond
                 ((symbolp command) "symbol")
                 ((null command) "unbound")
                 (t "function"))))
          (json-encode
           `(("key" . ,key)
             ("normalized_key" . ,(key-description key-vector))
             ("command" . ,command-name)
             ("command_type" . ,command-type)
             ("command_doc_summary" . ,(jwm/mcp-live-emacs--first-doc-line command-symbol))
             ("read_only" . t))))
      (error
       (json-encode
        `(("key" . ,key)
          ("error" . ,(error-message-string err))
          ("read_only" . t))))))

  (defun jwm/mcp-live-emacs-library-status (library)
    "Return read-only JSON metadata about LIBRARY or feature name.

MCP Parameters:
  library - feature or library name, for example gptel or json"
    (require 'json)
    (let* ((feature (intern-soft library))
           (loaded (and feature (featurep feature)))
           (path (locate-library library)))
      (json-encode
       `(("library" . ,library)
         ("feature_known" . ,(jwm/mcp-live-emacs--json-false feature))
         ("feature_loaded" . ,(jwm/mcp-live-emacs--json-false loaded))
         ("library_path" . ,path)
         ("read_only" . t)))))

  (defun jwm/mcp-live-emacs-eval (form)
    "Evaluate FORM and return its value's printed representation.

A failing form is reported with `mcp-server-lib-tool-throw', which the
client sees as a tool result carrying `isError'.  A broken channel
arrives instead as a JSON-RPC error, so the two stay distinguishable
at the protocol layer without wrapping the value in an envelope.

MCP Parameters:
  form - one elisp form, as a string, for example (org-version)"
    (condition-case err
        (prin1-to-string (eval (car (read-from-string form)) t))
      (error
       (mcp-server-lib-tool-throw (error-message-string err)))))

  (defun jwm/mcp-live-emacs-register-tools ()
    "Register the `live-emacs' MCP tools."
    (interactive)
    (require 'mcp-server-lib)
    (jwm/mcp-live-emacs--register-tool
     #'jwm/mcp-live-emacs-state-summary
     :id "emacs_state_summary"
     :description "Return read-only metadata about the current Emacs session."
     :title "Emacs State Summary"
     :read-only t
     :server-id jwm/mcp-live-emacs-server-id)
    (jwm/mcp-live-emacs--register-tool
     #'jwm/mcp-live-emacs-key-binding
     :id "emacs_key_binding"
     :description "Return the active command bound to an Emacs key sequence."
     :title "Emacs Key Binding"
     :read-only t
     :server-id jwm/mcp-live-emacs-server-id)
    (jwm/mcp-live-emacs--register-tool
     #'jwm/mcp-live-emacs-library-status
     :id "emacs_library_status"
     :description "Return loaded feature status and library path for an Emacs library name."
     :title "Emacs Library Status"
     :read-only t
     :server-id jwm/mcp-live-emacs-server-id)
    (jwm/mcp-live-emacs--register-tool
     #'jwm/mcp-live-emacs-eval
     :id "elisp_eval"
     :description "Evaluate one elisp form in this Emacs session and return its value."
     :title "Elisp Eval"
     :read-only nil
     :server-id jwm/mcp-live-emacs-server-id))

  (defun jwm/mcp-live-emacs-start ()
    "Start the `live-emacs' MCP server.

Deliberately not started on init: `elisp_eval' evaluates arbitrary
forms, so this exposes everything Emacs can do to any client that
can reach the socket."
    (interactive)
    (require 'mcp-server-lib)
    (jwm/mcp-live-emacs-register-tools)
    (unless (and (boundp 'mcp-server-lib--running)
                 mcp-server-lib--running)
      (mcp-server-lib-start))
    (message "MCP server %s is running" jwm/mcp-live-emacs-server-id))

  (defun jwm/mcp-live-emacs-stop ()
    "Stop the `live-emacs' MCP server."
    (interactive)
    (require 'mcp-server-lib)
    (when (and (boundp 'mcp-server-lib--running)
               mcp-server-lib--running)
      (mcp-server-lib-stop))
    (message "MCP server %s is stopped" jwm/mcp-live-emacs-server-id)))

(use-package ghostel
  :commands (ghostel ghostel-project))

(use-package claude-code-ide
  :if (executable-find "claude")
  :bind (:map jwm/ai-map ("c" . claude-code-ide-menu))
  :custom
  (claude-code-ide-terminal-backend 'ghostel)
  (claude-code-ide-cli-extra-flags
   (concat "--settings " (shell-quote-argument jwm/claude-code-hooks-file)))
  :config
  (claude-code-ide-emacs-tools-setup)
  (advice-add 'claude-code-ide--create-terminal-session
              :around #'jwm/claude-code-ide-add-buffer-name))

(defconst jwm/claude-code-hooks-file
  (expand-file-name "claude-code-ide-hooks.json"
                    (file-name-directory
                     (file-truename (or load-file-name buffer-file-name))))
  "Claude Code settings file holding the session status hooks.")

(defun jwm/claude-code-ide-add-buffer-name (orig-fn buffer-name &rest args)
  "Call ORIG-FN with CLAUDE_BUFFER_NAME=BUFFER-NAME in the environment.
ARGS are passed through.  Advises `claude-code-ide--create-terminal-session'."
  (let ((process-environment
         (if (stringp buffer-name)
             (cons (concat "CLAUDE_BUFFER_NAME=" buffer-name)
                   process-environment)
           process-environment)))
    (apply orig-fn buffer-name args)))

;; Adapted from claude-code.el 03199df, Copyright Stephen Molitor,
;; Apache License 2.0.
(defvar jwm/claude-code-event-hook nil
  "Hook run when a Claude Code session hook calls Emacs.
Each function gets one plist with :type, :buffer-name, :json-data
and :args.")

(defvar server-eval-args-left)

(defun jwm/claude-code-handle-hook (type buffer-name &rest args)
  "Run `jwm/claude-code-event-hook' for event TYPE from BUFFER-NAME.
Called through `emacsclient --eval' with the hook's JSON as the next
argument; ARGS and any further arguments are passed along."
  ;; Consume every argument, or the server evaluates the rest as Lisp.
  (let ((json-data (pop server-eval-args-left))
        (extra-args (prog1 server-eval-args-left
                      (setq server-eval-args-left nil))))
    (run-hook-with-args 'jwm/claude-code-event-hook
                        (list :type type
                              :buffer-name buffer-name
                              :json-data json-data
                              :args (append args extra-args)))
    nil))

(defun jwm/claude-code--pulse-mode-line ()
  "Flash the mode line twice."
  (dolist (delay '(0 0.1 0.2 0.3))
    (run-at-time delay nil #'invert-face 'mode-line)))

(defun jwm/claude-code--macos-notify (title body)
  "Post a macOS notification with TITLE and BODY."
  (when (and (eq system-type 'darwin) (executable-find "osascript"))
    (make-process
     :name "claude-code-notify"
     :noquery t
     :command (list "osascript"
                    "-e" "on run argv"
                    "-e" "display notification (item 2 of argv) with title (item 1 of argv)"
                    "-e" "end run"
                    title body))))

(defun jwm/claude-code-session-status (event)
  "Show the session status EVENT from `jwm/claude-code-event-hook'."
  (let* ((type (plist-get event :type))
         (buffer-name (plist-get event :buffer-name))
         (detail (ignore-errors
                   (gethash "message"
                            (json-parse-string (plist-get event :json-data)))))
         (status (pcase type
                   ('permission "needs permission")
                   ('idle "is waiting for input")
                   ('stop "finished its turn")
                   ('prompt "is working")
                   ('session-end "ended")
                   (_ (format "sent %s" type)))))
    (message "Claude %s: %s%s" status buffer-name
             (if detail (concat " — " detail) ""))
    (unless (eq type 'prompt)
      (jwm/claude-code--pulse-mode-line))
    (when (memq type '(permission idle))
      (jwm/claude-code--macos-notify
       (concat "Claude " status)
       (if detail (concat buffer-name ": " detail) buffer-name)))))

(add-hook 'jwm/claude-code-event-hook #'jwm/claude-code-session-status)

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
  (setq-default js-indent-level 2
                js2-global-externs (list "window" "module" "require" "buster" "sinon" "assert" "refute" "setTimeout" "clearTimeout" "setInterval" "clearInterval" "location" "__dirname" "console" "JSON" "jQuery" "$"))
  (add-to-list 'auto-mode-alist '("\\.js$" . js2-mode))
  (add-to-list 'auto-mode-alist '("\\.es6$" . js2-mode)))

(use-package json-mode)

(use-package yaml-mode
  :mode ("\\.ya?ml\\'" . yaml-mode))

(use-package outline-indent
  :hook
  ((yaml-mode yaml-ts-mode python-mode python-ts-mode) . outline-indent-minor-mode)
  :bind
  (:map outline-indent-minor-mode-map
        ("C-c o t" . outline-indent-toggle-fold)
        ("C-c o c" . outline-indent-close-fold)
        ("C-c o o" . outline-indent-open-fold)
        ("C-c o m" . outline-indent-close-folds)
        ("C-c o r" . outline-indent-open-folds)))

(use-package jsonnet-mode)

(use-package go-mode
  :ensure t
  :hook
  ((go-mode go-ts-mode) . eglot-ensure))

(reformatter-define goimports-format
  :program "goimports")

(add-hook 'go-mode-hook    #'goimports-format-on-save-mode)
(add-hook 'go-ts-mode-hook #'goimports-format-on-save-mode)

(use-package rust-ts-mode
       :ensure nil  ; built-in
       :preface
       (defun jwm/rust-set-compile-command ()
         "Default `compile-command' to a Cargo check in Rust buffers.
Makes `project-compile' (\\[project-compile]) pre-fill \"cargo check\"
instead of the global \"make -k\".  Still editable at the prompt for
--workspace, cargo test, etc."
         (setq-local compile-command "cargo check "))
       :hook
       (((rust-mode rust-ts-mode) . eglot-ensure)
        ((rust-mode rust-ts-mode) . jwm/rust-set-compile-command))
       :bind
       (:map rust-ts-mode-map
             ("C-c r f" . eglot-format-buffer)))

(use-package compile
  :ensure nil  ; built-in
  :config
  (add-to-list 'compilation-error-regexp-alist-alist
               '(jwm/cargo-rust
                 "^[[:space:]]*-->[[:space:]]+\\([^:\\n]+\\):\\([0-9]+\\):\\([0-9]+\\)"
                 1 2 3))
  (add-to-list 'compilation-error-regexp-alist 'jwm/cargo-rust))

(setq treesit-font-lock-level 4)  ; maximum fontification

;; When a grammar is present, remap the legacy mode (for
;; languages where a legacy mode exists) or wire auto-mode-alist
;; directly (for languages with no legacy mode) to the
;; tree-sitter variant.
(when (treesit-ready-p 'python t)
  (add-to-list 'major-mode-remap-alist '(python-mode . python-ts-mode)))

(when (treesit-ready-p 'json t)
  (add-to-list 'major-mode-remap-alist '(json-mode . json-ts-mode)))

(when (treesit-ready-p 'yaml t)
  (add-to-list 'major-mode-remap-alist '(yaml-mode . yaml-ts-mode)))

;; toml has no legacy mode in this config; wire the extension
;; directly to the tree-sitter mode.
(when (treesit-ready-p 'toml t)
  (add-to-list 'auto-mode-alist '("\\.toml\\'" . toml-ts-mode)))

(when (treesit-ready-p 'go t)
  (add-to-list 'major-mode-remap-alist '(go-mode . go-ts-mode)))

(when (treesit-ready-p 'dockerfile t)
  (add-to-list 'major-mode-remap-alist '(dockerfile-mode . dockerfile-ts-mode)))

(when (treesit-ready-p 'javascript t)
  (add-to-list 'major-mode-remap-alist '(js2-mode . js-ts-mode)))

(when (treesit-ready-p 'just t)
  (add-to-list 'major-mode-remap-alist '(just-mode . just-ts-mode)))

;; Rust has no legacy mode configured here.  Associate its extension
;; directly once the per-machine grammar is present.
(when (treesit-ready-p 'rust t)
  (add-to-list 'auto-mode-alist '("\\.rs\\'" . rust-ts-mode)))

;; Recipe for each grammar. treesit-install-language-grammar
;; looks these up when called non-interactively (e.g. from the
;; helper below). Without an entry, it errors with
;; "Cannot find recipe for this language".
(dolist (source
         '((python     "https://github.com/tree-sitter/tree-sitter-python")
           (json       "https://github.com/tree-sitter/tree-sitter-json")
           (yaml       "https://github.com/ikatyang/tree-sitter-yaml")
           (toml       "https://github.com/ikatyang/tree-sitter-toml")
           (go         "https://github.com/tree-sitter/tree-sitter-go")
           (dockerfile "https://github.com/camdencheek/tree-sitter-dockerfile")
           (javascript "https://github.com/tree-sitter/tree-sitter-javascript" "master" "src")
           (just       "https://github.com/IndianBoy42/tree-sitter-just")
           (rust       "https://github.com/tree-sitter/tree-sitter-rust")))
  (add-to-list 'treesit-language-source-alist source))

(defvar jwm/required-treesit-grammars
  '(python json toml yaml go dockerfile javascript just rust)
  "Languages for which this config wants tree-sitter grammars.
Add to this list as sub-goals add more -ts-mode remaps.")

(defun jwm/ensure-treesit-grammars ()
  "Install any grammars in `jwm/required-treesit-grammars' that aren't present.
Idempotent; safe to run on every machine after config clone."
  (interactive)
  (dolist (lang jwm/required-treesit-grammars)
    (unless (treesit-ready-p lang t)  ; t = silent check
      (message "Installing tree-sitter grammar for %s..." lang)
      (treesit-install-language-grammar lang))))

(use-package python
  :ensure nil  ; built-in
  :custom
  (python-shell-interpreter "python3")
  :hook
  ((python-mode python-ts-mode) . eglot-ensure))

(use-package reformatter)

(reformatter-define ruff-format
  :program "ruff"
  :args `("format" "--stdin-filename" ,(or buffer-file-name "stdin.py") "-"))

(use-package flymake-ruff
  :hook ((python-mode python-ts-mode) . flymake-ruff-load))

(add-hook 'python-mode-hook    #'ruff-format-on-save-mode)
(add-hook 'python-ts-mode-hook #'ruff-format-on-save-mode)

(use-package pet
  :config
  (add-hook 'python-base-mode-hook #'pet-mode -10))

(use-package eglot
  :ensure nil  ; built-in
  :custom
  (eglot-autoshutdown t)
  :config
  (add-to-list 'eglot-server-programs
               '((python-mode python-ts-mode)
                 . ("ty" "server")))
  ;; Dockerfile LSP. =docker-langserver= is the binary from the
  ;; npm package =dockerfile-language-server-nodejs=; it
  ;; delegates to =hadolint= for lint diagnostics when hadolint
  ;; is on PATH.
  (add-to-list 'eglot-server-programs
               '((dockerfile-mode dockerfile-ts-mode)
                 . ("docker-langserver" "--stdio")))
  (add-to-list 'eglot-server-programs
               '(sql-mode . ("postgres-language-server" "lsp-proxy")))
  (defun jwm/dockerfile-eglot-ensure ()
    "Start Eglot for Dockerfiles when docker-langserver is available."
    (when (executable-find "docker-langserver")
      (eglot-ensure))))

(use-package flymake
  :ensure nil  ; built-in
  :hook (prog-mode . flymake-mode)
  :bind (:map flymake-mode-map
              ("C-c ! n" . flymake-goto-next-error)
              ("C-c ! p" . flymake-goto-prev-error)
              ("C-c ! l" . flymake-show-buffer-diagnostics)))

(use-package just-mode)
(use-package just-ts-mode)

(defun jwm/sql-pop-to-session ()
  "Select this buffer's SQL session buffer, with point at its end."
  (interactive)
  ;; `sql-buffer' holds the session buffer's name, not the buffer.
  (unless (sql-buffer-live-p sql-buffer)
    (sql-set-sqli-buffer))
  (when (sql-buffer-live-p sql-buffer)
    (pop-to-buffer sql-buffer)
    (goto-char (point-max))))

(defun jwm/sql-font-lock-everything ()
  "Highlight session output as well as input."
  (sql-product-font-lock nil nil))

(defun jwm/sql-eglot-ensure ()
  "Start Eglot for SQL when postgres-language-server is installed."
  (when (executable-find "postgres-language-server")
    (eglot-ensure)))

(use-package sql
  :ensure nil
  :custom
  (sql-product 'postgres)
  (sql-postgres-login-params '(user))
  (sql-input-ring-file-name (locate-user-emacs-file ".sqli_history"))
  :bind (:map sql-mode-map ("C-c C-z" . jwm/sql-pop-to-session))
  :hook ((sql-interactive-mode . jwm/sql-font-lock-everything)
         (sql-mode . jwm/sql-eglot-ensure))
  :config
  ;; A customized ~/.psqlrc prompt breaks sql-interactive-mode's prompt matching.
  (add-to-list 'sql-postgres-options "--no-psqlrc" t))

(when (executable-find "pg_format")
  (require 'reformatter)
  (reformatter-define pg-format
    :program "pg_format"
    :args '("-"))

  (defun jwm/pg-format-dwim ()
    "Format the active region with pg_format, or the whole buffer."
    (interactive)
    (if (use-region-p)
        (pg-format-region (region-beginning) (region-end))
      (pg-format-buffer)))

  (with-eval-after-load 'sql
    (keymap-set sql-mode-map "C-c C-f" #'jwm/pg-format-dwim)))

(defconst jwm/pg-tool-max-rows 200
  "CSV rows, after the header, a PostgreSQL tool shows Claude.")

(defconst jwm/pg-tool-max-bytes (* 64 1024)
  "Bytes of psql output a PostgreSQL tool shows Claude.")

(defconst jwm/pg-tool-timeout 35
  "Seconds before Emacs kills a PostgreSQL tool's psql.")

(defconst jwm/pg-tool-pgoptions "-c statement_timeout=30s -c lock_timeout=5s"
  "Server-side limits for every PostgreSQL tool call.")

(defun jwm/pg-tool-environment (dir login-var)
  "Return (PSQL . ENVIRONMENT) for running psql as one of DIR's agent logins.
LOGIN-VAR names the mise variable holding the login.  Signal
`user-error' when DIR's mise environment does not set it."
  (let* ((default-directory dir)
         (env (with-temp-buffer
                (when (and (executable-find "mise")
                           (eq 0 (call-process "mise" nil '(t nil) nil
                                               "env" "--json")))
                  (json-parse-string (buffer-string) :object-type 'alist))))
         (user (alist-get (intern login-var) env))
         (psql (let ((exec-path (append (split-string (or (alist-get 'PATH env) "")
                                                      path-separator t)
                                        exec-path)))
                 (executable-find "psql"))))
    (when (or (null user) (string-empty-p user))
      (user-error "%s is not set in the mise environment of %s; \
it names the login this PostgreSQL tool runs as"
                  login-var (abbreviate-file-name dir)))
    (unless psql
      (user-error "No psql on %s's PATH" (abbreviate-file-name dir)))
    (cons psql
          (append (list (concat "PGUSER=" user)
                        (concat "PGOPTIONS=" jwm/pg-tool-pgoptions))
                  (mapcar (lambda (kv) (format "%s=%s" (car kv) (cdr kv))) env)
                  process-environment))))

(defun jwm/pg-tool-cut (output)
  "Return (TEXT . CUT) for OUTPUT, a unibyte string of psql CSV output.
TEXT keeps the header and `jwm/pg-tool-max-rows' rows, within
`jwm/pg-tool-max-bytes'; CUT is non-nil when anything was dropped."
  (let ((end (length output))
        (records 0)
        (quoted nil)
        (i 0))
    ;; Count records, not lines: a quoted CSV field may hold newlines.
    (while (< i end)
      (pcase (aref output i)
        (?\" (setq quoted (not quoted)))
        (?\n (unless quoted
               (setq records (1+ records))
               (when (> records jwm/pg-tool-max-rows)
                 (setq end (1+ i))))))
      (setq i (1+ i)))
    (setq end (min end jwm/pg-tool-max-bytes))
    (cons (decode-coding-string (substring output 0 end) 'utf-8)
          (< end (length output)))))

(defun jwm/pg-tool-run (dir login-var sql args callback)
  "Run SQL through psql as the DIR login in LOGIN-VAR, with extra psql ARGS.
CALLBACK runs exactly once, with the text to show Claude."
  (pcase-let* ((`(,psql . ,env) (jwm/pg-tool-environment dir login-var))
               (default-directory dir)
               (process-environment env)
               (chunks nil)
               (size 0)
               (done nil)
               (timer nil)
               (proc nil))
    (let ((finish
           (lambda (text)
             (unless done
               (setq done t)
               (when timer (cancel-timer timer))
               (when (process-live-p proc) (delete-process proc))
               (funcall callback text))))
          (result
           (lambda (status)
             (pcase-let ((`(,text . ,cut)
                          (jwm/pg-tool-cut (apply #'concat (reverse chunks)))))
               (concat (unless (eq status 0)
                         (format "psql exited with status %s:\n" status))
                       text
                       (when cut
                         (format "\n[Result cut off: at most %d rows and %d KB are shown.]"
                                 jwm/pg-tool-max-rows
                                 (/ jwm/pg-tool-max-bytes 1024))))))))
      (setq proc
            (make-process
             :name "jwm-pg-tool"
             :command (append (list psql "-X" "--csv" "--no-password"
                                    "-v" "ON_ERROR_STOP=1")
                              args)
             :connection-type 'pipe
             :coding 'no-conversion
             :noquery t
             :filter (lambda (_p string)
                       (push string chunks)
                       (setq size (+ size (length string)))
                       ;; Enough to fill the cap: stop reading.
                       (when (> size jwm/pg-tool-max-bytes)
                         (funcall finish (funcall result 0))))
             :sentinel (lambda (p _event)
                         (when (memq (process-status p) '(exit signal))
                           (funcall finish (funcall result (process-exit-status p)))))))
      (setq timer
            (run-at-time jwm/pg-tool-timeout nil
                         (lambda ()
                           (funcall finish
                                    (format "Error: psql was stopped after %d seconds; \
the statement did not finish." jwm/pg-tool-timeout)))))
      (process-send-string proc (encode-coding-string sql 'utf-8))
      (process-send-string proc "\n")
      (process-send-eof proc)
      proc)))

(defvar jwm/pg-tool--request nil
  "The web-server request of the MCP call being handled, or nil.")

(defun jwm/pg-tool-capture-request (orig request)
  "Call ORIG with REQUEST, keeping REQUEST where the PostgreSQL tools see it."
  (let ((jwm/pg-tool--request request))
    (funcall orig request)))

(declare-function ws-process "web-server")
(declare-function ws-body "web-server")
(declare-function ws-send "web-server")
(declare-function ws-response-header "web-server")
(declare-function claude-code-ide-mcp-server-get-session-context "claude-code-ide-mcp-server")
(declare-function claude-code-ide-make-tool "claude-code-ide-mcp-server")

(defun jwm/pg-tool-answer (request text)
  "Answer the MCP tools/call REQUEST with TEXT, then close its connection."
  (let ((proc (ws-process request)))
    (when (process-live-p proc)
      (let ((id (alist-get 'id (json-parse-string (ws-body request)
                                                  :object-type 'alist))))
        (ws-response-header proc 200 '("Content-Type" . "application/json"))
        (ws-send proc (json-encode
                       `((jsonrpc . "2.0")
                         (id . ,id)
                         (result (content . [((type . "text") (text . ,text))])))))
        (with-slots (requests) (plist-get (process-plist proc) :server)
          (setq requests (delq request requests)))
        (delete-process proc)))))

(defun jwm/pg-tool-call-as (login-var sql &rest args)
  "Run SQL as the login in LOGIN-VAR, with extra psql ARGS, for the calling session."
  (let ((dir (or (plist-get (claude-code-ide-mcp-server-get-session-context)
                            :project-dir)
                 default-directory))
        (request jwm/pg-tool--request))
    (if request
        (progn
          (jwm/pg-tool-run dir login-var sql args
                           (lambda (text) (jwm/pg-tool-answer request text)))
          ;; Leave the HTTP request open; the callback answers it.
          (throw 'close-connection :keep-alive))
      (let ((answer nil))
        (jwm/pg-tool-run dir login-var sql args (lambda (text) (setq answer text)))
        (while (not answer)
          (accept-process-output nil 0.1))
        answer))))

(defun jwm/pg-tool-call (sql &rest args)
  "Run SQL, with extra psql ARGS, as the read login of the calling session."
  (apply #'jwm/pg-tool-call-as "PGUSER_AGENT" sql args))

(defconst jwm/pg-tool-list-relations-sql
  "select n.nspname as schema, c.relname as name,
       case c.relkind when 'r' then 'table' when 'p' then 'partitioned table'
                      when 'v' then 'view' when 'm' then 'materialized view'
                      when 'f' then 'foreign table' end as kind,
       pg_catalog.obj_description(c.oid, 'pg_class') as comment
from pg_catalog.pg_class c
join pg_catalog.pg_namespace n on n.oid = c.relnamespace
where c.relkind in ('r', 'p', 'v', 'm', 'f')
  and n.nspname not in ('pg_catalog', 'information_schema')
  and n.nspname not like 'pg_toast%'
order by 1, 2"
  "Every table and view outside the system schemas.")

(defconst jwm/pg-tool-describe-relation-sql
  "select kind, name, definition from (
  select 1 as part, a.attnum as pos, 'column' as kind, a.attname::text as name,
         pg_catalog.format_type(a.atttypid, a.atttypmod)
         || case when a.attnotnull then ' not null' else '' end
         || coalesce(' default ' || pg_catalog.pg_get_expr(d.adbin, d.adrelid), '')
         as definition
  from pg_catalog.pg_attribute a
  left join pg_catalog.pg_attrdef d on d.adrelid = a.attrelid and d.adnum = a.attnum
  where a.attrelid = :'rel'::regclass and a.attnum > 0 and not a.attisdropped
  union all
  select 2, 0, 'constraint', conname::text, pg_catalog.pg_get_constraintdef(oid)
  from pg_catalog.pg_constraint where conrelid = :'rel'::regclass
  union all
  select 3, 0, 'index', c.relname::text, pg_catalog.pg_get_indexdef(i.indexrelid)
  from pg_catalog.pg_index i join pg_catalog.pg_class c on c.oid = i.indexrelid
  where i.indrelid = :'rel'::regclass
) parts order by part, pos, name"
  "Columns, constraints and indexes of the relation in psql variable rel.")

(defun jwm/pg-tool-describe-schema (&optional table)
  "Describe TABLE, or list every table and view when TABLE is nil."
  (if (and (stringp table) (not (string-empty-p table)))
      (jwm/pg-tool-call jwm/pg-tool-describe-relation-sql "-v" (concat "rel=" table))
    (jwm/pg-tool-call jwm/pg-tool-list-relations-sql)))

(defun jwm/pg-tool-run-query (query)
  "Run QUERY as the agent login."
  (jwm/pg-tool-call query))

(defun jwm/pg-tool-explain (query &optional analyze)
  "Return the plan for QUERY; with ANALYZE, run it and include timings."
  ;; JSON false arrives as :false, which is non-nil.
  (jwm/pg-tool-call (concat (if (eq analyze t) "EXPLAIN (ANALYZE) " "EXPLAIN ")
                            query)))

(defun jwm/pg-tool-run-write (statements)
  "Run STATEMENTS in one transaction as the agent writer login."
  (jwm/pg-tool-call-as "PGUSER_AGENT_WRITE" statements "--single-transaction"))

(defun jwm/pg-tools-register ()
  "Register the PostgreSQL tools with claude-code-ide's tool server."
  (claude-code-ide-make-tool
   :function #'jwm/pg-tool-describe-schema
   :name "pg_describe_schema"
   :description "Describe the project's PostgreSQL database. With no table, \
list every table and view (schema, name, kind, comment). With a table, list its \
columns, constraints and indexes. Output is CSV."
   :args '((:name "table" :type string :optional t
            :description "Table or view, optionally schema-qualified (nyse.factbook)")))
  (claude-code-ide-make-tool
   :function #'jwm/pg-tool-run-query
   :name "pg_run_query"
   :description "Run SQL against the project's PostgreSQL database and return the \
result as CSV. Runs as the project's agent login, whose grants decide what is \
allowed. Statements time out after 30 seconds; at most 200 rows and 64 KB come back, \
with a note when the result was cut off."
   :args '((:name "query" :type string :description "The SQL to run")))
  (claude-code-ide-make-tool
   :function #'jwm/pg-tool-explain
   :name "pg_explain"
   :description "Show PostgreSQL's EXPLAIN plan for a query in the project's \
database. With analyze true the query is executed (EXPLAIN ANALYZE), so use it only \
for statements that are safe to run."
   :args '((:name "query" :type string :description "The statement to explain")
           (:name "analyze" :type boolean :optional t
            :description "Run the statement and report actual timings")))
  (claude-code-ide-make-tool
   :function #'jwm/pg-tool-run-write
   :name "pg_run_write"
   :description "Change rows in the project's PostgreSQL database: insert, update, \
delete, or a query that calls a function which writes. Runs as the project's agent \
writer login, whose grants decide what is allowed; it cannot change the schema, which \
is done with Sqitch changes instead. The statements run in one transaction that \
commits when they all succeed; an error rolls all of them back. Returns psql's CSV \
output, including command tags such as INSERT 0 1 and any RETURNING rows, with the \
same 30 second timeout and 200 row / 64 KB limit as pg_run_query. pg_run_query runs \
as a read-only login and cannot write."
   :args '((:name "statements" :type string
            :description "The SQL to run; separate several statements with semicolons"))))

(with-eval-after-load 'claude-code-ide-mcp-server
  (jwm/pg-tools-register))

(with-eval-after-load 'claude-code-ide-mcp-http-server
  (advice-add 'claude-code-ide-mcp-http-server--handle-post
              :around #'jwm/pg-tool-capture-request))

(use-package terraform-mode
  :mode "\.tf\\'")

(use-package editorconfig
  :ensure nil  ; built-in since Emacs 30
  :config
  (editorconfig-mode 1))

(use-package envrc
  :hook (after-init . envrc-global-mode))

(use-package mise
  :if (executable-find "mise")
  :custom
  (mise-trust nil)
  :config
  (setq mise-exclude-predicate
        (lambda () (or (eq (bound-and-true-p envrc--status) 'on)
                       (mise-default-exclude))))
  :hook (after-init . global-mise-mode))

(defun jwm/mise-project-config ()
  "Return the closest mise config for `default-directory' that is not global."
  (let ((global (file-name-as-directory (expand-file-name "~/.config/mise"))))
    (with-temp-buffer
      (when (eq 0 (ignore-errors
                    (call-process "mise" nil '(t nil) nil "config" "ls" "--json")))
        (seq-find (lambda (f) (not (string-prefix-p global f)))
                  (mapcar (lambda (c) (expand-file-name (alist-get 'path c)))
                          (ignore-errors
                            (json-parse-string (buffer-string)
                                               :object-type 'alist
                                               :array-type 'list))))))))

(defvar jwm/mise-envrc-warned nil
  "Projects already warned about having both a .envrc and a mise config.")

(defun jwm/envrc-yield-to-mise (orig &optional arg)
  "Keep `envrc-mode' off where a project mise config applies too."
  (let ((envrc-dir (and (eql arg 1)
                        (executable-find "mise")
                        (not (file-remote-p default-directory))
                        (locate-dominating-file default-directory ".envrc")))
        (mise-config nil))
    (if (and envrc-dir (setq mise-config (jwm/mise-project-config)))
        (unless (member envrc-dir jwm/mise-envrc-warned)
          (push envrc-dir jwm/mise-envrc-warned)
          (display-warning
           'mise
           (format "%s has both %s.envrc and %s; using mise"
                   (abbreviate-file-name envrc-dir)
                   (abbreviate-file-name envrc-dir)
                   (abbreviate-file-name mise-config))))
      (funcall orig arg))))

(advice-add 'envrc-mode :around #'jwm/envrc-yield-to-mise)

(defun jwm/mise-refresh ()
  "Re-read mise for every buffer, then restart the Eglot servers they use.
Run after changing a project's mise settings, e.g. `just point-tools'."
  (interactive)
  (mise-update-dir t)
  (let ((managed (seq-filter (lambda (b) (with-current-buffer b (eglot-managed-p)))
                             (buffer-list))))
    (dolist (server (delete-dups (mapcar (lambda (b)
                                           (with-current-buffer b (eglot-current-server)))
                                         managed)))
      (eglot-shutdown server))
    ;; One postgres-language-server daemon serves every project and keeps
    ;; the environment it started with.
    (when (executable-find "postgres-language-server")
      (call-process "postgres-language-server" nil nil nil "stop"))
    (dolist (b managed)
      (with-current-buffer b (eglot-ensure)))))

(use-package docker
  :bind ("C-c d" . docker)
  :diminish)

(use-package dockerfile-mode
  :mode "Dockerfile[a-zA-Z.-]*\\'"
  :hook
  ((dockerfile-mode dockerfile-ts-mode) . jwm/dockerfile-eglot-ensure))

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
