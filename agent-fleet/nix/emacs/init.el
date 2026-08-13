;; -*- no-byte-compile: t; -*-

(require 'package)
(package-initialize)

;; (load-theme 'manoj-dark t)
;; (load-theme 'leuven t)

(make-directory (expand-file-name "quick-backups" user-emacs-directory) t)

(setq-default mouse-highlight nil
              case-fold-search t
              case-replace nil
              compilation-scroll-output t
              compilation-ask-about-save nil
              grep-highlight-matches t
              grep-scroll-output nil
              grep-save-buffers nil
              set-mark-command-repeat-pop t
              show-trailing-whitespace t
              truncate-lines t
              truncate-partial-width-windows nil
              fill-column 80
              make-backup-files nil
              auto-save-file-name-transforms
              `(("\\`/[^/]*:\\([^/]*/\\)*\\([^/]*\\)\\'"
                 ,temporary-file-directory t)
                (".*"
                 ,(expand-file-name "quick-backups" user-emacs-directory) t))
              create-lockfiles nil
              indent-tabs-mode nil)

(defmacro comment (&rest _body)
  "Ignore BODY."
  nil)

(defun rk/init-safe-vars ()
  "Mark supported directory-local variables as safe."
  (interactive)
  (put 'projectile-project-root-files-functions 'safe-local-variable 'listp)
  (put 'projectile-indexing-method 'safe-local-variable 'symbolp)
  (put 'projectile-ignored-projects 'safe-local-variable 'consp)
  (put 'projectile-project-root 'safe-local-variable 'stringp)
  (put 'projectile-project-compilation-cmd 'safe-local-variable 'stringp)
  (put 'before-save-hook 'safe-local-variable 'listp)
  (put 'org-confirm-babel-evaluate 'safe-local-variable 'booleanp)
  (put 'lsp-rust-analyzer-cargo-watch-args 'safe-local-variable 'vectorp)
  (put 'lsp-rust-analyzer-exclude-dirs 'safe-local-variable 'vectorp)
  (put 'eval 'safe-local-variable (lambda (_) t))
  (add-to-list 'safe-local-variable-values
               '(eval setq projectile-project-root
                      (locate-dominating-file default-directory ".projectile"))))

(rk/init-safe-vars)

;; -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
