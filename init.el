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

(defun jwm/personal-mac-p ()
  (and (eq 'darwin system-type)
       (file-exists-p "/j/pdata/.gitignore")))

(defun jwm/sift-mac-p ()
  (file-exists-p (expand-file-name "~/code/java/build.gradle")))

(setq user-full-name "Jeff McCarrell"
      user-mail-address (cond
                         ((jwm/sift-mac-p) "jmccarrell@siftscience.com")
                         (t "jeff@mccarrell.org")))
