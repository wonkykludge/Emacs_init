;; init.el --- Emacs configuration

;; INSTALL PACKAGES
;; --------------------------------------

(require 'package)

(add-to-list 'package-archives
       '("melpa" . "http://melpa.org/packages/") t)

(package-initialize)
(when (not package-archive-contents)
  (package-refresh-contents))

(defvar myPackages
  '(better-defaults
    ein
    elpy
    flycheck
    popup
    ample-theme
    py-autopep8
    undo-tree
    pos-tip
    js2-mode))

(mapc #'(lambda (package)
    (unless (package-installed-p package)
      (package-install package)))
      myPackages)

;; BASIC CUSTOMIZATION
;; --------------------------------------

(setq inhibit-startup-message t) ;; hide the startup message
(load-theme 'ample t) ;; load material theme
(global-linum-mode t) ;; enable line numbers globally

;; PYTHON CONFIGURATION
;; --------------------------------------

(elpy-enable)
(elpy-use-ipython)
(global-undo-tree-mode t)
(tool-bar-mode -1)
(menu-bar-mode -1) 
;; use flycheck not flymake with elpy
(when (require 'flycheck nil t)
  (setq elpy-modules (delq 'elpy-module-flymake elpy-modules))
  (add-hook 'elpy-mode-hook 'flycheck-mode))

;; enable autopep8 formatting on save
(require 'py-autopep8)
(add-hook 'elpy-mode-hook 'py-autopep8-enable-on-save)

;; Type:
;;     M-x package-install RET jedi RET
;;     M-x jedi:install-server RET
;; Then open Python file.

;; Standard Jedi.el setting

(defun project-directory (buffer-name)
  "Returns the root directory of the project that contains the
given buffer. Any directory with a .git directory is considered
to be a project root."
  (let ((git-dir (file-name-directory buffer-name)))
    (while (and (not (file-exists-p (concat git-dir ".git")))
                git-dir)
      (setq git-dir
            (if (equal git-dir "/")
                nil
              (file-name-directory (directory-file-name git-dir)))))
    git-dir))

(defun project-name (buffer-name)
  "Returns the name of the project that contains the given buffer."
  (let ((git-dir (project-directory buffer-name)))
    (if git-dir
        (file-name-nondirectory
         (directory-file-name git-dir))
      nil)))

(defun virtualenv-directory (buffer-name)
  "Returns the virtualenv that corresponds to the given
buffer. Virtualenvs are assumed to be in ~/.virtualenvs/ and to
have the same name as the project that uses them."
  (let ((project-name (project-name buffer-name)))
    (when project-name
      (let ((venv-dir (expand-file-name (concat "~/.virtualenvs/" project-name))))
        (when (file-exists-p venv-dir)
          venv-dir)))))

(defun jedi-setup-args ()
  "Defines a buffer local jedi:server-args variable with the
virtualenv path of the current buffer. If the current buffer
doesn't belong to a project, and has no virtualenv of its own,
the most recently found virtualenv will be used."
  (let ((venv-dir (virtualenv-directory buffer-file-name)))
    (when venv-dir
        (setq jedi-last-venv-dir venv-dir))
    (when (and (boundp 'jedi-last-venv-dir) jedi-last-venv-dir)
      (set (make-local-variable 'jedi:server-args) (list "--virtual-env" jedi-last-venv-dir)))))

(setq jedi:setup-keys t)
(setq jedi:complete-on-dot t)
(add-hook 'python-mode-hook 'jedi-setup-args)
(add-hook 'python-mode-hook 'jedi:setup)
(add-hook 'python-mode-hook 'auto-complete-mode)


(delete-selection-mode 1)

(require 'js2-refactor)

(add-hook 'js2-mode-hook #'js2-refactor-mode)
(js2r-add-keybindings-with-prefix "C-c C-r")
(define-key js2-mode-map (kbd "C-k") #'js2r-kill)

(add-to-list 'auto-mode-alist '("\\.js\\'" . js2-mode))

 (add-to-list 'auto-mode-alist '("\\.css$" . html-mode))
 (add-to-list 'auto-mode-alist '("\\.cfm$" . html-mode))


(defun ruthlessly-kill-line ()
  "Deletes a line, but does not put it in the kill-ring. (kinda)"
  (interactive)
  (move-beginning-of-line 1)
  (kill-line 1)
  (setq kill-ring (cdr kill-ring)))

(global-set-key (kbd "C-k") 'ruthlessly-kill-line)
