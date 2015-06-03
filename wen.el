;; enable yasnippet globally
;;(require 'yasnippet)
;;(yas-global-mode 1)

;; Define flycheck syntax checker for PHP and Web mode
(require 'flycheck)
(flycheck-define-checker my-php
  "A PHP syntax checker using the PHP command line interpreter.

See URL `http://php.net/manual/en/features.commandline.php'."
  :command ("php" "-l" "-d" "error_reporting=E_ALL" "-d" "display_errors=1"
            "-d" "log_errors=0" source)
  :error-patterns
  ((error line-start (or "Parse" "Fatal" "syntax") " error" (any ":" ",") " "
          (message) " in " (file-name) " on line " line line-end))
  :modes (php-mode php+-mode web-mode))

;; Add the newly defined checker to list of flycheckers
(add-to-list 'flycheck-checkers 'my-php)

;; Web mode for PHP
(defun my-setup-php ()
  ;; enable web mode
  (web-mode)

  ;; make these variables local
  (make-local-variable 'web-mode-code-indent-offset)
  (make-local-variable 'web-mode-markup-indent-offset)
  (make-local-variable 'web-mode-css-indent-offset)

  ;; set indentation, can set different indentation level for different code type
  (setq web-mode-code-indent-offset 4)
  (setq web-mode-css-indent-offset 4)
  (setq web-mode-markup-indent-offset 4)

  ;; Auto completion for web mode
  (setq web-mode-ac-sources-alist
        '(("css" . (ac-source-words-in-buffer ac-source-css-property))
          ("html" . (ac-source-words-in-buffer ac-source-abbrev))
          ("php" . (ac-source-words-in-buffer
                    ac-source-words-in-same-mode-buffers
                    ac-source-dictionary))
          ("phtml" . (ac-source-words-in-buffer
                      ac-source-words-in-same-mode-buffers
                      ac-source-dictionary))))

  ;; enable auto-complete-mode
  (require 'auto-complete)
  (auto-complete-mode t)

  ;; Set engine for file extension
  (setq web-mode-engines-alist '(("php"    . "\\.phtml\\'")))

  ;; enable flycheck-mode using my-php
  (require 'flycheck)
  (flycheck-select-checker 'my-php)
  (flycheck-mode t)

  ;; adding custom snippets
  ;; (setq web-mode-extra-snippets
  ;;       '(("php" . (("vd" . ("var_dump(|);\ndie();"))))
  ;;         ))

  ;; PHP Function snippet
  ;; (require 'php-auto-yasnippets)
  ;; (setq php-auto-yasnippet-php-program "~/.emacs.d/elpa/php-auto-yasnippets-20141128.1411/Create-PHP-YASnippet.php")
  ;; (define-key php-mode-map (kbd "C-c C-y") 'yas/create-php-snippet)
  )

;; Trigger my-setup-php when opening files matching the given pattern
(add-to-list 'auto-mode-alist '("\\.php$" . my-setup-php))
(add-to-list 'auto-mode-alist '("\\.phtml$" . my-setup-php))

;; Remove trailing whitespace on save
(add-hook 'before-save-hook 'delete-trailing-whitespace)
;; if indent-tabs-mode is off, untabify before saving
(add-hook 'write-file-hooks
          (lambda () (if (not indent-tabs-mode)
                         (untabify (point-min) (point-max)))
            nil ))

;; PHPUnit
(require 'phpunit)
(defun phpunit-get-program (args)
  "Return the command to launch unit test.
`ARGS' corresponds to phpunit command line arguments."
  (s-concat phpunit-program
            args
            " "
            (phpunit-get-root-directory)
            (phpunit-get-current-class)
            ".php"))
