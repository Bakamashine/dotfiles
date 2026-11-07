;;; clangd-rc.el --- clangd via Eglot, company for completion -*- lexical-binding: t; -*-

;; clangd is the language server (completion, errors/warnings, signature
;; help, goto-definition, rename).  Eglot is only the client that speaks
;; the Language Server Protocol to it; company-mode is the completion UI.
;;
;; Eglot exposes clangd candidates through `completion-at-point', and
;; company consumes them with its `company-capf' backend.  Diagnostics are
;; displayed by Flymake, which Eglot enables automatically.

(require 'eglot)
(require 'company)

;; clangd is normally on PATH.  Fall back to the standard LLVM install
;; location on Windows, in case Emacs was started before LLVM was added
;; to PATH.
(defun rc/clangd-program ()
  (or (executable-find "clangd")
      (let ((windows-default "C:/Program Files/LLVM/bin/clangd.exe"))
        (and (file-executable-p windows-default) windows-default))
      "clangd"))

;; Modes served by clangd.  `simpc-mode' is the custom mode this config
;; maps .c/.h/.cpp files to.  clangd detects the actual language from the
;; file extension and/or compile_commands.json, so it needs no language
;; id here.
(add-to-list 'eglot-server-programs
             `((c-mode c-ts-mode c++-mode c++-ts-mode objc-mode simpc-mode)
               ,(rc/clangd-program)
               "--background-index"
               "--clang-tidy"
               "--completion-style=detailed"
               "--header-insertion=never"))

;; Company is the autocomplete front-end: `company-capf' pulls clangd
;; candidates from Eglot, `company-dabbrev-code' is a local-words fallback.
;; Eglot sets `company-backends' itself in managed buffers, so set ours on
;; `eglot-managed-mode-hook' to win over that.
(defun rc/clangd-company-setup ()
  "Configure company for a clangd (Eglot) buffer."
  (setq-local company-backends '(company-capf company-dabbrev-code))
  (company-mode 1))

(add-hook 'eglot-managed-mode-hook #'rc/clangd-company-setup)

(defun rc/eglot-clangd-ensure ()
  "Start clangd via Eglot for the current buffer."
  (eglot-ensure))

(dolist (hook '(c-mode-hook
                c-ts-mode-hook
                c++-mode-hook
                c++-ts-mode-hook
                simpc-mode-hook))
  (add-hook hook #'rc/eglot-clangd-ensure))

;; Company behaviour: pop up early, IDE-style.
(setq company-minimum-prefix-length 1
      company-idle-delay 0.2
      company-tooltip-align-annotations t)

;; Diagnostics are shown by Flymake (wave underline, fringe markers and
;; echo area).  Eglot turns Flymake on in every buffer it manages; these
;; just keep checking responsive.
(setq flymake-no-changes-timeout 0.5
      flymake-start-on-save-buffer t)

(provide 'clangd-rc)
;;; clangd-rc.el ends here
