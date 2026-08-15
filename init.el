;; -*- lexical-binding: t; -*-

;; Disable bidirection text scanning
(setq-default bidi-display-reordering 'left-to-right
              bidi-paragraph-direction 'left-to-right)
(setq bidi-inhibit-bpa t)
;; Skip fontification during input
(setq redisplay-skip-fontification-on-input t)
;; Increase process output buffer for LSP
(setq read-process-output-max (* 4 1024 1024)) ; 4MB
;; Don't render cursors in non-focused windows
(setq-default cursor-in-non-selected-windows nil)
(setq highlight-nonselected-windows nil)
(setq gc-cons-threshold 50000000)
(setq load-prefer-newer t)
(setq ffap-machine-p-known 'reject)

;; (require 'package)
;; (setq package-archives '(("melpa" . "https://melpa.org/packages/")
;;                          ("org" . "https://orgmode.org/elpa/")
;;                          ("elpa" . "https://elpa.gnu.org/packages/")))
;; (package-initialize)
;; (unless package-archive-contents
;;   (package-refresh-contents))
;; (unless (package-installed-p 'use-package)
;;   (package-install 'use-package))
;; (require 'use-package)
;; (setq use-package-always-ensure t)

(defvar bootstrap-version)
(let ((bootstrap-file
       (expand-file-name
        "straight/repos/straight.el/bootstrap.el"
        (or (bound-and-true-p straight-base-dir)
            user-emacs-directory)))
      (bootstrap-version 7))
  (unless (file-exists-p bootstrap-file)
    (with-current-buffer
        (url-retrieve-synchronously
         "https://raw.githubusercontent.com/radian-software/straight.el/develop/install.el"
         'silent 'inhibit-cookies)
      (goto-char (point-max))
      (eval-print-last-sexp)))
  (load bootstrap-file nil 'nomessage))

(straight-use-package 'use-package)
(setq straight-use-package-by-default t)

(use-package exec-path-from-shell
  :if (memq window-system '(mac ns))
  :config
  (exec-path-from-shell-initialize))

(defun am/add-to-exec-path (path)
  "Add PATH to both `exec-path' and the process PATH environment."
  (let ((expanded (expand-file-name path)))
    (add-to-list 'exec-path expanded)
    (setenv "PATH" (concat expanded path-separator (getenv "PATH")))))

(dolist (path '("~/.local/bin" "~/.opencode/bin"))
  (am/add-to-exec-path path))
(when (eq system-type 'darwin)
  (am/add-to-exec-path "/opt/homebrew/bin"))

(require 'use-package-ensure-system-package)

(use-package envrc
  :config
  (defun am/envrc-enable-for-buffer ()
    (when (and buffer-file-name
               (not (minibufferp))
               (not (bound-and-true-p org-src-mode)))
      (envrc-mode 1)))
  (add-hook 'find-file-hook #'am/envrc-enable-for-buffer)
  (add-hook 'verilog-mode-hook #'am/envrc-enable-for-buffer)
  (add-hook 'verilog-ts-mode-hook #'am/envrc-enable-for-buffer))

(setq user-full-name "Angelo Montenegro"
      user-mail-address "amontene823@gmail.com")
;; dont pop up the warnings buffer during async native compilation
(setq native-comp-async-report-warnings-errors 'silent)
;; quit emacs directly, even if there are running processes
(setq confirm-kill-processes nil)

;;
(defconst angelo-savefile-dir (expand-file-name "savefile" user-emacs-directory))
;; create the savefile dir if it doesn't exist
(unless (file-exists-p angelo-savefile-dir)
  (make-directory angelo-savefile-dir))
(use-package saveplace
  :config
  (setq save-place-file (expand-file-name "saveplace" angelo-savefile-dir))
  ;; activate it for all buffers
  (save-place-mode +1))

;; remove toolbar
(when (fboundp 'tool-bar-mode)
  (tool-bar-mode -1))
(setq inhibit-startup-message t)
(setq inhibit-startup-screen t)
(blink-cursor-mode -1)
(scroll-bar-mode -1)
(tool-bar-mode -1)
(tooltip-mode -1)
(set-fringe-mode 10)
(menu-bar-mode -1)
(setq use-short-answers t)
(setq visible-bell t)
;; nice scrolling
(setq scroll-margin 0
      scroll-conservatively 100000
      scroll-preserve-screen-position 1)
(when (fboundp 'pixel-scroll-precision-mode)
  (pixel-scroll-precision-mode t))

;; wrapped lines respect the indentation of the original line
(global-visual-wrap-prefix-mode 1)
;; Proportional window resizing
(setq window-combination-resize t)
;; highlight the current error in compilation/grep buffers
(setq next-error-message-highlight t)

(winner-mode +1)
(defun toggle-delete-other-windows ()
  "Delete other windows in frame if any, or restore previous window config."
  (interactive)
  (if (and winner-mode
           (equal (selected-window) (next-window)))
      (winner-undo)
    (delete-other-windows)))
;; (global-set-key (kbd "C-x 1") #'toggle-delete-other-windows)
;; maximize the initial frame automatically
(add-to-list 'initial-frame-alist '(fullscreen . maximized))
;; more useful frame title, that show either a file or a
;; buffer name (if the buffer isn't visiting a file)
(setq frame-title-format
      '((:eval (if (buffer-file-name)
                   (abbreviate-file-name (buffer-file-name))
                 "%b"))))
;; Emacs modes typically provide a standard means to change the
;; indentation width -- eg. c-basic-offset: use that to adjust your
;; personal indentation width, while maintaining the style (and
;; meaning) of any files you load.
(setq-default indent-tabs-mode nil)   ;; don't use tabs to indent
(setq-default tab-width 8)            ;; but maintain correct appearance
;; Newline at end of file
(setq require-final-newline t)
;; Wrap lines at 80 characters
(setq-default fill-column 80)

;; fonts
(set-face-attribute 'default nil :font "JetBrains Mono" :height 120 :weight 'medium)
(set-face-attribute 'fixed-pitch nil :font "JetBrains Mono" :height 120 :weight 'medium)
(set-face-attribute 'variable-pitch nil :font "Inter" :height 120 :weight 'light)
(column-number-mode)
(global-display-line-numbers-mode t)
;; Disable line numbers for some modes
(defun disable-line-numbers ()
  "Hook to disable line-number-mode"
  (display-line-numbers-mode 0))
(dolist (hook `(org-mode-hook
                term-mode-hook
                shell-mode-hook
                eshell-mode-hook
                pdf-view-mode-hook))
  (add-hook hook #'disable-line-numbers))

;; doom
(use-package doom-themes
  :config
  (load-theme 'doom-tokyo-night t))
(use-package doom-modeline
  :custom (doom-modeline-height 15)
  :config (doom-modeline-mode 1))

;; rainbow parantheses
(use-package rainbow-delimiters
  :hook (prog-mode . rainbow-delimiters-mode))

(use-package all-the-icons)

;; diminish - hide minor modes from the mode line
(use-package diminish
  :config
  (diminish 'abbrev-mode)
  (diminish 'flyspell-mode)
  (diminish 'flyspell-prog-mode)
  (diminish 'eldoc-mode))

;; store all backup and autosave files in the tmp dir
(setq backup-directory-alist
      `((".*" . ,temporary-file-directory)))
(setq auto-save-file-name-transforms
      `((".*" ,temporary-file-directory t)))

;; revert buffers automatically when underlying files are changed externally
(setq auto-revert-avoid-polling t)
(global-auto-revert-mode t)

;; make it possible to navigate to the C source of Emacs functions
(setq find-function-C-source-directory "~/projects/emacs")

(use-package paren
  :config
  (show-paren-mode +1)
  ;; show matching paren context when it's offscreen
  (setq show-paren-context-when-offscreen 'overlay))

(use-package elec-pair
  :config
  (electric-pair-mode +1))
(defun am/org-electric-pair-inhibit (char)
  (if (eq char ?<)
      t
    (electric-pair-default-inhibit char)))

(add-hook 'org-mode-hook
          (lambda ()
            (setq-local electric-pair-inhibit-predicate
                        #'am/org-electric-pair-inhibit)))

(use-package whitespace
  :init
  (add-hook 'prog-mode-hook #'whitespace-mode)
  (add-hook 'prog-mode-hook
            (lambda ()
              (add-hook 'before-save-hook #'whitespace-cleanup nil t)))
  :config
  (setq whitespace-line-column 80)
  (setq whitespace-style '(face tabs empty trailing lines-tail)))

(use-package rainbow-mode
  :config
  (add-hook 'prog-mode-hook #'rainbow-mode)
  (diminish 'rainbow-mode))

(use-package treemacs
  :defer t
  :config
  (setq treemacs-width 30)
  (treemacs-follow-mode 1)
  (treemacs-project-follow-mode 1)
  ;; (treemacs-tag-follow-mode 1)
  ;; (setq treemacs-tag-follow-delay 0)
  (setq treemacs-file-event-delay 1000))

(use-package treemacs-evil
  :after (treemacs evil))

(defun am/treemacs-enable-leader-keys ()
  "Expose the main leader maps in Treemacs buffers."
  (when (and (boundp 'evil-normal-state-map)
             (boundp 'evil-treemacs-state-map)
             (boundp 'treemacs-mode-map))
    (let ((space-leader (lookup-key evil-normal-state-map (kbd "SPC")))
          (control-space-leader (lookup-key evil-normal-state-map (kbd "C-SPC"))))
      (when (keymapp space-leader)
        (define-key evil-treemacs-state-map (kbd "SPC") space-leader)
        (define-key treemacs-mode-map (kbd "SPC") space-leader))
      (when (keymapp control-space-leader)
        (define-key evil-treemacs-state-map (kbd "C-SPC") control-space-leader)
        (define-key treemacs-mode-map (kbd "C-SPC") control-space-leader)))))

(use-package treemacs-projectile
  :after (treemacs projectile))

(use-package yasnippet
  :config
  (add-to-list 'yas-snippet-dirs (expand-file-name "snippets" user-emacs-directory))
  (yas-global-mode 1))

;; Make ESC quit prompts
(global-set-key (kbd "<escape>") 'keyboard-escape-quit)

(use-package evil
  :init
  ;; these settings were important for correcting indentation in
  ;; org mode src blocks
  (setq evil-want-integration t)
  (setq evil-want-keybinding nil)
  (setq evil-want-C-u-scroll t)
  (setq evil-want-C-i-jump nil)
  (setq evil-split-window-below t)
  (setq evil-vsplit-window-right t)
  :config
  (evil-mode 1)
  ;;(define-key evil-normal-state-map (kbd "C-.") nil)
  ;;(define-key evil-insert-state-map (kbd "C-g") 'evil-normal-state)
  ;;(define-key evil-insert-state-map (kbd "C-h") 'evil-delete-backward-char-and-join)

  ;; Use visual line motions even outside of visual-line-mode buffers
  (evil-global-set-key 'motion "j" 'evil-next-visual-line)
  (evil-global-set-key 'motion "k" 'evil-previous-visual-line)

  (evil-set-initial-state 'messages-buffer-mode 'normal)
  (evil-set-initial-state 'dashboard-mode 'normal)

  (evil-set-undo-system 'undo-redo)) ;; undo-redo functionality

(use-package evil-collection
  :after evil
  :config
  (evil-collection-init))

(use-package evil-commentary
  :after evil
  :config
  (evil-commentary-mode))

(setq ispell-program-name "aspell")
(setq ispell-dictionary "en_US")
(setq ispell-personal-dictionary
      (expand-file-name "spell/en_US.pws" user-emacs-directory))

(dolist (hook '(text-mode-hook))
  (add-hook hook (lambda () (flyspell-mode 1))))

(when (eq system-type 'darwin) ;; Check if the OS is macOS
  (with-eval-after-load "flyspell"
    '(progn
       (define-key flyspell-mouse-map [down-mouse-3] #'flyspell-correct-word)
       (define-key flyspell-mouse-map [mouse-3] #'undefined))))

(use-package agent-shell
  :commands (agent-shell
             agent-shell-cycle-session-mode
             agent-shell-fork
             agent-shell-new-shell
             agent-shell-new-worktree-shell
             agent-shell-openai-start-codex
             agent-shell-opencode-start-agent
             agent-shell-prompt-compose
             agent-shell-resume-session
             agent-shell-send-clipboard-image
             agent-shell-send-screenshot
             agent-shell-set-session-config-option
             agent-shell-set-session-mode
             agent-shell-set-session-model
             agent-shell-set-session-thought-level
             agent-shell-toggle)
  :ensure-system-package
  ((codex-acp . "npm install -g --prefix ~/.local @agentclientprotocol/codex-acp"))
  :init
  (setq agent-shell-prefer-viewport-interaction t)
  :config
  (setq agent-shell-openai-authentication
        (agent-shell-openai-make-authentication :login t))

  (setq agent-shell-write-inhibit-minor-modes
        '(aggressive-indent-mode))

  (with-eval-after-load 'evil
    (evil-define-key 'insert agent-shell-mode-map (kbd "RET") #'newline)
    (evil-define-key 'normal agent-shell-mode-map (kbd "RET") #'comint-send-input))

  (add-hook 'diff-mode-hook
            (lambda ()
              (when (string-match-p "\\*agent-shell-diff\\*" (buffer-name))
                (evil-emacs-state)))))

(use-package agent-shell-macext
  :if (eq system-type 'darwin)
  :straight (:host github :repo "cxa/agent-shell-macext")
  :after agent-shell
  :hook (agent-shell-mode . agent-shell-macext-setup)
  :custom
  (agent-shell-macext-file-copy-policy 'auto)
  (agent-shell-macext-notifications t)
  (agent-shell-macext-notify-current-buffer nil))

(use-package agent-shell-links
  :straight (:host github :repo "ultronozm/agent-shell-links.el")
  :after agent-shell
  :config
  (agent-shell-links-bookmark-setup)
  (with-eval-after-load 'ol
    (org-link-set-parameters
     "agent-shell"
     :follow #'agent-shell-links-org-follow
     :store #'agent-shell-links-org-store)))

(use-package agent-shell-dashboard
  :straight (:host github :repo "wandersoncferreira/agent-shell-dashboard")
  :commands (agent-shell-dashboard))

(use-package agent-shell-org-transcript
  :straight (:host github :repo "lllShamanlll/agent-shell-org-transcript")
  :after agent-shell
  :custom
  (agent-shell-org-transcript-directory
   (file-truename "~/org/agent-shell/"))
  :config
  (make-directory agent-shell-org-transcript-directory t))

(use-package agent-recall
  :straight (:host github :repo "mrx-xo/agent-recall")
  :after agent-shell
  :commands (agent-recall-browse
             agent-recall-consult-search
             agent-recall-reindex
             agent-recall-resume
             agent-recall-search
             agent-recall-search-live
             agent-recall-stats)
  :hook (agent-shell-mode . agent-recall-track-sessions)
  :custom
  (agent-recall-search-paths '("~/Projects" "~/org"))
  (agent-recall-extra-transcript-dirs
   `((:dir ,(file-truename "~/org/agent-shell/")
      :project "agent-shell")))
  (agent-recall-search-function 'consult-ripgrep)
  (agent-recall-browse-sort 'modified-desc)
  :config
  (global-agent-recall-transcript-mode 1))

(use-package latex-to-svg-backend
  :straight (:host github :repo "alberti42/latex-to-svg-backend"))

(use-package agent-shell-math-renderer
  :straight (:host github :repo "alberti42/agent-shell-math-renderer")
  :after (agent-shell latex-to-svg-backend)
  :hook (agent-shell-mode . agent-shell-math-renderer-mode)
  :config
  (add-hook 'enable-theme-functions
            #'agent-shell-math-renderer-on-theme-change))

(use-package vertico
  ;; :custom
  ;; (vertico-scroll-margin 0) ;; Different scroll margin
  ;; (vertico-count 20) ;; Show more candidates
  ;; (vertico-resize t) ;; Grow and shrink the Vertico minibuffer
  ;;(vertico-cycle t) ;; Enable cycling for `vertico-next/previous'
  :init
  (vertico-mode))

(with-eval-after-load 'vertico
  (define-key vertico-map (kbd "C-j") 'vertico-next)
  (define-key vertico-map (kbd "C-k") 'vertico-previous))

(use-package vertico-directory
  :straight nil
  :after vertico
  ;; More convenient directory navigation commands
  :bind (:map vertico-map
              ("RET" . vertico-directory-enter)
              ("DEL" . vertico-directory-delete-char)
              ("M-DEL" . vertico-directory-delete-word))
  ;; Tidy shadowed file names
  :hook (rfn-eshadow-update-overlay . vertico-directory-tidy))

(use-package corfu
  ;; Optional customizations
  :custom
  ;; (corfu-cycle t)                ;; Enable cycling for `corfu-next/previous'
  ;; (corfu-auto t)                 ;; Enable auto completion
  (corfu-separator ?\s)          ;; Orderless field separator
  ;; (corfu-quit-at-boundary nil)   ;; Never quit at completion boundary
  ;; (corfu-quit-no-match nil)      ;; Never quit, even if there is no match
  ;; (corfu-preview-current nil)    ;; Disable current candidate preview
  ;; (corfu-preselect 'prompt)      ;; Preselect the prompt
  ;; (corfu-on-exact-match nil)     ;; Configure handling of exact matches
  ;; (corfu-scroll-margin 5)        ;; Use scroll margin

  ;; Enable Corfu only for certain modes. See also `global-corfu-modes'.
  ;; :hook ((prog-mode . corfu-mode)
  ;;        (shell-mode . corfu-mode)
  ;;        (eshell-mode . corfu-mode))

  ;; Recommended: Enable Corfu globally.  This is recommended since Dabbrev can
  ;; be used globally (M-/).  See also the customization variable
  ;; `global-corfu-modes' to exclude certain modes.
  :bind
  (:map corfu-map ("SPC" . corfu-insert-separator))
  :init
  (global-corfu-mode)
  :config
  (corfu-popupinfo-mode)
  (corfu-history-mode)
  )

(use-package cape
  :init
  (add-to-list 'completion-at-point-functions #'cape-file)
  (add-to-list 'completion-at-point-functions #'cape-dabbrev))

(use-package emacs
  :straight (:type built-in)
  :custom
  ;; TAB cycle if there are only few candidates
  ;; (completion-cycle-threshold 3)

  ;; Enable indentation+completion using the TAB key.
  ;; `completion-at-point' is often bound to M-TAB.
  (tab-always-indent 'complete)

  ;; Emacs 30 and newer: Disable Ispell completion function. As an alternative,
  ;; try `cape-dict'.
  ;; (text-mode-ispell-word-completion nil)

  ;; Support opening new minibuffers from inside existing minibuffers.
  (enable-recursive-minibuffers t)
  ;; Emacs 28 and newer: Hide commands in M-x which do not work in the current
  ;; mode.  Vertico commands are hidden in normal buffers. This setting is
  ;; useful beyond Vertico.
  (read-extended-command-predicate #'command-completion-default-include-p)
  :init
  ;; Add prompt indicator to `completing-read-multiple'.
  ;; We display [CRM<separator>], e.g., [CRM,] if the separator is a comma.
  (defun crm-indicator (args)
    (cons (format "[CRM%s] %s"
                  (replace-regexp-in-string
                   "\\`\\[.*?]\\*\\|\\[.*?]\\*\\'" ""
                   crm-separator)
                  (car args))
          (cdr args)))
  (advice-add #'completing-read-multiple :filter-args #'crm-indicator)

  ;; Do not allow the cursor in the minibuffer prompt
  (setq minibuffer-prompt-properties
        '(read-only t cursor-intangible t face minibuffer-prompt))
  (add-hook 'minibuffer-setup-hook #'cursor-intangible-mode))

;; makes scrolling good in emacs-mac
(use-package ultra-scroll-mac
  :straight (ultra-scroll-mac :type git :host github :repo "jdtsmith/ultra-scroll-mac")
  :if (eq window-system 'mac)
  :init
  (setq scroll-conservatively 101 ; important!
        scroll-margin 0)
  :config
  ;; Enable the ultra-scroll mode
  (ultra-scroll-mac-mode 1))

(use-package orderless
  :init
  ;; Tune the global completion style settings to your liking!
  ;; This affects the minibuffer and non-lsp completion at point.
  (setq completion-styles '(orderless partial-completion basic)
        completion-category-defaults nil
        completion-category-overrides nil))

(use-package consult
  ;; Replace bindings. Lazily loaded by `use-package'.
  :bind (;; C-c bindings in `mode-specific-map'
         ("C-c M-x" . consult-mode-command)
         ("C-c h" . consult-history)
         ("C-c k" . consult-kmacro)
         ("C-c m" . consult-man)
         ("C-c i" . consult-info)
         ([remap Info-search] . consult-info)
         ;; C-x bindings in `ctl-x-map'
         ("C-x M-:" . consult-complex-command)     ;; orig. repeat-complex-command
         ("C-x b" . consult-buffer)                ;; orig. switch-to-buffer
         ("C-x 4 b" . consult-buffer-other-window) ;; orig. switch-to-buffer-other-window
         ("C-x 5 b" . consult-buffer-other-frame)  ;; orig. switch-to-buffer-other-frame
         ("C-x t b" . consult-buffer-other-tab)    ;; orig. switch-to-buffer-other-tab
         ("C-x r b" . consult-bookmark)            ;; orig. bookmark-jump
         ("C-x p b" . consult-project-buffer)      ;; orig. project-switch-to-buffer
         ;; Custom M-# bindings for fast register access
         ("M-#" . consult-register-load)
         ("M-'" . consult-register-store)          ;; orig. abbrev-prefix-mark (unrelated)
         ("C-M-#" . consult-register)
         ;; Other custom bindings
         ("M-y" . consult-yank-pop)                ;; orig. yank-pop
         ;; M-g bindings in `goto-map'
         ("M-g e" . consult-compile-error)
         ("M-g f" . consult-flymake)               ;; Alternative: consult-flycheck
         ("M-g g" . consult-goto-line)             ;; orig. goto-line
         ("M-g M-g" . consult-goto-line)           ;; orig. goto-line
         ("M-g o" . consult-outline)               ;; Alternative: consult-org-heading
         ("M-g m" . consult-mark)
         ("M-g k" . consult-global-mark)
         ("M-g i" . consult-imenu)
         ("M-g I" . consult-imenu-multi)
         ;; M-s bindings in `search-map'
         ("M-s d" . consult-find)                  ;; Alternative: consult-fd
         ("M-s c" . consult-locate)
         ;; ("C-f"   . consult-ripgrep)
         ("M-s g" . consult-grep)
         ("M-s G" . consult-git-grep)
         ("C-l" . consult-line)
         ("M-s L" . consult-line-multi)
         ("M-s k" . consult-keep-lines)
         ("M-s u" . consult-focus-lines)
         ;; Isearch integration
         ("M-s e" . consult-isearch-history)
         :map isearch-mode-map
         ("M-e" . consult-isearch-history)         ;; orig. isearch-edit-string
         ("M-s e" . consult-isearch-history)       ;; orig. isearch-edit-string
         ("M-s l" . consult-line)                  ;; needed by consult-line to detect isearch
         ("M-s L" . consult-line-multi)            ;; needed by consult-line to detect isearch
         ;; Minibuffer history
         :map minibuffer-local-map
         ("M-s" . consult-history)                 ;; orig. next-matching-history-element
         ("M-r" . consult-history))                ;; orig. previous-matching-history-element

  ;; Enable automatic preview at point in the *Completions* buffer. This is
  ;; relevant when you use the default completion UI.
  :hook (completion-list-mode . consult-preview-at-point-mode)

  ;; The :init configuration is always executed (Not lazy)
  :init

  ;; Optionally configure the register formatting. This improves the register
  ;; preview for `consult-register', `consult-register-load',
  ;; `consult-register-store' and the Emacs built-ins.
  (setq register-preview-delay 0.5
        register-preview-function #'consult-register-format)

  ;; Optionally tweak the register preview window.
  ;; This adds thin lines, sorting and hides the mode line of the window.
  (advice-add #'register-preview :override #'consult-register-window)

  ;; Use Consult to select xref locations with preview
  (setq xref-show-xrefs-function #'consult-xref
        xref-show-definitions-function #'consult-xref)

  ;; Configure other variables and modes in the :config section,
  ;; after lazily loading the package.
  :config
  (recentf-mode) ;;turns on recent-f mode so consult can find recently opened files

  ;; Optionally configure preview. The default value
  ;; is 'any, such that any key triggers the preview.
  ;; (setq consult-preview-key 'any)
  ;; (setq consult-preview-key "M-.")
  ;; (setq consult-preview-key '("S-<down>" "S-<up>"))
  ;; For some commands and buffer sources it is useful to configure the
  ;; :preview-key on a per-command basis using the `consult-customize' macro.
  (consult-customize
   consult-theme :preview-key '(:debounce 0.2 any)
   consult-ripgrep consult-git-grep consult-grep
   consult-bookmark consult-recent-file consult-xref
   consult--source-bookmark consult--source-file-register
   consult--source-recent-file consult--source-project-recent-file
   ;; :preview-key "M-."
   :preview-key '(:debounce 0.4 any)))

;; Optionally configure the narrowing key.
;; Both "<" and C-+ work reasonably well.
(setq consult-narrow-key "<") ;; "C-+"

;; Optionally make narrowing help available in the minibuffer.
;; You may want to use `embark-prefix-help-command' or which-key instead.
;; (keymap-set consult-narrow-map (concat consult-narrow-key " ?") #'consult-narrow-help)

(use-package marginalia
  :config
  (marginalia-mode))

(use-package embark
  :bind*
  (("C-;" . embark-dwim)        ;; good alternative: M-.
   ("C-h B" . embark-bindings)) ;; alternative for `describe-bindings'
  :init
  ;; Optionally replace the key help with a completing-read interface
  (setq prefix-help-command #'embark-prefix-help-command)

  ;; Show the Embark target at point via Eldoc. You may adjust the
  ;; Eldoc strategy, if you want to see the documentation from
  ;; multiple providers. Beware that using this can be a little
  ;; jarring since the message shown in the minibuffer can be more
  ;; than one line, causing the modeline to move up and down:

  ;; (add-hook 'eldoc-documentation-functions #'embark-eldoc-first-target)
  ;; (setq eldoc-documentation-strategy #'eldoc-documentation-compose-eagerly)
  :config
  ;; Hide the mode line of the Embark live/completions buffers
  (add-to-list 'display-buffer-alist
               '("\\`\\*Embark Collect \\(Live\\|Completions\\)\\*"
                 nil
                 (window-parameters (mode-line-format . none)))))
;; Consult users will also want the embark-consult package.
(use-package embark-consult
  :hook
  (embark-collect-mode . consult-preview-at-point-mode))

(use-package auctex
  :hook ((LaTeX-mode . LaTeX-preview-setup)
         (LaTeX-mode . turn-on-reftex)
         (LaTeX-mode . flyspell-mode)
         (LaTeX-mode . LaTeX-math-mode))
  :init
  (setq TeX-auto-save t)
  (setq TeX-parse-self t)
  (setq-default TeX-master nil)
  (setq TeX-PDF-mode t)

  ;; IMPORTANT: your PDF is in build/
  (setq TeX-output-dir "build")
  (setq TeX-auto-local "build/auto")

  ;; SyncTeX
  (setq TeX-source-correlate-method 'synctex)
  (setq TeX-source-correlate-mode t)
  (setq TeX-source-correlate-start-server t)

  ;; If you use PDF Tools inside Emacs:
  (setq TeX-view-program-selection '((output-pdf "PDF Tools")))
  (setq TeX-view-program-list '(("PDF Tools" TeX-pdf-tools-sync-view)))

  ;; Make sure LaTeX commands include synctex (latexmk already does, but this doesn't hurt)
  (setq TeX-command-extra-options "-synctex=1 -interaction=nonstopmode -file-line-error")
  )

(defun my-custom-function ()
  "Automatically run `TeX-command-run-all` when a LaTeX file is saved."
  (TeX-command-run-all nil))

(defun add-latex-save-hook ()
  "Add a save hook to compile LaTeX files."
  (add-hook 'after-save-hook #'my-custom-function nil t))

(add-hook 'LaTeX-mode-hook #'add-latex-save-hook)

(use-package markdown-mode
  :mode (("\\.md\\'" . gfm-mode)
         ("\\.markdown\\'" . gfm-mode))
  :config
  ;; syntax-highlight code inside fenced blocks
  (setq markdown-fontify-code-blocks-natively t)
  ;; no space between ``` and the language name
  (setq markdown-spaces-after-code-fence 0)
  :preface
  (defun jekyll-insert-image-url ()
    (interactive)
    (let* ((files (directory-files "../assets/images"))
           (selected-file (completing-read "Select image: " files nil t)))
      (insert (format "![%s](/assets/images/%s)" selected-file selected-file))))

  (defun jekyll-insert-post-url ()
    (interactive)
    (let* ((project-root (projectile-project-root))
           (posts-dir (expand-file-name "_posts" project-root))
           (default-directory posts-dir))
      (let* ((files (remove "." (mapcar #'file-name-sans-extension (directory-files "."))))
             (selected-file (completing-read "Select article: " files nil t)))
        (insert (format "{%% post_url %s %%}" selected-file))))))

;; Prefer side-by-side previews/opening in other windows.
(setq split-height-threshold nil)
(setq split-width-threshold 80)
(cond
 ((and (eq system-type 'darwin) (executable-find "gls"))
  (setq insert-directory-program "gls"
        dired-use-ls-dired t
        dired-listing-switches "-alh --group-directories-first"))
 ((eq system-type 'darwin)
  (setq dired-listing-switches "-alh"))
 (t
  (setq dired-listing-switches "-alh --group-directories-first")))

(use-package nerd-icons)

(use-package nerd-icons-dired
  :hook (dired-mode . nerd-icons-dired-mode))

(with-eval-after-load 'evil
  (evil-define-key 'normal dired-mode-map
    (kbd "h") #'dired-up-directory
    (kbd "l") #'dired-find-file
    (kbd "m") #'dired-mark
    (kbd "u") #'dired-unmark
    (kbd "t") #'dired-toggle-marks
    (kbd "C") #'dired-do-copy
    (kbd "R") #'dired-do-rename
    (kbd "D") #'dired-do-delete
    (kbd "Z") #'dired-do-compress
    (kbd "x") #'dired-do-flagged-delete
    (kbd "+") #'dired-create-directory
    (kbd "-") #'dired-up-directory
    (kbd "M-RET") #'dired-display-file))

(setq delete-by-moving-to-trash t)
;; always delete and copy recursively
(setq dired-recursive-deletes 'always)
(setq dired-recursive-copies 'always)

(use-package projectile
   :config
   (setq projectile-project-search-path '("~/Projects" "~/org"))
   (setq projectile-indexing-method 'alien)
   (projectile-mode 1))

(defun am/org-font-setup ()
  ;; Replace list hyphen with dot
  ;; (font-lock-add-keywords 'org-mode
  ;; '(("^ *\\([-]\\) "
  ;; (0 (prog1 () (compose-region (match-beginning 1) (match-end 1) "•"))))))
  ;; Set faces for heading levels
  (dolist (face '((org-level-1 . 1.6)
                  (org-level-2 . 1.4)
                  (org-level-3 . 1.2)
                  (org-level-4 . 1.0)
                  (org-level-5 . 1.0)
                  (org-level-6 . 1.0)
                  (org-level-7 . 1.0)
                  (org-level-8 . 1.0)))
    (set-face-attribute (car face) nil :font "Inter" :weight 'bold :height (cdr face)))
  ;; Ensure that anything that should be fixed-pitch in Org files appears that way
  (set-face-attribute 'org-block nil :foreground 'unspecified :inherit 'fixed-pitch)
  (set-face-attribute 'org-code nil   :inherit '(shadow fixed-pitch))
  (set-face-attribute 'org-table nil   :inherit '(shadow fixed-pitch))
  (set-face-attribute 'org-verbatim nil :inherit '(shadow fixed-pitch))
  (set-face-attribute 'org-special-keyword nil :inherit '(font-lock-comment-face fixed-pitch))
  (set-face-attribute 'org-meta-line nil :inherit '(font-lock-comment-face fixed-pitch))
  (set-face-attribute 'org-column nil :inherit 'fixed-pitch)
  (set-face-attribute 'org-column-title nil :inherit 'fixed-pitch)
  (set-face-attribute 'org-checkbox nil :inherit 'fixed-pitch))

(defun am/org-setup()
  ;; Add frame borders and window dividers
  (modify-all-frames-parameters
   '((right-divider-width . 40)
     (internal-border-width . 40)))
  (dolist (face '(window-divider
                  window-divider-first-pixel
                  window-divider-last-pixel))
    (face-spec-reset-face face)
    (set-face-foreground face (face-attribute 'default :background)))
  (set-face-background 'fringe (face-attribute 'default :background))

  (setq
   ;; Edit settings
   org-auto-align-tags nil
   org-tags-column 0
   org-catch-invisible-edits 'show-and-error
   org-special-ctrl-a/e t
   org-insert-heading-respect-content t
   line-spacing 0.1

   org-pretty-entities-include-sub-superscripts nil
   ;; Org styling, hide markup etc.
   org-hide-emphasis-markers t
   org-pretty-entities t

   ;; Agenda styling
   org-agenda-tags-column 0
   org-agenda-block-separator ?─
   org-agenda-time-grid
   '((daily today require-timed)
     (800 1000 1200 1400 1600 1800 2000)
     " ┄┄┄┄┄ " "┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄")
   org-agenda-current-time-string
   "◀── now ─────────────────────────────────────────────────")

  ;; Ellipsis styling
  (setq org-ellipsis "…")
  (set-face-attribute 'org-ellipsis nil :inherit 'default :box nil)
  (set-face-attribute 'org-table nil :inherit 'fixed-pitch) )

(defun am/org-mode-setup ()
  ;; (org-indent-mode 1)
  (variable-pitch-mode 1)
  (visual-line-mode 1))

(use-package org
  ;; :straight (:type built-in)
  :hook
  (org-mode . am/org-mode-setup)
  ;; (org-src-mode-hook . company-mode)
  :config
  (setq org-image-actual-width nil
        org-adapt-indentation t
        org-startup-indented t
        org-agenda-files
        '("~/org")
        org-attach-id-dir (expand-file-name "~/references/attach/")
        org-attach-store-link-p 'attached)
  ;; (setq org-blank-before-new-entry
  ;; '((heading . nil)
  ;; (plain-list-item . auto)))
  (setq org-todo-keywords
        '((sequence "TODO(t)" "IN-PROGRESS(i)" "WAITING(w)" "ORDERED(o)" "|" "DONE(d)" "CANCELLED(c)" "RECEIVED(r)")))
  (setq org-hierarchical-todo-statistics nil)

  (defvar am/org-dashboard-summary--updating nil
    "Non-nil while updating a dashboard summary TODO state.")

  (defun am/org-dashboard-summary-heading-p ()
    "Return non-nil when the current Org heading is a dashboard summary."
    (string= (downcase (or (org-entry-get nil "DASHBOARD") "")) "summary"))

  (defun am/org-dashboard-summary--all-states-in-p (states accepted-states)
    "Return non-nil when every item in STATES is in ACCEPTED-STATES."
    (let ((all-states-match t))
      (dolist (state states all-states-match)
        (unless (member state accepted-states)
          (setq all-states-match nil)))))

  (defun am/org-dashboard-summary--child-todo-states ()
    "Return TODO states for descendants of the current summary heading."
    (let ((summary-point (point))
          (summary-level (org-current-level))
          states)
      (save-excursion
        (org-map-entries
         (lambda ()
           (let ((state (org-get-todo-state)))
             (when (and state
                        (/= (point) summary-point)
                        (> (org-current-level) summary-level))
               (push state states))))
         nil
         'tree))
      (nreverse states)))

  (defun am/org-dashboard-summary--target-state (states)
    "Return the parent TODO state implied by child TODO STATES."
    (cond
     ((null states) nil)
     ((am/org-dashboard-summary--all-states-in-p states org-done-keywords)
      (if (am/org-dashboard-summary--all-states-in-p states '("RECEIVED"))
          "RECEIVED"
        "DONE"))
     ((member "IN-PROGRESS" states) "IN-PROGRESS")
     ((member "ORDERED" states) "ORDERED")
     ((member "WAITING" states) "WAITING")
     (t "TODO")))

  (defun am/org-dashboard-summary--nearest-summary-point ()
    "Return the nearest dashboard summary heading at or above point."
    (save-excursion
      (cond
       ((am/org-dashboard-summary-heading-p) (point))
       (t
        (let (summary-point)
          (while (and (not summary-point) (org-up-heading-safe))
            (when (am/org-dashboard-summary-heading-p)
              (setq summary-point (point))))
          summary-point)))))

  (defun am/org-dashboard-summary-update-parent ()
    "Update the nearest dashboard summary TODO state from child TODO states."
    (unless am/org-dashboard-summary--updating
      (let ((summary-point (am/org-dashboard-summary--nearest-summary-point)))
        (when summary-point
          (let ((am/org-dashboard-summary--updating t))
            (save-excursion
              (goto-char summary-point)
              (let* ((states (am/org-dashboard-summary--child-todo-states))
                     (target-state (am/org-dashboard-summary--target-state states))
                     (current-state (org-get-todo-state)))
                (when (and target-state
                           current-state
                           (not (string= current-state target-state)))
                  (org-todo target-state)))))))))

  (defvar am/org-dashboard-cost--updating nil
    "Non-nil while updating dashboard summary COST properties.")

  (defun am/org-dashboard-cost--parse-number (value)
    "Parse VALUE as a numeric Org property."
    (when (and value (string-match-p "[0-9]" value))
      (let ((cleaned (replace-regexp-in-string "[,$[:space:]]" "" value)))
        (when (string-match-p
               "\\`[-+]?\\(?:[0-9]+\\(?:\\.[0-9]*\\)?\\|\\.[0-9]+\\)\\'"
               cleaned)
          (string-to-number cleaned)))))

  (defun am/org-dashboard-cost--format (value)
    "Format VALUE as a COST property."
    (format "%.2f" value))

  (defun am/org-dashboard-cost--child-total ()
    "Return (COUNT . TOTAL) for priced child headings under point."
    (let ((summary-point (point))
          (summary-level (org-current-level))
          (count 0)
          (total 0.0))
      (save-excursion
        (org-map-entries
         (lambda ()
           (when (and (/= (point) summary-point)
                      (> (org-current-level) summary-level))
             (let ((unit-cost (am/org-dashboard-cost--parse-number
                               (org-entry-get nil "UNIT_COST")))
                   (quantity (am/org-dashboard-cost--parse-number
                              (org-entry-get nil "QUANTITY"))))
               (when (and unit-cost quantity)
                 (setq count (1+ count))
                 (setq total (+ total (* unit-cost quantity)))))))
         nil
         'tree))
      (cons count total)))

  (defun am/org-dashboard-cost-update-at-point ()
    "Update the COST property for the dashboard summary heading at point."
    (when (am/org-dashboard-summary-heading-p)
      (let* ((existing-cost (org-entry-get nil "COST"))
             (priced-total (am/org-dashboard-cost--child-total))
             (priced-count (car priced-total))
             (cost (am/org-dashboard-cost--format (cdr priced-total))))
        (when (or (> priced-count 0) existing-cost)
          (unless (string= (or existing-cost "") cost)
            (org-entry-put nil "COST" cost))))))

  (defun am/org-dashboard-cost-update-parent ()
    "Update the nearest dashboard summary COST property."
    (interactive)
    (let ((summary-point (am/org-dashboard-summary--nearest-summary-point)))
      (unless summary-point
        (user-error "No dashboard summary heading at or above point"))
      (save-excursion
        (goto-char summary-point)
        (am/org-dashboard-cost-update-at-point))))

  (defun am/org-dashboard-cost-update-buffer ()
    "Update COST properties for dashboard summary headings in the current buffer."
    (interactive)
    (unless am/org-dashboard-cost--updating
      (let ((am/org-dashboard-cost--updating t)
            summary-markers)
        (org-with-wide-buffer
         (org-map-entries
          (lambda ()
            (when (am/org-dashboard-summary-heading-p)
              (push (point-marker) summary-markers)))
          nil
          'file)
         (dolist (marker (nreverse summary-markers))
           (goto-char marker)
           (am/org-dashboard-cost-update-at-point)
           (set-marker marker nil))))))

  (defun am/org-dashboard-cost-enable ()
    "Enable dashboard summary COST rollups in the current Org buffer."
    (add-hook 'before-save-hook #'am/org-dashboard-cost-update-buffer nil t))

  (add-hook 'org-after-todo-state-change-hook
            #'am/org-dashboard-summary-update-parent)
  (add-hook 'org-mode-hook #'am/org-dashboard-cost-enable)

  (am/org-font-setup)
  (am/org-setup))

(use-package org-modern
  :after org
  :hook (org-mode . org-modern-mode)
  :custom
  (org-modern-star 'replace)
  (org-modern-timestamp nil))

(use-package org-ql
  :after org)

(use-package org-roam
  :init
  (setq org-roam-vs-ack t)
  :custom
  (org-roam-directory (file-truename "~/org/roam/"))
  (org-roam-completion-everywhere t)
  :bind (("C-c n l" . org-roam-buffer-toggle)
         ("C-c n f" . org-roam-node-find)
         ("C-c n i" . org-roam-node-insert)
         :map org-mode-map
         ("C-M-i" . completion-at-point))
  :config
  (org-roam-db-autosync-mode 1)
  (org-roam-setup))

;; Org babel languages
(org-babel-do-load-languages
 'org-babel-load-languages
 '((emacs-lisp . t)
   (python . t)
   (shell . t)
   (C . t)))
(setq org-confirm-babel-evaluate nil)

(defun am/org-babel-refresh-inline-images ()
  "Refresh inline image previews after evaluating Org Babel blocks."
  (when (derived-mode-p 'org-mode)
    (if (fboundp 'org-link-preview-refresh)
        (org-link-preview-refresh)
      (org-display-inline-images nil t))))

(add-hook 'org-babel-after-execute-hook #'am/org-babel-refresh-inline-images)

;; Adjusts org latex font
(setq org-format-latex-options '(:foreground default :background default :scale 1.5 :html-foreground "Black" :html-background "Transparent" :html-scale 1.0 :matchers ("begin" "$1" "$" "$$" "\\(" "\\[")))

(use-package cdlatex
  :hook (org-mode . turn-on-org-cdlatex))

(use-package org-fragtog
  :hook (org-mode . org-fragtog-mode))

(use-package pdf-tools
  :config
  (pdf-tools-install :no-query)
  (require 'pdf-info))

(defun my-pdf-view-mode-hook ()
  (pdf-view-fit-page-to-window)
  (auto-revert-mode))

(add-hook 'pdf-view-mode-hook #'my-pdf-view-mode-hook)

(use-package org-noter
  :after (org pdf-tools)
  :custom
  (org-noter-supported-modes '(pdf-view-mode)))

(use-package org-pdftools
  :after (org pdf-tools)
  :hook (org-mode . org-pdftools-setup-link))

(use-package org-noter-pdftools
  :after (org-noter org-pdftools pdf-tools)
  :config
  ;; Add a function to ensure precise note is inserted
  (defun org-noter-pdftools-insert-precise-note (&optional toggle-no-questions)
    (interactive "P")
    (org-noter--with-valid-session
     (let ((org-noter-insert-note-no-questions
            (if toggle-no-questions
                (not org-noter-insert-note-no-questions)
              org-noter-insert-note-no-questions))
           (org-pdftools-use-isearch-link t)
           (org-pdftools-use-freepointer-annot t))
       (org-noter-insert-note (org-noter--get-precise-info)))))

  (defun org-noter-set-start-location (&optional arg)
    "When opening a session with this document, go to the current location.
With a prefix ARG, remove start location."
    (interactive "P")
    (org-noter--with-valid-session
     (let ((inhibit-read-only t)
           (ast (org-noter--parse-root))
           (location
            (org-noter--doc-approx-location
             (when (called-interactively-p 'any) 'interactive))))
       (with-current-buffer (org-noter--session-notes-buffer session)
         (org-with-wide-buffer
          (goto-char (org-element-property :begin ast))
          (if arg
              (org-entry-delete nil org-noter-property-note-location)
            (org-entry-put nil org-noter-property-note-location
                           (org-noter--pretty-print-location location))))))))

  (with-eval-after-load 'pdf-annot
    (add-hook 'pdf-annot-activate-handler-functions
              #'org-noter-pdftools-jump-to-note)))

(use-package org-roam-ui
  :straight
  (:host github :repo "org-roam/org-roam-ui" :branch "main" :files ("*.el" "out"))
  :after org-roam
  ;;         normally we'd recommend hooking orui after org-roam, but since org-roam does not have
  ;;         a hookable mode anymore, you're advised to pick something yourself
  ;;         if you don't care about startup time, use
  ;;  :hook (after-init . org-roam-ui-mode)
  :config
  (setq org-roam-ui-sync-theme t
        org-roam-ui-follow t
        org-roam-ui-update-on-save t
        org-roam-ui-open-on-start t))

(setq org-publish-project-alist
      '(("my-org-files"
         :base-directory "~/org/roam"
         :base-extension "org"
         :recursive t
         :publishing-directory "~/public_html"
         :publishing-function org-html-publish-to-html
         :with-broken-links t
         )))

;; org special edit splits to the right
(setq org-src-window-setup 'split-window-right)

(use-package citar
    :custom
    (citar-bibliography '("~/references/bibfile.bib"))
    ;;(citar-open-entry-function #'citar-open-entry-in-zotero)
    (citar-open-entry-function #'citar-open-entry-in-file)
    (citar-library-paths '("~/references/articles" "~/references/books"))
    :hook
    (LaTeX-mode . citar-capf-setup)
    (org-mode . citar-capf-setup))
  (setq org-cite-global-bibliography '("~/references/bibfile.bib"))
  (use-package citeproc
    :after org)
  (setq org-cite-csl-locales-dir
        (expand-file-name "~/references/csl/locales"))
  (setq org-cite-export-processors
        `((html . (csl ,(expand-file-name "~/references/csl/nature.csl")))
          (t . (csl ,(expand-file-name "~/references/csl/nature.csl")))))

  (use-package citar-embark
    :after citar embark
    :no-require
    :config (citar-embark-mode))

  (use-package citar-org-roam
    :after (citar org-roam)
    :config (citar-org-roam-mode))
  (setq citar-org-roam-note-title-template "${author} - ${title}")
  (setq org-roam-capture-templates
        '(("d" "default" plain
           "%?"
           :target
           (file+head
            "%<%Y%m%d%H%M%S>-${slug}.org"
            "#+title: ${note-title}\n#+STARTUP: latexpreview")
           :unnarrowed t)
          ("n" "literature note" plain
           "%?"
           :target
           (file+head
            "%(expand-file-name (or citar-org-roam-subdir \"\") org-roam-directory)/${citar-citekey}.org"
            "#+title: ${citar-citekey} (${citar-date}). ${note-title}.\n#+created: %U\n#+last_modified: %U\n\n#+STARTUP: latexpreview")
           :unnarrowed t)))
  (setq citar-org-roam-capture-template-key "n")

  (use-package org-ref
    :after (org-roam org))
    ;; :config
    ;; (setq org-ref-default-bibliography '("~/references/bibfile.bib")
    ;;       org-ref-pdf-directory "~/references/pdfs/"))
  (require 'doi-utils)

  (use-package bibtex-completion
    :after (org-roam org)
    :custom
    (bibtex-completion-bibliography '("~/references/bibfile.bib"))
    (bibtex-completion-library-path '("~/references/articles" "~/references/books"))
    (bibtex-completion-notes-path "~/org/roam"))

  (defun am/org-export--copy-files-skip-existing (files destination)
    "Copy FILES into DESTINATION, skipping existing destination files."
    (let ((destination (file-name-as-directory (expand-file-name destination)))
          (copied 0)
          (skipped 0)
          (missing 0))
      (make-directory destination t)
      (dolist (source (delete-dups (mapcar #'expand-file-name files)))
        (cond
         ((not (file-regular-p source))
          (setq missing (1+ missing)))
         (t
          (let ((target (expand-file-name (file-name-nondirectory source) destination)))
            (if (file-exists-p target)
                (setq skipped (1+ skipped))
              (copy-file source target nil)
              (setq copied (1+ copied)))))))
      (list :copied copied :skipped skipped :missing missing)))

  (defun am/org-export--safe-directory-name (name)
    "Return NAME sanitized for use as a directory name."
    (let ((clean (replace-regexp-in-string
                  "[[:cntrl:]/\\:*?\"<>|]+" "_" (or name ""))))
      (setq clean (replace-regexp-in-string
                   "\\`[[:space:]_.-]+\\|[[:space:]_.-]+\\'" "" clean))
      (if (string= clean "") "No heading" clean)))

  (defun am/org-export--copy-file-records-skip-existing (records destination)
    "Copy file RECORDS into DESTINATION, skipping existing destination files.

Each record is a cons cell of the form (SOURCE-FILE . RELATIVE-DIRECTORY)."
    (let ((destination (file-name-as-directory (expand-file-name destination)))
          (copied 0)
          (skipped 0)
          (missing 0))
      (make-directory destination t)
      (dolist (record (delete-dups records))
        (let* ((source (expand-file-name (car record)))
               (relative-directory (cdr record))
               (target-directory (if relative-directory
                                     (expand-file-name relative-directory destination)
                                   destination)))
          (cond
           ((not (file-regular-p source))
            (setq missing (1+ missing)))
           (t
            (make-directory target-directory t)
            (let ((target (expand-file-name (file-name-nondirectory source)
                                            target-directory)))
              (if (file-exists-p target)
                  (setq skipped (1+ skipped))
                (copy-file source target nil)
                (setq copied (1+ copied))))))))
      (list :copied copied :skipped skipped :missing missing)))

  (defun am/org-export--citation-file-records-in-buffer ()
    "Return citation file records grouped by nearest Org heading."
    (require 'citar)
    (require 'oc)
    (let (records)
      (save-restriction
        (widen)
        (let* ((tree (org-element-parse-buffer))
               (keys (delete-dups
                      (delq nil
                            (org-element-map tree 'citation-reference
                              (lambda (reference)
                                (org-element-property :key reference))))))
               (files-by-key (and keys (citar-get-files keys))))
          (when files-by-key
            (org-element-map tree 'citation-reference
              (lambda (reference)
                (let* ((key (org-element-property :key reference))
                       (heading (org-element-lineage reference '(headline) t))
                       (heading-name (and heading (org-element-property :raw-value heading)))
                       (relative-directory (and heading-name
                                                (am/org-export--safe-directory-name heading-name))))
                  (dolist (file (gethash key files-by-key))
                    (push (cons file relative-directory) records))))))))
      (delete-dups (nreverse records))))

  (defun org-export-citation-files (destination)
    "Copy cited literature files from the current Org buffer to DESTINATION.

Files that already exist in DESTINATION are skipped."
    (interactive (list (read-directory-name "Export citation files to: ")))
    (unless (derived-mode-p 'org-mode)
      (user-error "This command must be run from an Org buffer"))
    (let* ((records (am/org-export--citation-file-records-in-buffer))
           (result (am/org-export--copy-file-records-skip-existing records destination)))
      (message "Exported citation files: %d copied, %d skipped, %d missing"
               (plist-get result :copied)
               (plist-get result :skipped)
               (plist-get result :missing))))

  (defun am/org-export--attach-files-in-buffer ()
    "Return Org attach files from all headings in the current buffer."
    (require 'org-attach)
    (let (files)
      (save-restriction
        (widen)
        (save-excursion
          (org-map-entries
           (lambda ()
             (when-let ((directory (org-attach-dir)))
               (dolist (file (org-attach-file-list directory))
                 (push (expand-file-name file directory) files))))
           nil 'file)))
      (delete-dups (nreverse files))))

  (defun org-export-attach-files (destination)
    "Copy Org attach files from the current buffer to DESTINATION.

Files that already exist in DESTINATION are skipped."
    (interactive (list (read-directory-name "Export attach files to: ")))
    (unless (derived-mode-p 'org-mode)
      (user-error "This command must be run from an Org buffer"))
    (let* ((files (am/org-export--attach-files-in-buffer))
           (result (am/org-export--copy-files-skip-existing files destination)))
      (message "Exported attach files: %d copied, %d skipped, %d missing"
               (plist-get result :copied)
               (plist-get result :skipped)
               (plist-get result :missing))))

  ;; Sci-hub
(defun sci-hub-pdf-url (doi)
  "Get url to the pdf from SCI-HUB"
  (setq *doi-utils-pdf-url* (concat "https://sci-hub.se/" doi) ;captcha
        *doi-utils-waiting* t
        )
  ;; try to find PDF url (if it exists)
  (url-retrieve (concat "https://sci-hub.se/" doi)
            (lambda (status)
              (goto-char (point-min))
              (while (search-forward-regexp "\\(https://\\|//sci-hub.se/downloads\\).+download=true'" nil t)
                (let ((foundurl (match-string 0)))
                  (message foundurl)
                  (if (string-match "https:" foundurl)
                  (setq *doi-utils-pdf-url* foundurl)
                (setq *doi-utils-pdf-url* (concat "https:" foundurl))))
                (setq *doi-utils-waiting* nil))))
  (while *doi-utils-waiting* (sleep-for 0.1))
  *doi-utils-pdf-url*)

(use-package which-key
  :diminish which-key-mode
  :config
  (setq which-key-idle-delay 0)
  (which-key-mode))

(use-package helpful
  ;;:custom
  ;;(counsel-describe-function-function #'helpful-callable)
  ;;(counsel-describe-variable-function #'helpful-variable)
  :bind
  ;;([remap describe-function] . counsel-describe-function)
  ([remap describe-command] . helpful-command)
  ;;([remap describe-variable] . counsel-describe-variable)
  ([remap describe-key] . helpful-key))

(use-package magit)
(use-package transient) ;; for magit
(use-package vterm
  :bind (("C-`" . am/vterm-toggle))
  :init
  (defvar am/vterm-buffer-name "*am:vterm*")

  (defun am/vterm-toggle ()
    "Toggle a persistent vterm window at the bottom of the frame."
    (interactive)
    (let* ((buffer (get-buffer am/vterm-buffer-name))
           (window (and buffer (get-buffer-window buffer nil))))
      (if (window-live-p window)
          (delete-window window)
        (let ((default-directory
               (or (when-let ((project (project-current nil)))
                     (project-root project))
                   default-directory)))
          (unless (buffer-live-p buffer)
            (require 'vterm)
            (setq buffer (get-buffer-create am/vterm-buffer-name))
            (with-current-buffer buffer
              (vterm-mode)))
          (select-window
           (display-buffer-in-side-window
            buffer
            '((side . bottom)
              (slot . -1)
              (window-height . 10)))))))))

  (defun am/vterm-open ()
    "Open the persistent vterm window at the bottom of the frame."
    (let ((buffer (get-buffer am/vterm-buffer-name)))
      (unless (buffer-live-p buffer)
        (require 'vterm)
        (setq buffer (get-buffer-create am/vterm-buffer-name))
        (with-current-buffer buffer
          (vterm-mode)))
      (select-window
       (display-buffer-in-side-window
        buffer
        '((side . bottom)
          (slot . -1)
          (window-height . 10))))))

  (defun am/rclone-copy-references ()
    "Run the references rclone copy command in the persistent vterm window."
    (interactive)
    (am/vterm-open)
    (vterm-send-string
     "rclone copy ~/references dropbox:references --filter-from ~/references/rclone-ignore.txt -P")
    (vterm-send-return))

  (defun am/project-ide-toggle ()
    "Toggle Treemacs and a project-specific vterm for the current project."
    (interactive)
    (require 'projectile)
    (require 'treemacs)
    (require 'vterm)
    (let* ((project-root (projectile-acquire-root))
           (vterm-buffer-name
            (projectile-generate-process-name "vterm" nil project-root))
           (vterm-buffer (get-buffer vterm-buffer-name))
           (vterm-window (and vterm-buffer
                              (get-buffer-window vterm-buffer nil)))
           (treemacs-window (treemacs-get-local-window)))
      (if (and (window-live-p treemacs-window)
               (window-live-p vterm-window))
          (progn
            (delete-window vterm-window)
            (delete-window treemacs-window))
        (treemacs-add-and-display-current-project)
        (unless (buffer-live-p vterm-buffer)
          (setq vterm-buffer (get-buffer-create vterm-buffer-name))
          (with-current-buffer vterm-buffer
            (setq-local default-directory project-root)
            (vterm-mode)))
        (select-window
         (display-buffer-in-side-window
          vterm-buffer
          '((side . bottom)
            (slot . -1)
            (window-height . 10)))))))
(use-package org-download
  :config
  (setq org-download-image-dir "~/Figures/")  ; Set the directory where images will be saved
  ;; (setq org-download-screenshot-method "gnome-screenshot -a -f %s")  ; Set the method for screenshot
  (setq org-download-screenshot-method "grim -g \"$(slurp)\" %s")
  (add-hook 'dired-mode-hook 'org-download-enable) ;Enable org-download in dired-mode
  (org-download-enable))

(use-package org-mac-image-paste
  :straight (org-mac-image-paste :type git :host github :repo "jdtsmith/org-mac-image-paste")
  :if (eq window-system 'mac)
  :config
  (org-mac-image-paste-mode 1)
  (setq org-use-property-inheritance t) ;Inherit :ID/etc. from parent nodes
  (setq org-image-actual-width nil)  ;allow #+ATTR_ORG: :width 300 etc.
  (setq org-attach-id-dir "../../Figures") ;; copy-pasted files in Figures dir
  ;; (setq org-attach-id-dir ".org-attach") ; make the attachment directory less visible

  ;; Optional: You can bind the paste image function to a key if desired
  (define-key org-mode-map (kbd "C-c C-x p") #'org-mac-image-paste)
  )

;; Persist history over Emacs restarts. Vertico sorts by history position.
(use-package savehist
  :init
  (savehist-mode))

(when (and (eq system-type 'gnu/linux)
           (or (getenv "WSL_DISTRO_NAME")
               (getenv "WSL_INTEROP")
               (getenv "WSLENV")))
  (defun my-org--paste-image-program ()
    "Return the helper used to save a Windows clipboard image."
    (or (executable-find "win-paste-image")
        (let ((fallback "/run/current-system/sw/bin/win-paste-image"))
          (and (file-executable-p fallback) fallback))
        (user-error "win-paste-image is not on PATH; rebuild the WSL host")))

  (defun my-org--require-image-paste-target ()
    "Return the current Org file, or signal why image paste cannot continue."
    (unless (derived-mode-p 'org-mode)
      (user-error "This command is intended for Org buffers"))
    (or (buffer-file-name)
        (user-error "Save this Org buffer before pasting an image")))

  (defun my-org--paste-windows-clipboard-image (target-file)
    "Save the Windows clipboard image to TARGET-FILE."
    (let* ((program (my-org--paste-image-program))
           (target-dir (file-name-directory target-file))
           (temp-file
            (concat
             (make-temp-name
              (expand-file-name ".clipboard-image-" target-dir))
             ".png")))
      (unwind-protect
          (progn
            (make-directory target-dir t)
            (with-temp-buffer
              (let ((exit-code (call-process program nil t nil temp-file)))
                (unless (and (integerp exit-code) (zerop exit-code))
                  (let ((output
                         (replace-regexp-in-string
                          "\\`[ \t\n\r]+\\|[ \t\n\r]+\\'" "" (buffer-string))))
                    (user-error
                     "Could not paste Windows clipboard image%s"
                     (if (string= output "") "" (concat ": " output)))))))
            (unless (and (file-readable-p temp-file)
                         (> (file-attribute-size (file-attributes temp-file)) 0))
              (user-error "win-paste-image did not create a readable image file"))
            (rename-file temp-file target-file t))
        (when (file-exists-p temp-file)
          (delete-file temp-file))))
    target-file)

  (defvar my-org-pasted-image-width 600
    "Default pixel width for images pasted into Org buffers.")

  (defun my-org--insert-image-link (target-file org-file)
    "Insert a resized Org image link to TARGET-FILE relative to ORG-FILE."
    (let* ((org-dir (file-name-directory org-file))
           (link (org-link-escape (file-relative-name target-file org-dir))))
      (insert
       (format
        "#+ATTR_ORG: :width %d\n#+ATTR_HTML: :width %dpx\n#+ATTR_LATEX: :width 0.8\\linewidth\n[[file:%s]]"
        my-org-pasted-image-width
        my-org-pasted-image-width
        link))
      (org-display-inline-images)))

  (defun my-org-paste-image ()
    "Paste the Windows clipboard image next to the current Org file."
    (interactive)
    (let* ((org-file (my-org--require-image-paste-target))
           (org-dir (file-name-directory org-file))
           (prefix
            (expand-file-name
             (format "%s_%s_"
                     (file-name-base org-file)
                     (format-time-string "%Y%m%d"))
             org-dir))
           (target-file (concat (make-temp-name prefix) ".png")))
      (my-org--paste-windows-clipboard-image target-file)
      (my-org--insert-image-link target-file org-file)))

  (defun my-org-paste-image-to-dir (image-name)
    "Paste the Windows clipboard image into ~/references/images/IMAGE-NAME.png."
    (interactive "sImage name: ")
    (let* ((org-file (my-org--require-image-paste-target))
           (name (file-name-sans-extension
                  (file-name-nondirectory image-name)))
           (target-file
            (expand-file-name
             (concat name ".png")
             (expand-file-name "~/references/images/"))))
      (when (string= name "")
        (user-error "Image name cannot be empty"))
      (when (and (file-exists-p target-file)
                 (not (yes-or-no-p
                       (format "Overwrite %s? " target-file))))
        (user-error "Cancelled"))
      (my-org--paste-windows-clipboard-image target-file)
      (my-org--insert-image-link target-file org-file)))

  (defun am/wsl--windows-path (path)
    "Return PATH converted to a Windows path."
    (let ((wslpath (or (executable-find "wslpath")
                       (user-error "wslpath is not on PATH"))))
      (with-temp-buffer
        (let ((exit-code (call-process wslpath nil t nil "-w" path)))
          (unless (and (integerp exit-code) (zerop exit-code))
            (user-error
             "Could not convert path for Explorer: %s"
             (replace-regexp-in-string
              "\\`[ \t\n\r]+\\|[ \t\n\r]+\\'" "" (buffer-string)))))
        (replace-regexp-in-string "[\r\n]+\\'" "" (buffer-string)))))

  (defun am/wsl-open-in-explorer (file _link)
    "Open FILE in Windows Explorer from WSL."
    (let ((explorer (or (executable-find "explorer.exe")
                        (let ((fallback "/mnt/c/Windows/explorer.exe"))
                          (and (file-executable-p fallback) fallback))
                        (user-error "explorer.exe is not available"))))
      (start-process "explorer.exe" nil explorer (am/wsl--windows-path file))))

  (with-eval-after-load 'org
    (add-to-list 'org-file-apps '(directory . am/wsl-open-in-explorer))))

;; WSL-specific setup
(when (and (eq system-type 'gnu/linux)
           (getenv "WSLENV"))

  ;; pgtk is only available in Emacs 29+
  ;; without it Emacs fonts don't scale properly on
  ;; HiDPI display
  (when (< emacs-major-version 29)
    (set-frame-font "Inconsolata 28" t t))

  ;; Teach Emacs how to open links in your default Windows browser
  (let ((cmd-exe "/mnt/c/Windows/System32/cmd.exe")
        (cmd-args '("/c" "start")))
    (when (file-exists-p cmd-exe)
      (setq browse-url-generic-program  cmd-exe
            browse-url-generic-args     cmd-args
            browse-url-browser-function 'browse-url-generic
            search-web-default-browser 'browse-url-generic))))

(use-package general
  :config
  (general-create-definer am/leader-keys
    :keymaps '(normal insert visual emacs)
    :prefix "SPC"
    :global-prefix "C-SPC")
  (general-define-key ;; evil overrides
   :states '(normal visual)
   :keymaps 'global-map
   "C-f" 'consult-ripgrep
   "C-." 'embark-act
   "C-i" 'evil-jump-forward)
  (am/leader-keys
    "a"  '(:ignore a :which-key "AI")
    "aa" '(agent-shell :which-key "Agent Shell")
    "ac" '(agent-shell-openai-start-codex :which-key "Codex")
    "ao" '(agent-shell-opencode-start-agent :which-key "OpenCode")
    "ad" '(agent-shell-dashboard :which-key "Dashboard")
    "at" '(agent-shell-toggle :which-key "Toggle")
    "ap" '(agent-shell-prompt-compose :which-key "Compose Prompt")
    "an" '(agent-shell-new-shell :which-key "New Session")
    "aw" '(agent-shell-new-worktree-shell :which-key "New Worktree")
    "af" '(agent-shell-fork :which-key "Fork Session")
    "ar" '(agent-recall-resume :which-key "Recall Resume")
    "av" '(agent-shell-set-session-model :which-key "Set Model")
    "aM" '(agent-shell-set-session-mode :which-key "Set Mode")
    "aT" '(agent-shell-set-session-thought-level :which-key "Set Thinking")
    "aC" '(agent-shell-cycle-session-mode :which-key "Cycle Mode")
    "aO" '(agent-shell-set-session-config-option :which-key "Set Option")
    "ai" '(agent-shell-send-clipboard-image :which-key "Clipboard Image")
    "as" '(agent-shell-send-screenshot :which-key "Screenshot")
    "al" '(org-store-link :which-key "Store Link")
    "aL" '(org-insert-link :which-key "Insert Link")
    "ab" '(agent-recall-browse :which-key "Recall Browse")
    "a/" '(agent-recall-search :which-key "Recall Search")
    "a?" '(agent-recall-search-live :which-key "Recall Live Search")
    "aI" '(agent-recall-reindex :which-key "Recall Reindex")
    "aS" '(agent-recall-stats :which-key "Recall Stats")

    "b"  '(:ignore b :which-key "Buffer")
    "bb" '(next-buffer :which-key "Next")
    "bn" '(next-buffer :which-key "Next")
    "bp" '(previous-buffer :which-key "Previous")
    "bN" '(previous-buffer :which-key "Previous")
    "bl" '(consult-buffer :which-key "Switch")
    "bk" '(kill-buffer :which-key "Kill")

    "w"  '(:ignore w :which-key "Window")
    "ww" '(evil-window-next :which-key "Next")
    "wn" '(evil-window-next :which-key "Next")
    "wN" '(evil-window-prev :which-key "Previous")
    "wh" '(evil-window-left :which-key "Focus Left")
    "wj" '(evil-window-down :which-key "Focus Down")
    "wk" '(evil-window-up :which-key "Focus Up")
    "wl" '(evil-window-right :which-key "Focus Right")
    "ws" '(evil-window-split :which-key "Horizontal Split")
    "wv" '(evil-window-vsplit :which-key "Vertical Split")
    "wc" '(evil-window-delete :which-key "Close")
    "wo" '(toggle-delete-other-windows :which-key "Close Others")
    "w=" '(enlarge-window :which-key "Grow")
    "w-" '(shrink-window :which-key "Shrink")

    ":" '(execute-extended-command :which-key "M-x")

    "h"  '(:ignore h :which-key "Help")
    "hv" '(describe-variable :which-key "Describe Variable")
    "hf" '(describe-function :which-key "Describe Function")
    "hi" '(indent-region :which-key "Indent Region")
    "hs" '(describe-symbol :which-key "Describe Symbol")
    "hm" '(describe-mode :which-key "Describe Mode")
    "hk" '(describe-key :which-key "Describe Key")

    "f"  '(:ignore f :which-key "Files")
    "fr" '(consult-recent-file :which-key "Recent Files")
    "ff" '(find-file :which-key "Find File")
    "fc" '(am/rclone-copy-references :which-key "Copy References")

    "p"  '(:ignore p :which-key "Project")
    "pp" '(projectile-switch-project :which-key "Switch Project")
    "pf" '(projectile-find-file :which-key "Find File")
    "pd" '(projectile-find-dir :which-key "Find Directory")
    "ps" '(projectile-ripgrep :which-key "Search Project")
    "pt" '(am/project-ide-toggle :which-key "Toggle IDE View")
    "pb" '(projectile-ibuffer :which-key "Project Buffers")
    "pk" '(projectile-kill-buffers :which-key "Kill Buffers")
    "pc" '(projectile-compile-project :which-key "Compile Project")
    "pr" '(projectile-replace :which-key "Replace Project")

    "l"  '(:ignore l :which-key "Latex")
    "lg" '(pdf-sync-forward-search :which-key "source-to-pdf")

    "o"  '(:ignore o :which-key "org")
    "ot" '(org-babel-tangle :which-key "Tangle")
    "of" '(org-roam-node-find :which-key "Find Node")
    "od" '(org-toggle-inline-images :which-key "Toggle Images")
    "or" '(org-mac-image-paste-refresh-this-node :which-key "Refresh Images")
    "oe" '(org-edit-special :which-key "org Edit Special")

    "c"  '(:ignore c :which-key "Citations")
    "ci" '(citar-insert-citation :which-key "insert-citation")
    "ce" '(citar-open-entry :which-key "open-entry")

    "z" '(repeat :which-key "Repeat Command")

    "." '(find-file :which-key "Find file")

    "t"  '(:ignore b :which-key "Text")
    "ta" '(text-scale-adjust :which-key "Adjust Text Scale")
    )
  (with-eval-after-load 'treemacs-evil
    (am/treemacs-enable-leader-keys)))

(use-package eglot
  :straight (:type built-in)
  :config
  ;; Python
  (add-to-list 'eglot-server-programs
               '(python-ts-mode . ("pyright-langserver" "--stdio")))
  ;; C / C++
  (add-to-list 'eglot-server-programs
               '((c-mode c-ts-mode c++-mode c++-ts-mode)
                 . ("clangd")))
  ;; Nix
  (add-to-list 'eglot-server-programs
               '((nix-mode nix-ts-mode) . ("nixd")))

  ;; Org babel Python src blocks
  (add-to-list 'org-src-lang-modes '("python" . python-ts))
  (add-to-list 'org-src-lang-modes '("C" . c))
  (add-to-list 'org-src-lang-modes '("cpp" . c++)))

(use-package apheleia
  :hook (prog-mode . apheleia-mode)
  :config
  (setf (alist-get 'python-ts-mode apheleia-mode-alist)
        '(ruff)))

(let ((tree-sitter-dir (expand-file-name "tree-sitter" user-emacs-directory)))
  (when (file-directory-p tree-sitter-dir)
    (add-to-list 'treesit-extra-load-path tree-sitter-dir)))

;; Prefer explicit tree-sitter mode remaps over `treesit-auto`.
(setq major-mode-remap-alist
      '((python-mode . python-ts-mode)
        (css-mode . css-ts-mode)
        (js-mode . js-ts-mode)
        (c-mode . c-ts-mode)
        (c++-mode . c++-ts-mode)))

(defun uv-activate ()
  "Activate Python environment managed by uv based on current project directory."
  (interactive)
  (let* ((project-root (project-root (project-current t)))
         (venv-path (expand-file-name ".venv" project-root))
         (python-path (expand-file-name
                       (if (eq system-type 'windows-nt)
                           "Scripts/python.exe"
                         "bin/python")
                       venv-path)))
    (if (file-exists-p python-path)
        (unless (equal (getenv "VIRTUAL_ENV") venv-path)
          (setq python-shell-interpreter python-path)
          (let ((venv-bin-dir (file-name-directory python-path)))
            (setq exec-path (cons venv-bin-dir
                                  (remove venv-bin-dir exec-path))))
          (setenv "PATH" (concat (file-name-directory python-path)
                                 path-separator
                                 (getenv "PATH")))
          (setenv "VIRTUAL_ENV" venv-path)
          (setenv "PYTHONHOME" nil)
          (message "Activated UV Python environment at %s" venv-path))
      (error "No UV Python environment found in %s" project-root))))

(defun am/python-project-setup ()
  (when (and buffer-file-name
             (string-match-p "\\.py\\'" buffer-file-name))
    (uv-activate)
    (eglot-ensure)
    (unless (python-shell-get-process)
      (run-python))))

(add-hook 'python-ts-mode-hook #'am/python-project-setup)

;; (use-package lazy-ruff
;; :bind (("C-c f" . lazy-ruff-lint-format-dwim)) ;; keybinding
;; :config
;; (lazy-ruff-global-mode t)) ;; Enable the lazy-ruff minor mode globally


(setq python-indent-offset 4)
(setq org-edit-src-content-indentation 2)
(setq org-src-tab-acts-natively t)
(setq evil-auto-indent t)
(setq help-window-select t)

(advice-add 'save-place-find-file-hook :after
            (lambda (&rest _)
              (when buffer-file-name (ignore-errors (recenter)))))

(use-package nix-mode
  :mode "\\.nix\\'")

(use-package verilog-mode
  :mode ("\\.v\\'" "\\.vh\\'" "\\.sv\\'" "\\.svh\\'")
  :init
  (setq verilog-indent-level             2
        verilog-indent-level-module      2
        verilog-indent-level-declaration 2
        verilog-indent-level-behavioral  2
        verilog-indent-level-directive   2
        verilog-case-indent              2
        verilog-auto-newline             nil
        verilog-auto-indent-on-newline   t
        verilog-tab-always-indent        t
        verilog-align-ifelse             t
        verilog-align-assign-expr        t
        verilog-minimum-comment-distance 40
        verilog-indent-begin-after-if    t
        verilog-auto-delete-trailing-whitespace nil))

;; `verilog-ts-mode` requires the `systemverilog` grammar, not the older
;; `verilog` grammar. Add this after `verilog-mode` so its `:mode` entry does
;; not take precedence.
(add-to-list 'auto-mode-alist
             (cons "\\.s?vh?\\'"
                   (if (treesit-language-available-p 'systemverilog)
                       'verilog-ts-mode
                     'verilog-mode)))

(use-package verilog-ext
  :straight (:host github :repo "gmlarumbe/verilog-ext")
  :after (verilog-mode eglot apheleia)
  :hook ((verilog-mode . verilog-ext-mode)
         (verilog-mode . eglot-ensure))
  :init
  (setq verilog-ext-feature-list
        '(font-lock
          xref
          capf
          hierarchy
          beautify
          navigation
          formatter
          compilation
          imenu
          which-func
          hideshow
          typedefs
          time-stamp
          block-end-comments
          eglot
          ports))
  :config
  (verilog-ext-mode-setup))

(with-eval-after-load 'eglot
  ;; Pick one server you actually have installed in your dev shell.
  ;; `verible-verilog-ls` is a good default if available.
  (add-to-list 'eglot-server-programs
               '((verilog-mode verilog-ts-mode) . ("verible-verilog-ls"))))

(with-eval-after-load 'apheleia
  ;; Format SystemVerilog/Verilog with Verible if it is installed.
  (setf (alist-get 'verilog-mode apheleia-mode-alist)
        '(verible-verilog-format))
  (setf (alist-get 'verilog-ts-mode apheleia-mode-alist)
        '(verible-verilog-format))
  (setf (alist-get 'verible-verilog-format apheleia-formatters)
        '("verible-verilog-format" "--indentation_spaces" "2" "-")))

(use-package scad-mode
  :straight (:host github
             :repo "openscad/emacs-scad-mode"
             :files ("*.el"))
  :mode ("\\.scad\\'" . scad-mode)
  :preface
  (defun am/scad-eglot-setup ()
    (remove-hook 'flymake-diagnostic-functions #'scad-flymake t)
    (eglot-ensure))
  :hook (scad-mode . am/scad-eglot-setup)
  :config
  (with-eval-after-load 'eglot
    (add-to-list 'eglot-server-programs
                 '(scad-mode . ("openscad-lsp" "--stdio")))))

(with-eval-after-load 'org
  (require 'ob-scad)
  (add-to-list 'org-babel-load-languages '(scad . t)))
