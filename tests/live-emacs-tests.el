;;; live-emacs-tests.el --- Tests for the live-emacs MCP tools -*- lexical-binding: t; -*-

(require 'ert)
(require 'json)

(load-file (expand-file-name "../init.el" (file-name-directory load-file-name)))
(require 'mcp-server-lib)

(defun jwm/live-emacs-tests--json (string)
  "Parse STRING as a JSON object into an alist."
  (let ((json-object-type 'alist)
        (json-array-type 'list)
        (json-key-type 'symbol))
    (json-read-from-string string)))

(ert-deftest jwm/live-emacs-eval-returns-printed-value ()
  "A form's value comes back as its printed representation."
  (should (equal (jwm/live-emacs-eval "(+ 1 2)") "3"))
  (should (equal (jwm/live-emacs-eval "(concat \"a\" \"b\")") "\"ab\"")))

(ert-deftest jwm/live-emacs-eval-reports-failure-as-tool-error ()
  "A failing form signals `mcp-server-lib-tool-error', not a raw error.

The distinction is the contract: a tool error reaches the client as a
result with `isError', while an unhandled error would surface as a
JSON-RPC error and be indistinguishable from a broken channel."
  (should-error (jwm/live-emacs-eval "(car 5)")
                :type 'mcp-server-lib-tool-error)
  (should-error (jwm/live-emacs-eval "(jwm/live-emacs-no-such-function)")
                :type 'mcp-server-lib-tool-error))

(ert-deftest jwm/live-emacs-eval-error-carries-the-message ()
  "The flattened error message survives to the client."
  (condition-case err
      (progn (jwm/live-emacs-eval "(car 5)") (ert-fail "expected a tool error"))
    (mcp-server-lib-tool-error
     (should (string-match-p "Wrong type argument" (cadr err))))))

(ert-deftest jwm/live-emacs-state-summary-is-json-with-expected-keys ()
  "The state summary parses as JSON and names the session's basics."
  (let ((summary (jwm/live-emacs-tests--json (jwm/live-emacs-state-summary))))
    (dolist (key '(buffer major_mode default_directory emacs_version read_only))
      (should (assq key summary)))
    (should (equal (alist-get 'emacs_version summary) emacs-version))))

(ert-deftest jwm/live-emacs-key-binding-resolves-a-known-binding ()
  "A bound key reports its command; an unbound one says so rather than erroring."
  (let ((bound (jwm/live-emacs-tests--json (jwm/live-emacs-key-binding "C-f"))))
    (should (equal (alist-get 'command bound) "forward-char"))
    (should (equal (alist-get 'command_type bound) "symbol")))
  (let ((junk (jwm/live-emacs-tests--json (jwm/live-emacs-key-binding "no-such-key"))))
    (should (assq 'error junk))))

(ert-deftest jwm/live-emacs-library-status-distinguishes-known-from-unknown ()
  "A loaded feature reports as known and loaded; a fictional one as neither."
  (let ((known (jwm/live-emacs-tests--json (jwm/live-emacs-library-status "json"))))
    (should (eq (alist-get 'feature_known known) t))
    (should (eq (alist-get 'feature_loaded known) t)))
  (let ((unknown (jwm/live-emacs-tests--json
                  (jwm/live-emacs-library-status "jwm-no-such-library"))))
    (should-not (eq (alist-get 'feature_loaded unknown) t))))

(ert-deftest jwm/live-emacs-registers-its-four-tools ()
  "Registration is idempotent and covers the documented surface."
  (let ((jwm/live-emacs-tools-registered nil))
    (jwm/live-emacs-register-tools)
    (jwm/live-emacs-register-tools)
    (should (equal (sort (copy-sequence jwm/live-emacs-tools-registered) #'string<)
                   '("elisp_eval" "emacs_key_binding"
                     "emacs_library_status" "emacs_state_summary")))))

(provide 'live-emacs-tests)
;;; live-emacs-tests.el ends here
