;;; gptel-tools-tests.el --- Tests for gptel's tool set -*- lexical-binding: t; -*-

(require 'ert)

(load-file (expand-file-name "../init.el" (file-name-directory load-file-name)))

(ert-deftest jwm/gptel-tools-exclude-system-tools-and-send-none-by-default ()
  "Registering by tag leaves out llm-tool-collection's shell and elisp tools,
and no tool is sent until one is chosen in `gptel-menu'."
  (skip-unless (locate-library "llm-tool-collection"))
  (require 'gptel)
  (require 'llm-tool-collection)
  (should (gptel-get-tool "grep"))
  (should-error (gptel-get-tool "bash"))
  (should-error (gptel-get-tool "eval_elisp"))
  (should-not gptel-tools))

;;; gptel-tools-tests.el ends here
