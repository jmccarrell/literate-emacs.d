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

(setq user-full-name "Jeff McCarrell"
      user-mail-address (cond
                         (t "jeff@mccarrell.org")))

(when (window-system)
  (server-start))

(require 'package)

(unless (assoc-default "org" package-archives)
  (add-to-list 'package-archives '("org" . "https://orgmode.org/elpa/") t))
(unless (assoc-default "melpa" package-archives)
  (add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t))

(package-initialize)

(setq use-package-verbose t)
(setq use-package-always-ensure t)
(require 'use-package)

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
  (let (f (selected-frame))
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

(global-set-key (kbd "M-[") 'insert-pair)
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
  ;; prefer to show the entire command name with no truncation.
  ;;  some of those projectile command names exceed the default value of 27, eg
  ;;  projectile-toggle-between-implementation-and-test
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

(use-package projectile
  :diminish projectile-mode
  :commands (projectile-mode projectile-switch-project)
  :bind (("C-c p p" . projectile-switch-project))
  :init
  (setq projectile-completion-system 'default)
  :config
  (define-key projectile-mode-map (kbd "s-p") 'projectile-command-map)
  (define-key projectile-mode-map (kbd "C-c p") 'projectile-command-map)
  (setq projectile-keymap-prefix (kbd "C-c p"))
  (projectile-global-mode t))

(use-package savehist
  :ensure nil
  :init (savehist-mode))

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

(use-package magit
  :defer t
  :bind ("C-x g" . magit-status))

(bind-keys
 ;; org mode wants these default global bindings set up.
 ("C-c l" . org-store-link)
 ("C-c c" . org-capture)
 ("C-c a" . org-agenda))

(setq org-directory
      (cond (t "~/jwm/todo")))

;; The default place to put notes for capture mode
(setq org-default-notes-file
      (concat org-directory
              (cond (t "/todo.org"))))

;; where I store periodic reminders, ie, ticklers in GTD-talk
(defvar jwm/org-tickler-file (concat org-directory "/tickler.org"))

(setq org-agenda-files (jwm/emacs-subdirectory "org-agenda-files-list"))

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

(use-package gptel
  :commands (gptel gptel-send gptel-menu)
  :bind (("C-c g g" . gptel)
         ("C-c g s" . gptel-send)
         ("C-c g m" . gptel-menu))
  :init
  (defvar jwm/gptel-anthropic-host "api.anthropic.com"
    "Auth-source host for the Anthropic API key.")

  (defvar jwm/gptel-claude-model 'claude-sonnet-4-5-20250929
    "Selectable Claude model for gptel.")

  (defvar jwm/gptel-ollama-host "localhost:11434"
    "Host for the local Ollama gptel backend.")

  (defvar jwm/gptel-gemma4-model 'gemma4:26b
    "Fallback local Gemma 4 model for gptel.")

  (defvar jwm/gptel-qwen-mlx-model 'qwen3.5:35b-a3b-coding-nvfp4
    "Default local Qwen MLX model for gptel.")

  (defun jwm/gptel-auth-source-password (host)
    "Return the first auth-source password for HOST."
    (require 'auth-source)
    (or (auth-source-pick-first-password :host host)
        (user-error "No auth-source password found for %s" host)))

  :config
  (setq gptel-default-mode 'org-mode
        gptel-include-reasoning nil)
  (gptel-make-anthropic "Claude"
    :stream t
    :key (lambda ()
           (jwm/gptel-auth-source-password jwm/gptel-anthropic-host))
    :models (list jwm/gptel-claude-model))
  (gptel-make-ollama "Ollama Gemma 4"
    :host jwm/gptel-ollama-host
    :stream t
    :models (list jwm/gptel-gemma4-model))
  (setq gptel-model jwm/gptel-qwen-mlx-model)
  (setq gptel-backend
        (gptel-make-ollama "Ollama Qwen MLX"
          :host jwm/gptel-ollama-host
          :stream t
          :models (list jwm/gptel-qwen-mlx-model)))

  (with-eval-after-load 'which-key
    (which-key-add-key-based-replacements "C-c g" "gptel")))

(use-package mcp-server-lib
  :commands (mcp-server-lib-install
             mcp-server-lib-start
             mcp-server-lib-stop
             mcp-server-lib-register-tool)
  :init
  (defvar jwm/emacs-mcp-server-id "jwm-emacs"
    "MCP server identifier for Jeff's read-only Emacs tools.")

  (defvar jwm/emacs-mcp-tools-registered nil
    "List of Jeff read-only Emacs MCP tool IDs registered in this session.")

  (defun jwm/emacs-mcp--json-false (value)
    "Return VALUE as a JSON boolean value."
    (if value t :json-false))

  (defun jwm/emacs-mcp--first-doc-line (symbol)
    "Return the first documentation line for SYMBOL, or nil."
    (when (symbolp symbol)
      (let ((doc (documentation symbol t)))
        (when (stringp doc)
          (car (split-string doc "\n" t))))))

  (defun jwm/emacs-mcp--register-tool (handler &rest properties)
    "Register HANDLER with PROPERTIES once for this Emacs session."
    (require 'mcp-server-lib)
    (when (eq jwm/emacs-mcp-tools-registered t)
      (setq jwm/emacs-mcp-tools-registered '("emacs_state_summary")))
    (let ((id (plist-get properties :id)))
      (unless (member id jwm/emacs-mcp-tools-registered)
        (apply #'mcp-server-lib-register-tool handler properties)
        (add-to-list 'jwm/emacs-mcp-tools-registered id))))

  (defun jwm/emacs-mcp-state-summary ()
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

  (defun jwm/emacs-mcp-key-binding (key)
    "Return read-only JSON metadata about KEY's active binding.

MCP Parameters:
  key - Emacs key sequence accepted by `kbd', for example C-c g g"
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
             ("command_doc_summary" . ,(jwm/emacs-mcp--first-doc-line command-symbol))
             ("read_only" . t))))
      (error
       (json-encode
        `(("key" . ,key)
          ("error" . ,(error-message-string err))
          ("read_only" . t))))))

  (defun jwm/emacs-mcp-library-status (library)
    "Return read-only JSON metadata about LIBRARY or feature name.

MCP Parameters:
  library - feature or library name, for example gptel or json"
    (require 'json)
    (let* ((feature (intern-soft library))
           (loaded (and feature (featurep feature)))
           (path (locate-library library)))
      (json-encode
       `(("library" . ,library)
         ("feature_known" . ,(jwm/emacs-mcp--json-false feature))
         ("feature_loaded" . ,(jwm/emacs-mcp--json-false loaded))
         ("library_path" . ,path)
         ("read_only" . t)))))

  (defun jwm/emacs-mcp-register-tools ()
    "Register Jeff's read-only Emacs MCP tools."
    (interactive)
    (require 'mcp-server-lib)
    (jwm/emacs-mcp--register-tool
     #'jwm/emacs-mcp-state-summary
     :id "emacs_state_summary"
     :description "Return read-only metadata about the current Emacs session."
     :title "Emacs State Summary"
     :read-only t
     :server-id jwm/emacs-mcp-server-id)
    (jwm/emacs-mcp--register-tool
     #'jwm/emacs-mcp-key-binding
     :id "emacs_key_binding"
     :description "Return the active command bound to an Emacs key sequence."
     :title "Emacs Key Binding"
     :read-only t
     :server-id jwm/emacs-mcp-server-id)
    (jwm/emacs-mcp--register-tool
     #'jwm/emacs-mcp-library-status
     :id "emacs_library_status"
     :description "Return loaded feature status and library path for an Emacs library name."
     :title "Emacs Library Status"
     :read-only t
     :server-id jwm/emacs-mcp-server-id))

  (defun jwm/emacs-mcp-start ()
    "Start Jeff's read-only Emacs MCP server."
    (interactive)
    (require 'mcp-server-lib)
    (jwm/emacs-mcp-register-tools)
    (unless (and (boundp 'mcp-server-lib--running)
                 mcp-server-lib--running)
      (mcp-server-lib-start))
    (message "Emacs MCP server %s is running" jwm/emacs-mcp-server-id))

  (defun jwm/emacs-mcp-stop ()
    "Stop Jeff's read-only Emacs MCP server."
    (interactive)
    (require 'mcp-server-lib)
    (when (and (boundp 'mcp-server-lib--running)
               mcp-server-lib--running)
      (mcp-server-lib-stop))
    (message "Emacs MCP server %s is stopped" jwm/emacs-mcp-server-id)))

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

(use-package jsonnet-mode)

(use-package go-mode
  :ensure t
  :hook
  ((go-mode go-ts-mode) . eglot-ensure))

(reformatter-define goimports-format
  :program "goimports")

(add-hook 'go-mode-hook    #'goimports-format-on-save-mode)
(add-hook 'go-ts-mode-hook #'goimports-format-on-save-mode)

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
           (just       "https://github.com/IndianBoy42/tree-sitter-just")))
  (add-to-list 'treesit-language-source-alist source))

(defvar jwm/required-treesit-grammars
  '(python json toml yaml go dockerfile javascript just)
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
                 . ("docker-langserver" "--stdio"))))

(use-package flymake
  :ensure nil  ; built-in
  :hook (prog-mode . flymake-mode)
  :bind (:map flymake-mode-map
              ("C-c ! n" . flymake-goto-next-error)
              ("C-c ! p" . flymake-goto-prev-error)
              ("C-c ! l" . flymake-show-buffer-diagnostics)))

(use-package just-mode)
(use-package just-ts-mode)

(use-package terraform-mode
  :mode "\.tf\\'")

(use-package editorconfig
  :ensure nil  ; built-in since Emacs 30
  :config
  (editorconfig-mode 1))

(use-package envrc
  :hook (after-init . envrc-global-mode))

(use-package docker
  :bind ("C-c d" . docker)
  :diminish)

(use-package dockerfile-mode
  :mode "Dockerfile[a-zA-Z.-]*\\'"
  :hook
  ((dockerfile-mode dockerfile-ts-mode) . eglot-ensure))

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
