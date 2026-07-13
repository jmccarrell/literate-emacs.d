;;; cargo-compilation-tests.el --- Tests for Cargo diagnostics -*- lexical-binding: t; -*-

(require 'ert)
(require 'compile)

(load-file (expand-file-name "../init.el" (file-name-directory load-file-name)))

(ert-deftest jwm/cargo-rust-compilation-regexp-parses-human-diagnostic ()
  "Cargo's indented human diagnostic opens the reported source line."
  (let* ((root (make-temp-file "jwm-cargo-compilation-" t))
         (source (expand-file-name "member/src/lib.rs" root))
         source-buffer)
    (unwind-protect
        (progn
          (make-directory (file-name-directory source) t)
          (write-region "\n    value\n" nil source nil 'silent)
          (let ((default-directory root))
            (with-temp-buffer
              (insert "error[E0308]: mismatched types\n"
                      " --> member/src/lib.rs:2:5\n")
              (compilation-mode)
              (let ((inhibit-read-only t))
                (compilation-parse-errors (point-min) (point-max)))
              (goto-char (point-min))
              (next-error 1)
              (setq source-buffer (get-file-buffer source))
              (should source-buffer)
              (with-current-buffer source-buffer
                (should (= (line-number-at-pos) 2))
                (should (= (current-column) 4))))))
      (when source-buffer
        (kill-buffer source-buffer))
      (delete-directory root t))))

;;; cargo-compilation-tests.el ends here
