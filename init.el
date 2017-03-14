;;; package --- init.el
;;; Commentary:
;;; Code:
(setq message-log-max 10000)

(require 'package)
(setq custom-file "~/.emacs.d/custom.el")
(load custom-file)
(setq package-enable-at-startup nil)
(setq package-archives '(("melpa-stable" . "https://stable.melpa.org/packages/")
                         ("gnu" . "https://elpa.gnu.org/packages/")))
(unless (file-directory-p "~/.emacs.d/elpa/archives")
  (package-refresh-contents))
(package-initialize)

(setq quelpa-update-melpa-p nil)
(unless (require 'quelpa nil t)
  (with-temp-buffer
    (url-insert-file-contents (concat "https://raw.github.com/quelpa"
                                      "/quelpa/master/bootstrap.el"))
    (eval-buffer)))

;; install use-package and the quelpa handler
(quelpa '(use-package
           :fetcher github
           :repo "jwiegley/use-package"))
(quelpa '(quelpa-use-package
          :fetcher github
          :repo "quelpa/quelpa-use-package"))
(require 'quelpa-use-package)

(setq use-package-always-ensure t)
(quelpa-use-package-activate-advice)

;;;; settings
;;;;; global-settings
(use-package global-settings
  :ensure nil
  :init
  (menu-bar-mode -1)
  (setq inhibit-startup-message t
        require-final-newline t
        vc-follow-symlinks t
        browse-url-browser-function 'browse-url-generic)
  (setq-default indent-tabs-mode nil)
  (add-hook 'before-save-hook #'delete-trailing-whitespace)
  (global-auto-revert-mode)
  (winner-mode)
  (put 'narrow-to-region 'disabled nil)
  (put 'scroll-left 'disabled nil)
  (put 'upcase-region 'disabled nil)
  (put 'downcase-region 'disabled nil)
  (defadvice terminal-init-screen
      ;; The advice is named `tmux', and is run before `terminal-init-screen' runs.
      (before tmux activate)
    ;; Docstring.  This describes the advice and is made available inside emacs;
    ;; for example when doing C-h f terminal-init-screen RET
    "Apply xterm keymap, allowing use of keys passed through tmux."
    ;; This is the elisp code that is run before `terminal-init-screen'.
    (if (getenv "TMUX")
        (let ((map (copy-keymap xterm-function-map)))
          (set-keymap-parent map (keymap-parent input-decode-map))
          (set-keymap-parent input-decode-map map))))
  (define-key key-translation-map "\e[39;6" (kbd "C-'"))
  (define-key key-translation-map "\e[65;6" (kbd "C-S-a"))
  (define-key key-translation-map "\e[68;6" (kbd "C-S-d"))
  (define-key key-translation-map "\e[86;8" (kbd "C-M-S-v"))
  (provide 'global-settings))

;;;;; visual-settings
(use-package visual-settings
  :ensure nil
  :init
  (line-number-mode)                 ; line numbers in the mode line
  (column-number-mode)               ; column numbers in the mode line
  (global-hl-line-mode)              ; highlight current line
  (global-linum-mode)                ; add line numbers on the left
  (provide 'visual-settings))

;;;;; zenburn-theme
(use-package zenburn-theme
  :quelpa (zenburn-theme :fetcher github
                         :repo "bbatsov/zenburn-emacs")
  :config (set-face-background 'hl-line "color-240"))

;;;;; cider
(use-package cider
  :bind (:map cider-repl-mode-map
              ("C-M-q" . prog-indent-sexp))
  :config
  (setq cider-repl-history-size 100000
        cider-repl-history-file "~/.emacs.d/cider-repl-history.eld")
  (defvar cider-cljs-lein-repl
    "(do (use 'figwheel-sidecar.repl-api) (start-figwheel!) (cljs-repl))")
  (put 'cider-cljs-lein-repl 'safe-local-variable #'stringp))

;;;; replacements for improved functionality
;;;;; which-key
(use-package which-key
  :diminish which-key-mode
  :config (which-key-mode))

;;;;; projectile
(use-package projectile
  :config (projectile-global-mode))

;;;;; helm
(use-package helm
  :config
  (require 'helm-config)
  (helm-mode)
  :bind (("C-x b" . helm-buffers-list)
         ("M-x" . helm-M-x)))

;;;;; helm-projectile
(use-package helm-projectile
  :config
  (setq projectile-switch-project-action 'helm-projectile)
  (helm-projectile-on))

;;;;; goto-last-change
(use-package goto-last-change
  :bind (("C-x C-/" . goto-last-change)
         ("C-x C-_" . goto-last-change)))

;;;;; company
(use-package company
  :diminish company-mode
  :init (add-hook 'after-init-hook #'global-company-mode)
  :bind (("C-M-i" . company-complete)
         :map emacs-lisp-mode-map
         ("C-M-i" . company-complete)
         :map company-active-map
         ("C-n" . company-select-next)
         ("C-p" . company-select-previous)
         ("C-d" . company-show-doc-buffer)
         ("M-." . company-show-location)))

(use-package eldoc
  :ensure nil
  :diminish eldoc-mode
  :commands eldoc-mode
  :init
  (add-hook 'emacs-lisp-mode-hook #'eldoc-mode)
  (add-hook 'cider-mode-hook #'eldoc-mode)
  (add-hook 'cider-repl-mode-hook #'eldoc-mode))

;;;;; clojure-mode
(use-package clojure-mode-extra-font-locking)
(use-package clojure-mode
  :config
  (defun configure-clojure-indent ()
    (define-clojure-indent
                (GET 'defun)
                (POST 'defun)
                (PUT 'defun)
                (DELETE 'defun)
                (HEAD 'defun)
                (ANY 'defun)
                (context 'defun)
                (checking 'defun)))
  (add-hook 'clojure-mode-hook #'configure-clojure-indent))

;;;;; rainbow-delimiters
(use-package rainbow-delimiters
  :config
  (add-hook 'clojure-mode-hook #'rainbow-delimiters-mode)
  (add-hook 'emacs-lisp-mode-hook #'rainbow-delimiters-mode))

;;;;; smartparens
(use-package smartparens
  :diminish smartparens-mode
  :config
  (sp-use-smartparens-bindings)
  (show-smartparens-global-mode)
  (smartparens-global-strict-mode)
  (require 'smartparens-config)
  (set-face-background 'sp-show-pair-match-face "deep sky blue")
  (set-face-foreground 'sp-show-pair-match-face "white"))

;;;; version control
;;;;; magit
(use-package magit
  :bind ("C-x C-z" . magit-status))

;;;;; git-gutter
(use-package git-gutter
  :diminish git-gutter-mode
  :init
  (git-gutter:linum-setup)
  (global-git-gutter-mode)
  :bind (("C-x C-g" . git-gutter-mode)
         ("C-x v =" . git-gutter:popup-hunk)))