;; more packages
(require 'package)
(add-to-list 'package-archives
         '("MELPA Stable" . "https://stable.melpa.org/packages/") t)
(add-to-list 'package-archives
         '("MELPA" . "https://melpa.org/packages/") t)

;; uncomment the following line if you don't want startup screen
;; (setq inhibit-startup-screen t)

;; enable line numbering (on the left)
(global-display-line-numbers-mode 1)

;; set a dark theme
;; comment the following line if you like the good ol' emacs light theme
(custom-set-variables '(custom-enabled-themes '(wombat)))

;; make a backup directory (instead of having backup files in working directory)
(setq backup-directory-alist '(("." . "~/.emacs.d/backup"))
  backup-by-copying t    ; Don't delink hardlinks
  version-control t      ; Use version numbers on backups
  delete-old-versions t  ; Automatically delete excess backups
  kept-new-versions 20   ; how many of the newest versions to keep
  kept-old-versions 5    ; and how many of the old
  )

;; better tab indentation
(setq-default indent-tabs-mode t)
(setq-default tab-width 4)
(defvaralias 'c-basic-offset 'tab-width)

;; enable lsp ui when lsp-mode is activated
(use-package lsp-ui
  :ensure
  :commands lsp-ui-mode
  :custom
  (lsp-ui-peek-always-show t)
  (lsp-ui-sideline-show-hover t)
  (lsp-ui-doc-enable t))

;; automatically enable lsp-mode when in languages mode
(add-hook 'c-mode-hook 'lsp)
(add-hook 'c++-mode-hook 'lsp)
(add-hook 'python-mode-hook 'lsp)
(add-hook 'typescript-mode-hook 'lsp)
(add-hook 'javascript-mode-hook 'lsp)
(add-hook 'latex-mode-hook 'lsp)

;; install and enable helm (better command line)
(use-package helm :ensure t)
(helm-mode 1)
;; redéfinit les macros emacs pour utiliser celles d'helm
(global-set-key (kbd "M-x") 'helm-M-x)
(global-set-key (kbd "C-x C-f") 'helm-find-files)

;; install and enable company (autocompletion)
(use-package company :ensure t)
(company-mode 1)

;; install and enable flycheck (syntax analysis)
(use-package flycheck :ensure t)
(global-flycheck-mode 1)
