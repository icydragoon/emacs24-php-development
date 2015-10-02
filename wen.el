;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Set custom emacs variables                          ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(setq large-file-warning-threshold nil) ; Disables large file warning, mainly for TAGS file

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Define flycheck syntax checker for PHP and Web mode ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
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


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Add the newly defined checker to list of flycheckers ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(add-to-list 'flycheck-checkers 'my-php)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;     Define custom mode for PHP                       ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
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

  ;; Load TAGS
  (visit-tags-table "/opt/git/WebApps/PHP_TAGS")

  ; expanders: typing d/s/ will expand to <div><span>|</span></div> (see web-mode-expanders).
  ;(setq web-mode-enable-auto-expanding t)

  ;; Set engine for file extension
  (setq web-mode-engines-alist '(("php"    . "\\.phtml\\'")))

  ;; Set comment format
  (add-to-list 'web-mode-comment-formats '("php" . "//"))

  ;; enable flycheck-mode using my-php
  (require 'flycheck)
  (flycheck-select-checker 'my-php)
  (flycheck-mode t)

  ;; adding custom snippets
  ;; (setq web-mode-extra-snippets
  ;;       '(("php" . (("vd" . ("var_dump(|);\ndie();"))))
  ;;         ))

  ;; enable yasnippet
  (require 'yasnippet)
  (yas-global-mode t)
  ;; (yas-reload-all t)
  ;; Create symlink to elpa yasnippet snippets directory to use them without needing to add another directory and reloading the snippets (SLOWER)
  ;; (add-to-list 'yas-snippet-dirs "/home/wen/.emacs.d/snippets/text-mode/")
  )


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;     Define custom mode for JavaScript                ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun my-setup-js ()
  (require 'auto-complete)
  (auto-complete-mode t)

  (add-hook 'js2-mode-hook (lambda () (tern-mode t)))
  (eval-after-load 'tern
    '(progn
       (require 'tern-auto-complete)
       (tern-ac-setup)))

  ;; enable js2 mode, javascript-mode is deprecated
  (js2-mode)

  ;; js2-mode provides 4 level of syntax highlighting. They are
  ;; * 0 or a negative value means none.
  ;; * 1 adds basic syntax highlighting.
  ;; * 2 adds highlighting of some Ecma built-in properties.
  ;; * 3 adds highlighting of many Ecma built-in functions.
  (setq js2-highlight-level 3)

  ;; enable auto-complete-mode
  ;; (require 'auto-complete)
  ;; (auto-complete-mode t)
  ;; (require 'tern)
  ;; (tern-mode t)
  ;; (require 'tern-auto-complete)
  ;; (tern-ac-setup t)

  ;; Load TAGS
  ;;(visit-tags-table "/opt/git/WebApps/JS_TAGS")

  ;; enable yasnippet
  (require 'yasnippet)
  (yas-global-mode t)
  ;; (yas-reload-all t)
  ;; Create symlink to elpa yasnippet snippets directory to use them without needing to add another directory and reloading the snippets (SLOWER)
  ;; (add-to-list 'yas-snippet-dirs "/home/wen/.emacs.d/snippets/text-mode/")
  )


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Trigger appropriate modes when opening files                       ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(add-to-list 'auto-mode-alist '("\\.php$" . my-setup-php))
(add-to-list 'auto-mode-alist '("\\.phtml$" . my-setup-php))
(add-to-list 'auto-mode-alist '("\\.js$" . my-setup-js))
(add-to-list 'auto-mode-alist '("\\.json$" . my-setup-js))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Remove trailing whitespace and save as unix line ending on save ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun before-save ()
  (setq-default buffer-file-coding-system 'utf-8-unix)
  (setq-default default-buffer-file-coding-system 'utf-8-unix)
  (set-default-coding-systems 'utf-8-unix)
  (prefer-coding-system 'utf-8-unix)

  (delete-trailing-whitespace t)
)

(add-hook 'before-save-hook 'delete-trailing-whitespace)
;; if indent-tabs-mode is off, untabify before saving
(add-hook 'write-file-hooks
          (lambda () (if (not indent-tabs-mode)
                         (untabify (point-min) (point-max)))
            nil ))


;;;;;;;;;;;;;;;;;;;;;
;;     PHPUnit     ;;
;;;;;;;;;;;;;;;;;;;;;
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
