;;; worktree-management-tests.el --- Tests for worktree navigation -*- lexical-binding: t; -*-

(require 'ert)
(require 'cl-lib)

(load-file (expand-file-name "../init.el" (file-name-directory load-file-name)))

(ert-deftest jwm/worktree-container-directory-uses-repository-sibling ()
  "The primary checkout determines its `.worktrees' container."
  (should
   (equal (jwm/worktree-container-directory "/Users/jeff/code/k8s/")
          "/Users/jeff/code/k8s.worktrees/")))

(ert-deftest jwm/magit-worktree-reader-prefills-convention-path ()
  "Magit creation offers the primary checkout's container and branch slug."
  (let (directory initial)
    (cl-letf (((symbol-function 'magit-list-worktrees)
               (lambda () '(("/Users/jeff/code/k8s/" "abc" "main" nil))))
              ((symbol-function 'make-directory) (lambda (&rest _)))
              ((symbol-function 'read-directory-name)
               (lambda (_prompt dir _default _mustmatch supplied-initial)
                 (setq directory dir
                       initial supplied-initial))))
      (jwm/magit-read-worktree-directory "Checkout: " "RND-123/foo")
      (should (equal directory "/Users/jeff/code/k8s.worktrees/"))
      (should (equal initial "RND-123-foo")))))

(ert-deftest jwm/git-worktree-paths-parses-registered-worktrees ()
  "Only registered worktree records are offered for navigation."
  (should
   (equal (jwm/git-worktree-paths-from-porcelain
           "worktree /Users/jeff/code/k8s\nHEAD abc\nbranch refs/heads/main\n\nworktree /Users/jeff/code/k8s.worktrees/RND-123\nHEAD def\nbranch refs/heads/RND-123\n")
          '("/Users/jeff/code/k8s/"
            "/Users/jeff/code/k8s.worktrees/RND-123/"))))

(ert-deftest jwm/git-worktree-paths-includes-current-worktree ()
  "The Git registry reports the checkout from which the command is run."
  (should (member (file-name-as-directory (expand-file-name default-directory))
                  (jwm/git-worktree-paths))))

(ert-deftest jwm/magit-switch-worktree-opens-selected-registration ()
  "Selecting a registered worktree opens its Magit status buffer."
  (require 'magit)
  (let (visited)
    (cl-letf (((symbol-function 'jwm/git-worktree-paths)
               (lambda () '("/Users/jeff/code/k8s/"
                            "/Users/jeff/code/k8s.worktrees/RND-123/")))
              ((symbol-function 'completing-read)
               (lambda (&rest _) "/Users/jeff/code/k8s.worktrees/RND-123/"))
              ((symbol-function 'magit-status-setup-buffer)
               (lambda (directory) (setq visited directory))))
      (jwm/magit-switch-worktree)
      (should (equal visited "/Users/jeff/code/k8s.worktrees/RND-123/")))))

;;; worktree-management-tests.el ends here
