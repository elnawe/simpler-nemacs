;; Variables
(load (concat user-emacs-directory "init-vars.el"))

;; Default font
(set-fontset-font t 'unicode (font-spec :name "Envy Code R-14") nil)
(set-face-font 'default "Envy Code R-14")

;; Better defaults
(setq-default auto-save-default nil
              bidi-display-reordering nil
              blink-matching-paren nil
              buffer-file-coding-system  'utf-8
              cursor-in-non-selected-windows nil
              custom-file (expand-file-name "custom.el" nemacs-etc-dir)
              create-lockfiles nil
              delete-by-moving-to-trash t
              fill-column 80
              frame-inhibit-implied-resize t
              frame-title-format "NEMACS"
              help-window-select t
              highlight-nonselected-windows nil
              hl-line-sticky-flag t
              fringe-indicator-alist (delq
                                      (assq 'continuation fringe-indicator-alist)
                                      fringe-indicator-alist)
              indent-tabs-mode nil
              indicate-buffer-boundaries nil
              indicate-empty-lines nil
              make-backup-files nil
              max-mini-window-height 0.3
              mode-line-default-help-echo nil
              mouse-yank-at-point t
              ns-right-alternate-modifier nil
              require-final-newline t
              resize-mini-windows 'grow-only
              ring-bell-function #'ignore
              show-help-function nil
              split-height-threshold nil
              split-width-threshold 160
              tab-always-indent t
              tab-width 4
              tabify-regexp "^\t* [ \t]+"
              truncate-lines nil
              uniquify-buffer-name-style 'post-forward-angle-brackets
              use-dialog-box nil
              use-package-always-ensure t
              vc-handled-backends nil
              visible-bell nil
              visible-cursor nil
              whitespace-line-column fill-column
              whitespace-style '(face tab trailing)
              word-wrap t
              x-stretch-cursor t)

(setq-default mode-line-format
      '("%e"
        mode-line-front-space
        mode-line-modified
        " "
        mode-line-buffer-identification
        " "
        mode-line-position
        " "
        mode-line-modes
        mode-line-misc-info))

;; Save files
(setq-default abbrev-file-name (concat nemacs-local-dir "abbrev.el")
              auto-save-list-file-name (concat nemacs-cache-dir "autosave")
              bookmark-default-file (concat nemacs-etc-dir   "bookmarks")
              nsm-settings-file (expand-file-name "ns.data" nemacs-cache-dir)
              pcache-directory (concat nemacs-cache-dir "pcache")
              recentf-save-file (expand-file-name "recentf" nemacs-cache-dir)
              savehist-file (expand-file-name "history" nemacs-cache-dir)
              url-history-file (expand-file-name "url.el" nemacs-cache-dir))

;; Simpler UI
(when window-system
  (tooltip-mode -1)
  (menu-bar-mode -1)
  (tool-bar-mode -1)
  (scroll-bar-mode -1))

;; Modes and default folder
(cd "~")
(fset #'yes-or-no-p #'y-or-n-p)
(show-paren-mode t)
(global-auto-revert-mode t)
(global-subword-mode t)
(delete-selection-mode t)
(column-number-mode t)

;; Hooks
(add-hook 'before-save-hook 'delete-trailing-whitespace)

;; Package management
(eval-and-compile
  (setq package-user-dir nemacs-packages-dir))

(setq package-enable-at-startup nil)

(setq package-archives '(("org"          . "https://orgmode.org/elpa/")
                         ("gnu"          . "https://elpa.gnu.org/packages/")
                         ("melpa"        . "https://melpa.org/packages/")
                         ("melpa-stable" . "https://stable.melpa.org/packages/")))
(package-initialize)

(progn
  (when (not package-archive-contents)
    (package-refresh-contents))
  (package-install 'use-package))

(eval-when-compile
  (require 'use-package))

;; Theme
(use-package night-owl-theme
  :init
  (load-theme 'night-owl t))

;; TODO: Add all-the-icons, check for folder with fonts, if doesn't exist run install.
(use-package ido
  :ensure flx-ido
  :config
  (ido-mode t)
  (ido-everywhere 1)
  (flx-ido-mode 1)
  :custom
  (ido-save-directory-list-file (expand-file-name "ido.last" nemacs-cache-dir))
  (ido-enable-prefix nil)
  (ido-enable-flex-matching t)
  (ido-case-fold nil)
  (ido-auto-merge-work-directories-length -1)
  (ido-create-new-buffer 'always)
  (ido-use-filename-at-point nil)
  (ido-max-prospects 10)
  (ido-use-faces nil))

;; Programming
(use-package prog-mode
  :ensure nil
  :config
  (use-package company
    :bind (:map company-active-map
                ("M-p" . company-select-previous)
                ("M-n" . company-select-next)
                ("C-p" . nil)
                ("C-n" . nil))
    :custom
    (company-idle-delay 0.5)
    (company-minimum-prefix-length 3))

  (use-package json-mode)

  (use-package markdown-mode)

  (use-package rjsx-mode)

  (use-package rust-mode)

  (use-package typescript-mode)
  :custom
  (js-indent-level 2)
  (sgml-basic-offset 4))

;; Org
(use-package org
  :init
  (use-package org-bullets
    :custom
    (org-bullets-bullet-list '("▲" "●" "■" "✶" "◉" "○" "○"))
    (org-bullets-face-name 'org-bullets))

  (use-package org-id
    :ensure nil)
  :preface
  (defvar nemacs-org-dir "~/Dropbox/Notes")

  (defun nemacs-setup-org-mode ()
    "Setups NEMACS org-mode."
    (org-bullets-mode)
    (org-indent-mode)
    (turn-on-visual-line-mode)
    (setq-local line-spacing 0.1))

  (defun nemacs-org-file (filename)
    "Expands from `nemacs-org-dir', appending `filename'."
    (expand-file-name filename nemacs-org-dir))

  (defun nemacs-org-capture-todo ()
    "Captures a new TODO entry. Same as `C-c c T'."
    (interactive)
    (org-capture :keys "T"))

  (defun nemacs-org-open-inbox ()
    "Opens the `inbox.org' file."
    (interactive)
    (find-file (nemacs-org-file "inbox.org")))
  :hook (org-mode . nemacs-setup-org-mode)
  :bind (("C-c l" . org-store-link)
         ("C-c c" . org-capture)
         ("M-n" . nemacs-org-capture-todo)
         ("C-c i" . nemacs-org-open-inbox))
  :custom
    (org-archive-location (nemacs-org-file "archive.org::datetree/"))
    (org-blank-before-new-entry '((heading . nil)
                                     (plain-list-item . nil)))
    (org-deadline-warning-days 7)
    (org-default-notes-file (nemacs-org-file "inbox.org"))
    (org-descriptive-links t)
    (org-directory nemacs-org-dir)
    (org-ellipsis " […]")
    (org-fontify-done-headline t)
    (org-fontify-whole-heading-line t)
    (org-return-follows-link t)
    (org-startup-folded nil)
    (org-startup-truncated nil)
    (org-support-shift-select 'always)
    (org-tags-column -75)

    (org-todo-keyword-faces
     `(("TODO"     . "OrangeRed")
       ("WAITING"  . "RoyalBlue")
       ("DONE"     . "SeaGreen")
       ("CANCELED" . "DarkRed")

       ;; Special states
       ("JOURNAL"  . "DarkOrange")
       ("MEETING"  . "SlateBlue3")))

    (org-log-done 'time)
    (org-log-redeadline 'note)
    (org-log-reschedule 'note)
    (org-read-date-prefer-future 'time)

    (org-capture-templates
     `(("T" "Create a TODO task"
        entry (file ,org-default-notes-file)
        "* TODO %?"))))

;; Projects
(use-package projectile
  :commands (projectile-command-map
             projectile-find-file)
  :config
  (define-key projectile-mode-map (kbd "C-c p") 'projectile-command-map)
  (projectile-mode +1)
  (add-to-list 'projectile-globally-ignored-directories ".local")
  (add-to-list 'projectile-globally-ignored-directories "node_modules")
  :custom
  (projectile-cache-file (expand-file-name "projectile.cache" nemacs-cache-dir))
  (projectile-known-projects-file (expand-file-name "projectile-bookmarks.eld" nemacs-cache-dir)))

;; Simple
(use-package simple
  :ensure nil
  :custom
  (inhibit-default-init t)
  (inhibit-startup-echo-area-message user-login-name)
  (initial-major-mode 'fundamental-mode)
  (initial-scratch-message nil)
  (inhibit-startup-message t))

;; Boot up
(eval-and-compile
  (setq gc-cons-threshold 402653184
        gc-cons-percentage 0.6))

(setq max-lisp-eval-depth 50000
      max-specpdl-size 13000)

(defun nemacs-after-init ()
  "After init function, run this in `after-init-hook'."
  ;; Utils
  (load (expand-file-name "nemacs-utils.el" user-emacs-directory))

  (setq gc-cons-threshold 16777216
        gc-cons-percentage 0.1)

  (add-to-list 'default-frame-alist '(fullscreen . maximized)))

(add-hook 'after-init-hook #'nemacs-after-init)
