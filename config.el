;; $DOOMDIR/config.el -*- lexical-binding: t; -*-



;;; Error handling

;;(toggle-debug-on-error)
(setq debugger-stack-frame-as-list t)




;;; Personal information

(setq user-full-name "Holger Schurig")
(setq user-mail-address "holgerschurig@gmail.com")
(defvar my-freenode-password nil "Password for the IRC network freenode.net")
(require 'private (expand-file-name "private.el" doom-private-dir) 'noerror)




;;; Commands

(put 'erase-buffer 'disabled nil)
(put 'narrow-to-region 'disabled nil)
(put 'downcase-region 'disabled nil)
(put 'update-region 'disabled nil)
(put 'customize-group 'disabled nil)




;;; Misc

(defun 822date ()
  "Insert date at point format the RFC822 way."
  (interactive)
  (insert (format-time-string "%a, %e %b %Y %H:%M:%S %z")))

(defun dos2unix()
  "Convert MSDOS (^M) end of line to Unix end of line."
  (interactive)
  (goto-char(point-min))
  (while (search-forward "\r" nil t) (replace-match "")))

(defalias 'sudo-edit 'doom/sudo-this-file
   "Edit currently visited file as root.")

(setenv "PATH" "/home/schurig/.local/bin:/usr/local/bin:/usr/bin:/bin:/usr/local/games:/usr/games")


;; https://blog.lambda.cx/posts/emacs-align-columns/
(defun my-align-non-space (BEG END)
  "Align non-space columns in region BEG END."
  (interactive "r")
  (align-regexp BEG END "\\(\\s-*\\)\\S-+" 1 1 t))


;; 1. Download  https://github.com/ryanoasis/nerd-fonts/blob/master/patched-fonts/RobotoMono/Regular/complete/Roboto%20Mono%20Nerd%20Font%20Complete.ttf
;; 2. Put that in ~/.config/share/fonts/

;; (setq doom-font (font-spec :family "RobotoMono Nerd Font Mono" :size 13)
;;       ;; doom-variable-pitch-font (font-spec :family "Fira Sans")
;;       doom-unicode-font (font-spec :family "DejaVu Sans Mono")
;;       doom-big-font (font-spec :family "RobotoMono Nerd Font Mono" :size 19))




;;; Misc keybindings
;; This is like the start of modules/config/default/+emacs-bindings.el:

;; Sensible default key bindings for non-evil users
(setq doom-leader-alt-key "C-c"
      doom-localleader-alt-key "C-c l")

;; Allow scrolling up and down
(global-set-key (kbd "C-S-<up>")   (kbd "C-u 1 M-v"))
(global-set-key (kbd "C-S-<down>") (kbd "C-u 1 C-v"))



;;; Package: core/auth-sources

(after! auth-source
  (setq auth-sources (list (concat doom-etc-dir "authinfo.gpg")
                           "~/.authinfo.gpg"
                           "~/.authinfo")))



;;; Package: core/browse-url

;; see https://www.emacswiki.org/emacs/BrowseUrl#h5o-7
(after! browse-url
  (setq browse-url-browser-function 'browse-url-firefox
        browse-url-new-window-flag  t
        browse-url-firefox-new-window-is-tab t))




;;; Package: core/buffers

(setq-default tab-width 4)

;; Don't asks you if you want to kill a buffer with a live process
;; attached to it:
(remove-hook 'kill-buffer-query-functions 'process-kill-buffer-query-function)


;; Make the messages be displayed full-screen
(add-to-list 'display-buffer-alist
             `(,(rx bos "*Messages*" eos)
               (display-buffer-reuse-window display-buffer-same-window)
               (reusable-frames . visible))
             )


;; revert buffer with one keystroke
(defun revert-buffer-no-confirm ()
  "Revert buffer, no questions asked"
  (interactive)
  (revert-buffer nil t t))
(map! "<f3>" #'revert-buffer-no-confirm)


(defun my-zoom-next-buffer2 ()
  (let ((curbuf (current-buffer))
        (firstbuf nil))
    (dolist (buffer (buffer-list))
      (with-current-buffer buffer
        ;;(princ (format "name %s, fn %s\n" (buffer-name) buffer-file-name))
        (unless (or
                 ;; Don't mention internal buffers.
                 (string= (substring (buffer-name) 0 1) " ")
                 ;; No buffers without files.
                 (not buffer-file-name)
                 ;; Skip the current buffer
                 (eq buffer curbuf)
                 )
          ;;(princ (format " nme %s, fn %s\n" (buffer-name) buffer-file-name))
          (unless firstbuf
            (setq firstbuf buffer))
          ;;(print buffer)
          )))
    (when firstbuf
      ;;(princ (format "new buffer: %s.\n" firstbuf))
      (bury-buffer)
      (switch-to-buffer firstbuf))))
(defun my-explode-window ()
  "If there is only one window displayed, act like C-x2. If there
are two windows displayed, act like C-x1:"
  (interactive)
  (if (one-window-p t)
      (progn
        (split-window-vertically)
        (other-window 1)
        (my-zoom-next-buffer2)
        (other-window -1))
    (delete-other-windows)))

(map! "<f5>" #'my-explode-window)


;; If there is only one window displayed, swap it with previous buffer.
;; If there are two windows displayed, act like "C-x o".
(defun my-switch-to-buffer ()
  "If there is only one window displayed, swap it with previous buffer.
If there are two windows displayed, act like \"C-x o\"."
  (interactive)
  (if (one-window-p t)
      (switch-to-buffer (other-buffer (current-buffer) 1))
    (other-window -1)))

(map! "<f6>" #'my-switch-to-buffer)




;;; Package: core/calc
(after! calc
  (setq calc-angle-mode 'rad  ; radians are radians, 0..2*pi
        calc-symbolic-mode t))



;;; Package: core/cus-edit

(after! cus-edit
  ;; keep lisp names in the custom buffers, don't capitalize.
  (setq custom-unlispify-tag-names nil)
  ;; kill old buffers.
  (setq custom-buffer-done-kill t))




;;; Package: core/files

(after! files
  (setq confirm-kill-emacs nil)

  ;; Preserve hard links to the file you´re editing (this is
  ;; especially important if you edit system files)
  (setq backup-by-copying-when-linked t)

  ;; Just never create backup files at all
  ;; (make-backup-files nil)

  ;; Alternatively put backup files into their own directory
  (setq backup-directory-alist (list (cons "." (locate-user-emacs-file "tmp/bak/"))))

  ;; Make files with shebang executable
  (add-hook 'after-save-hook #'executable-make-buffer-file-executable-if-script-p))

(map! "<f2>" #'save-buffer)




;;; Package: core/ibuffer

(after! ibuffer

  ;; see `ibuffer-filtering-alist` for what is possible beside "name" and "mode"
  (setq ibuffer-saved-filter-groups
        `(("default"
           ("Programming"  (or
                            (derived-mode . prog-mode)
                            (filename . ,(concat "^" (getenv "HOME") "/d/"))
                            ))
           ("Dired" (mode . dired-mode))
           ("Mail"  (or
                     (mode . mu4e-view-mode)
                     (mode . mu4e-compose-mode)
                     (mode . mu4e-headers-mode)))
           ("IRC"   (or
                     (mode . erc-mode)
                     (mode . circe-server-mode)
                     (mode . circe-query-mode)
                     (mode . circe-channel-mode)
                     ))
           ("Feeds" (or
                     (mode . elfeed-show-mode)
                     (mode . elfeed-search-mode)
                     (name . "elfeed.org$")
                     (name . "^\\*elfeed.log\\*$")
                     ))
           ("Documentation" (or
                     (name . "^\\*info")
                     (name . "^\\*help")
                     ))
           ("Emacs" (or
                     (name . "^\\*")
                     ))
                   )))

  ;; no empty sections
  (setq ibuffer-show-empty-filter-groups nil)

  ;; less annoying questions
  (setq ibuffer-expert t)

  :preface
  (defun my-ibuffer-setup ()
    (ibuffer-switch-to-saved-filter-groups "default")
    (ibuffer-auto-mode 1))

  (add-hook 'ibuffer-mode-hook #'my-ibuffer-setup)

  (map! "C-x b" #'ibuffer)
)



;;; Package: core/isearch

(after! isearch
  ;; Scrolling (including C-s) while searching:
  (setq isearch-allow-scroll t)

  ;; Do less flickering be removing highlighting immediately
  (setq lazy-highlight-initial-delay 0))




;;; Package: core/recentf

(after! recentf
  (dolist (i `(".*-autoloads\\.el\\'"
               ".*CMakeFiles.*"
               ".pdf$"
               "COMMIT_EDITMSG"
               "COMMIT_EDITMSG"
               "TAG_EDITMSG"
               "\\.html$"
               "\\.org_archive$"
               "\\.png$"
               "^/tmp/"
               "svn-commit\\.tmp$"))
    (add-to-list 'recentf-exclude i))
  (setq recentf-max-saved-items 1000
        recentf-auto-cleanup 300
        recentf-max-menu-items 20))



;;; Package: core/register
(after! register
  (setq register-preview-delay 1)
  (setq register-preview-function #'consult-register-format))



;;; Package: core/message

(after! message
  (setq message-send-mail-function #'message-send-mail-with-sendmail
        message-citation-line-format "On %b, %Y-%m-%d %H:%S, %N wrote ..."
        message-citation-line-function 'message-insert-formatted-citation-line))



;;; Package: core/misc

(map! "C-z" #'zap-up-to-char)



;;; Package: core/minibuf

(setq history-delete-duplicates t)

(setq resize-mini-windows t)

;; don't show "*Completions*" buffer
(setq completion-auto-help nil)

;; Have you ever tried to quit the minibuffer when point was in another window?
;; Naturally you would try hammering C-g but in stock Emacs the minibuffer stays
;; active and all you get are grumpy "Quit" messages.
(defun my-keyboard-quit ()
  "Quit current context.

This function is a combination of `keyboard-quit' and
`keyboard-escape-quit' with some parts omitted and some custom
behavior added."
  ;; See: https://with-emacs.com/posts/tips/quit-current-context/
  (interactive)
  (cond ((region-active-p)
         ;; Avoid adding the region to the window selection.
         (setq saved-region-selection nil)
         (let (select-active-regions)
           (deactivate-mark)))
        ((eq last-command 'mode-exited) nil)
        (current-prefix-arg
         nil)
        (defining-kbd-macro
          (message
           (substitute-command-keys
            "Quit is ignored during macro defintion, use \\[kmacro-end-macro] if you want to stop macro definition"))
          (cancel-kbd-macro-events))
        ((active-minibuffer-window)
         (when (get-buffer-window "*Completions*")
           ;; hide completions first so point stays in active window when
           ;; outside the minibuffer
           (minibuffer-hide-completions))
         (abort-recursive-edit))
        (t
         ;; if we got this far just use the default so we don't miss
         ;; any upstream changes
         (keyboard-quit))))
(global-set-key [remap keyboard-quit] #'my-keyboard-quit)




;;; Package: core/mule-util

(after! mule-util
  (setq truncate-string-ellipsis "…"))



;;; Package: core/sendmail

(after! sendmail
  (setq sendmail-program "msmtp"
        send-mail-function #'smtpmail-send-it))



;;; Package: core/shr

(after! shr
  (setq shr-color-visible-luminance-min 80
        shr-bullet "• "
        shr-folding-mode t))


;;; Package: core/simple

(after! simple
  ;; The following may be of interest to people who (a) are happy with
  ;; "C-w" and friends for killing and yanking, (b) use
  ;; "transient-mark-mode", (c) also like the traditional Unix tty
  ;; behaviour that "C-w" deletes a word backwards. It tweaks "C-w" so
  ;; that, if the mark is inactive, it deletes a word backwards instead
  ;; of killing the region. Without that tweak, the C-w would create an
  ;; error text without an active region.
  ;; http://www.emacswiki.org/emacs/DefaultKillingAndYanking#toc2

  (defadvice kill-region (before unix-werase activate compile)
    "When called interactively with no active region, delete a single word
  backwards instead."
    (interactive
     (if mark-active (list (region-beginning) (region-end))
       (list (save-excursion (backward-word 1) (point)) (point)))))


  ;; React faster to keystrokes
  (setq idle-update-delay 0.35)

  ;; Be silent when killing text from read only buffer:
  (setq kill-read-only-ok t)

  ;; Read quoted chars with radix 16 --- octal is sooooo 1960
  (setq read-quoted-char-radix 16)

  ;; Deleting past a tab normally changes tab into spaces. Don't do
  ;; that, kill the tab instead.
  (setq backward-delete-char-untabify-method nil)

  (setq kill-ring-max 500)

  ;; Don't type C-u C-SPC C-u C-SPC to pop 2 marks, now you can do C-u C-SPC C-SPC
  (setq set-mark-command-repeat-pop t))

(map! "C-x I" #'insert-buffer

      "M-SPC" #'cycle-spacing   ;; was: just-one-space

      "M-c" #'capitalize-dwim
      "M-l" #'downcase-dwim
      "M-u" #'upcase-dwim

      "M-o" #'delete-blank-lines  ; opposite of C-o

      ;; Error navigation
      "<f8>"   #'next-error
      "S-<f8>"  #'previous-error)




;;; Package: core/vc

(after! vc-hooks
  ;; Remove most back-ends from vc-mode
  (setq vc-handled-backends '(Git))
  ;; Disable version control when using tramp
  (setq vc-ignore-dir-regexp
      (format "\\(%s\\)\\|\\(%s\\)"
              vc-ignore-dir-regexp
              tramp-file-name-regexp)))



;;; Package: core/url-vars

(after! url-vars
  (setq url-privacy-level '(email agent cookies lastloc)))



;;; Package: core/window

(map! "C-x k" #'kill-buffer-and-window)


;;; Package: core/xref

(use-package! xref
  :custom
  (xref-file-name-display 'project-relative) ;; was abs
  (xref-search-program 'ripgrep)             ;; was grep

  :config
  (advice-remove #'xref-push-marker-stack #'doom-set-jump-a)
)



;;; Package: gui/display-line-numbers

;; This removes the display of the line numbers

(remove-hook! '(prog-mode-hook text-mode-hook conf-mode-hook)
  #'display-line-numbers-mode)




;;; Package: gui/minibuffer

(after! minibuffer
  (setq history-length 1000)

  (minibuffer-depth-indicate-mode 1)

  ;; Allow to type space chars in minibuffer input (for `timeclock-in',
  ;; for example).
  (define-key minibuffer-local-completion-map " " nil)
  (define-key minibuffer-local-must-match-map " " nil)

  ;; Don't insert current directory into minubuffer
  (setq insert-default-directory nil))




;;; Package: gui/nswbuff

(after! nswbuff
  (setq nswbuff-display-intermediate-buffers t
        nswbuff-exclude-buffer-regexps '("^ .*" "^\\*.*\\*")))

(map! "S-<f5>" #'nswbuff-switch-to-previous-buffer
      "S-<f6>" #'nswbuff-switch-to-next-buffer)




;;; Package: gui/whitespace

;; (after! whitespace
;;   (setq whitespace-global-modes nil))
;; ;; unfortunately, removing doom-highlight-non-default-indentation-h from
;; ;; change-major-mode-hook didn't work, it was somehow added again so I define a
;; ;; dummy function to override doom's weird behavior of turning white-space
;; ;; mode on at unwanted times.
;; (defun doom-highlight-non-default-indentation-h ()
;;   "Dummy")

;; (map! "C-c w" #'whitespace-mode)





;;; Package: gui/hl-todo
(after! hl-todo
  (setq hl-todo-keyword-faces
        '(("TODO" warning bold)                      ;; was "#cc9393"
          ("FIXME" error bold)                       ;; was "#cc9393")
          ("HACK" font-lock-constant-face bold)      ;; was "#d0bf8f"
          ("REVIEW" font-lock-keyword-face bold)
          ("NOTE" success bold)                      ;; was "#d0bf8f"
          ("DEPRECATED" font-lock-doc-face bold)
          ("BUG" error bold)
          ("XXX" font-lock-constant-face bold)       ;; was "#cc9393"
          ;; some more original values
          ("HOLD" . "#d0bf8f")
          ("OKAY" . "#7cb8bb")
          ("DONT" . "#5f7f5f")
          ("FAIL" . "#8c5353")
          ("DONE" . "#afd8af")
          ("KLUDGE" . "#d0bf8f")
          ("TEMP" . "#d0bf8f")
          ;; some of my own
          ("WAIT" . "#d0bf8f")
          ("XXX+" . "#dc752f"))))



;;; Package: theme/font-core

;; I got the idea from here:
;; http://amitp.blogspot.de/2013/05/emacs-highlight-active-buffer.html

(defun highlight-focus:app-focus-in ()
  (global-font-lock-mode 1))

(defun highlight-focus:app-focus-out ()
  (global-font-lock-mode -1))

(add-hook 'focus-in-hook  #'highlight-focus:app-focus-in)
(add-hook 'focus-out-hook #'highlight-focus:app-focus-out)




;;; Package: theme/font-lock

(after! font-lock
  (setq font-lock-maximum-decoration 2))  ;; was t



;;; Package: theme/modus-themes
;; https://protesilaos.com/codelog/2019-08-07-emacs-modus-themes/
;; https://gitlab.com/protesilaos/modus-themes
;; https://github.com/protesilaos/modus-themes/blob/main/doc/modus-themes.org


(setq doom-theme 'modus-vivendi)

(use-package! modus-vivendi-theme
  :custom
  (modus-themes-slanted-constructs t)
  (modus-themes-bold-constructs t)
  (modus-themes-completions 'opinionated)

  :config
  ;; Make the marked region be much easier visible
  (set-face-attribute 'region nil :background "#6c6c6c")
)



;;; Package: edit/autorevert

(after! autorevert
  (setq global-auto-revert-non-file-buffers t
        auto-revert-interval 1
        auto-revert-verbose nil))



;;; Package: edit/clean-aindent-mode

;; Nice tip from tuhdo, see https://www.emacswiki.org/emacs/CleanAutoIndent
(add-hook 'prog-mode-hook #'clean-aindent-mode)




;;; Package: edit/expand-region

(after! expand-region
  (setq expand-region-reset-fast-key    "<ESC><ESC>"))

(map! "C-+" #'er/expand-region)



;;; Package: edit/kurecolor
;; https://github.com/emacsfodder/kurecolor
;;
;; This package allows interactive modification of color values.

(defhydra hydra-kurecolor (:color pink :hint  nil)
  "
Dec/Inc      _j_/_J_ brightness      _k_/_K_ saturation      _l_/_L_ hue
Set          _sj_ ^^ brightness      _sk_ ^^ saturation      _sl_ ^^ hue
Get          _gj_ ^^ brightness      _gk_ ^^ saturation      _gl_ ^^ hue

Convert      _ch_ ^^ RGB → Hex       _cr_ ^^ Hex → RGB       _cR_ ^^ Hex → RGBA
"
  ("j"  kurecolor-decrease-brightness-by-step)
  ("J"  kurecolor-increase-brightness-by-step)
  ("k"  kurecolor-decrease-saturation-by-step)
  ("K"  kurecolor-increase-saturation-by-step)
  ("l"  kurecolor-decrease-hue-by-step)
  ("L"  kurecolor-increase-hue-by-step)
  ("sj" kurecolor-set-brightness :color blue)
  ("sk" kurecolor-set-saturation :color blue)
  ("sl" kurecolor-set-hue :color blue)
  ("gj" kurecolor-hex-val-group :color blue)
  ("gk" kurecolor-hex-sat-group :color blue)
  ("gl" kurecolor-hex-hue-group :color blue)
  ("ch" kurecolor-cssrgb-at-point-or-region-to-hex :color blue)
  ("cr" kurecolor-hexcolor-at-point-or-region-to-css-rgb :color blue)
  ("cR" kurecolor-hexcolor-at-point-or-region-to-css-rgba :color blue)
  ("q"  nil "cancel" :color blue))

(defun kurecolor ()
  "Turns on rainbow mode and lets you modify the current color code. The
cursor must be sitting over a CSS-like color string, e.g. \"#ff008c\"."
  (interactive)
  (rainbow-mode t)
  (hydra-kurecolor/body))




;;; Package: edit/indent

;; This variable is used in indent-for-tab-command and calls and calls out to
;; completion-at-point
(setq tab-always-indent 'complete
      completion-cycle-threshold 3
      tab-first-completion 'eol)




;;; Package: edit/newcomment

(map! "C-c c" #'comment-dwim)



;;; Package: edit/smartparens

;; I hate this package, so I don't want it. But I must define some fake functions
;; in order to mitigate errors.
(cl-defun sp-local-pair (modes
                         open
                         close
                         &key
                         trigger
                         trigger-wrap
                         (actions '(:add))
                         (when '(:add))
                         (unless '(:add))
                         (pre-handlers '(:add))
                         (post-handlers '(:add))
                         wrap
                         bind
                         insert
                         prefix
                         suffix
                         skip-match)
  "Dummy")
(defun turn-off-smartparens-mode ()
  "Dummy")
(defun sp-point-in-comment (&optional pos)
  "Dummy"
  nil)
(defun sp-point-in-string (&optional pos)
  "Dummy"
  nil)




;;; Package: edit/symbol-overlay - jump / manipulate to symbols
;; https://github.com/wolray/symbol-overlay

(map! "M-p"      #'symbol-overlay-jump-prev
      "M-n"      #'symbol-overlay-jump-next
      "M-<up>"   #'symbol-overlay-jump-prev
      "M-<down>" #'symbol-overlay-jump-next
      )





;;; Package: edit/tabify
(after! tabify
  ;; only tabify initial whitespace
  (setq tabify-regexp "^\t* [ \t]+"))





;;; Package: edit/undo-tree

(after! undo-tree
  ;; Disable undo-in-region. It sounds like an interesting feature,
  ;; but unfortunately the implementation is very buggy and regularly
  ;; causes you to lose your undo history.
  (setq undo-tree-enable-undo-in-region nil)

  ;; don't save history persistently
  (setq undo-tree-auto-save-history nil)

  (setq undo-tree-visualizer-timestamps t)
  (map! "C-z" #'undo-tree-visualize)
)





;;; Package: edit/wgrep

(use-package wgrep
  ;; :after (embark-consult ripgrep)
  :defer t

  :general
  (keymaps '(wgrep-mode-map)
           "C-c C-c" #'save-buffer)
  (keymaps '(grep-mode-map)
           "e" #'wgrep-change-to-wgrep-mode)
)



;;; Package: misc/embark

;; The following keymaps are already existing, so you can just add actions to
;; them. Then position the cursor somewhere and do "C-,". To see then which
;; actions are available, run "C-h".
;;
;; embark-meta-map
;; embark-symbol-map
;; embark-collect-direct-action-minor-mode-map
;; embark-become-shell-command-map
;; embark-command-map
;; embark-collect-mode-map
;; embark-buffer-map
;; embark-file-map
;; embark-become-file+buffer-map
;; embark-variable-map
;; embark-occur-direct-action-minor-mode-map
;; embark-package-map
;; embark-unicode-name-map
;; embark-general-map
;; embark-overriding-map
;; embark-bookmark-map
;; embark-become-help-map
;; embark-become-match-map
;; embark-url-map
;; embark-consult-location-map

;; https://github.com/oantolin/embark
;; https://github.com/oantolin/embark/wiki/Default-Actions
;;
;; E.g. go to a lisp symbol and hit "C-, h" to get help on symbol
;;      go to an URL        and hit "C-, e" to open the URL in eww (or "C-, b" to browse it normally)
;; generally hit "C-, C-h" to get help on available actions, which sometimes display more entries than which-keys

(use-package! embark-consult
  :after (embark consult)
  :load-path "~/.emacs.d/.local/straight/repos/embark"
  :demand t
  :hook (embark-collect-mode-hook . embark-consult-preview-minor-mode)
)


(use-package! embark
  :commands embark-act

  :custom
  (embark-collect-initial-view-alist '((file . list)   ;; was grid
                                       (buffer . list) ;; was grid
                                       (symbol . list)
                                       (line . list)   ;; new entry
                                       (consult-location . list)
                                       (xref-location . list)
                                       (kill-ring . zebra)
                                       (t . list)))

  :config
  (setq prefix-help-command #'embark-prefix-help-command)

  ;; which key is nicer than embark's build in prompt
  (add-to-list 'display-buffer-alist
               '("\\`\\*Embark Collect \\(Live\\|Completions\\)\\*"
                 nil
                 (window-parameters (mode-line-format . none))))

  (setq embark-action-indicator
      (lambda (map &optional _target)
        (which-key--show-keymap "Embark" map nil nil 'no-paging)
        #'which-key--hide-popup-ignore-command)
      embark-become-indicator embark-action-indicator)

  :general
  ("C-," #'embark-act)
  (:keymaps '(minibuffer-local-map minibuffer-local-completion-map)
   "C-," #'embark-act)
  (:keymaps '(embark-collect-mode-map)
   "M-t" #'toggle-truncate-lines)
  (:keymaps '(embark-symbol-map)
   "."   #'embark-find-definition)
  (:keymaps '(embark-file-map)
   "j"    #'dired-jump)
)


(use-package! embark-consult
  :after (embark consult)
  :demand t                ; only necessary if you have the hook below
  ;; if you want to have consult previews as you move around an
  ;; auto-updating embark collect buffer
  :hook (embark-collect-mode . embark-consult-preview-minor-mode)
)



;;; Package: modes/dts-mode

(use-package! dts-mode
  :mode (("\\.dts\\'"     . dts-mode)
         ("\\.overlay\\'" . dts-mode))
)



;;; Package: modes/diff-mode

;; The following let the commits from "git diff >foo.diff" stand out more:
(after! diff-mode
  (defun my-diff-mode-setup ()
    (hi-lock-line-face-buffer "^commit"))
  (add-hook 'diff-mode-hook #'my-diff-mode-setup))




;;; Package: modes/dired

(after! dired
  (setq dired-listing-switches "-laGh1v --group-directories-first")
  ;; revert when revisiting
  (setq dired-auto-revert-buffer t)
  ;; work in a Norton Commander like mode if 2 panes are open
  (setq dired-dwim-target t))

(after! dired-aux
  ;; If dwim, Isearch matches file names when initial point position
  ;; is on a file name. Otherwise, it searches the whole buffer
  ;; without restrictions.
  (setq dired-isearch-filenames 'dwim))

(map! "C-x C-d" #'dired-jump  ;; "C-x d" is dired
      :map dired-mode-map
      "q" #'dired-up-directory)





;;; Package: modes/ediff

(after! ediff
  :config
  (setq ediff-split-window-function 'split-window-vertically)

  (add-hook 'ediff-after-quit-hook-internal #'winner-undo))




;;; Package: modes/helpful

(after! helpful
  (add-to-list 'display-buffer-alist
               `(,(rx bos "*helpful" )
                 (display-buffer-reuse-window display-buffer-same-window)
                 (reusable-frames . visible))
               )
  (add-hook 'helpful-mode-hook #'visual-line-mode))

(map! "<f1> h" #'helpful-at-point
      :map helpful-mode-map
      "q" #'kill-buffer-and-window)




;;; Package: modes/js-mode

(use-package! js-mode
  :mode "\\.ns\\'"  ;; bitburner .ns files
)



;;; Package: modes/nov

;; https://depp.brause.cc/nov.el/
(use-package! nov
  :defer t
  :mode (("\\epub\\'" . nov-mode))
  :hook
  (nov-mode-hook . visual-line-mode)
)

;;; Package: modes/pdf-tools

(after! pdf-tools
  (add-hook 'pdf-view-mode-hook #'pdf-view-auto-slice-minor-mode)
  (add-hook 'pdf-view-mode-hook #'pdf-view-midnight-minor-mode)
  (defhydra hydra-pdftools (:color blue :hint nil)
    "
                                                                      ╭───────────┐
       Move  History   Scale/Fit     Annotations  Search/Link    Do   │ PDF Tools │
   ╭──────────────────────────────────────────────────────────────────┴───────────╯
         ^^_g_^^      _B_    ^↧^    _+_    ^ ^     [_al_] list    [_s_] search    [_u_] revert buffer
         ^^^↑^^^      ^↑^    _H_    ^↑^   ↦ _W_ ↤  [_am_] markup  [_o_] outline   [_i_] info
         ^^_p_^^      ^ ^    ^↥^    _0_    ^ ^     [_at_] text    [_F_] link      [_d_] dark mode
         ^^^↑^^^      ^↓^  ╭─^─^─┐  ^↓^  ╭─^ ^─┐   [_ad_] delete  [_f_] search link
    _h_ ←pag_e_→ _l_  _N_  │ _P_ │  _-_    _b_     [_aa_] dired
         ^^^↓^^^      ^ ^  ╰─^─^─╯  ^ ^  ╰─^ ^─╯   [_y_]  yank
         ^^_n_^^      ^ ^  _r_eset slice box
         ^^^↓^^^
         ^^_G_^^
   --------------------------------------------------------------------------------
        "
    ("\\" hydra-master/body "back")
    ("<ESC>" nil "quit")
    ("al" pdf-annot-list-annotations)
    ("ad" pdf-annot-delete)
    ("aa" pdf-annot-attachment-dired)
    ("am" pdf-annot-add-markup-annotation)
    ("at" pdf-annot-add-text-annotation)
    ("y"  pdf-view-kill-ring-save)
    ("+" pdf-view-enlarge :color red)
    ("-" pdf-view-shrink :color red)
    ("0" pdf-view-scale-reset)
    ("H" pdf-view-fit-height-to-window)
    ("W" pdf-view-fit-width-to-window)
    ("P" pdf-view-fit-page-to-window)
    ("n" pdf-view-next-page-command :color red)
    ("p" pdf-view-previous-page-command :color red)
    ("d" pdf-view-dark-minor-mode)
    ("b" pdf-view-set-slice-from-bounding-box)
    ("r" pdf-view-reset-slice)
    ("g" pdf-view-first-page)
    ("G" pdf-view-last-page)
    ("e" pdf-view-goto-page)
    ("o" pdf-outline)
    ("s" pdf-occur)
    ("i" pdf-misc-display-metadata)
    ("u" pdf-view-revert-buffer)
    ("F" pdf-links-action-perform)
    ("f" pdf-links-isearch-link)
    ("B" pdf-history-backward :color red)
    ("N" pdf-history-forward :color red)
    ("l" image-forward-hscroll :color red)
    ("h" image-backward-hscroll :color red))

  (map! :map pdf-view-mode-map
        "?"  #'hydra-pdftools/body
        "g"  #'pdf-view-first-page
        "G"  #'pdf-view-last-page
        "l"  #'image-forward-hscroll
        "h"  #'image-backward-hscroll
        "j"  #'pdf-view-next-page
        "k"  #'pdf-view-previous-page
        "e"  #'pdf-view-goto-page
        "u"  #'pdf-view-revert-buffer
        "al" #'pdf-annot-list-annotations
        "ad" #'pdf-annot-delete
        "aa" #'pdf-annot-attachment-dired
        "am" #'pdf-annot-add-markup-annotation
        "at" #'pdf-annot-add-text-annotation
        "y"  #'pdf-view-kill-ring-save
        "i"  #'pdf-misc-display-metadata
        "s"  #'pdf-occur
        "b"  #'pdf-view-set-slice-from-bounding-box
        "r"  #'pdf-view-reset-slice))




;;; Package: completion/selectrum

;; https://github.com/raxod502/selectrum
(use-package! selectrum
  :init
  (selectrum-mode +1)

  :general
  ("C-x C-z"  #'selectrum-repeat) ;; was suspend-frame
  ("C-c C-r"  #'selectrum-repeat)

  :custom
  (selectrum-fix-vertical-window-height 15)
)


;;; Package: completion/selectrum-prescient
(use-package! selectrum-prescient
  :after (selectrum prescient)
  :init
  (selectrum-prescient-mode +1)
)

;;; Package: completion/prescient
;; https://github.com/raxod502/prescient.el
;; Alternative: https://github.com/oantolin/orderless
(use-package! prescient
  :custom
  (prescient-save-file (concat doom-cache-dir "prescient-save.el"))

  :config
  (prescient-persist-mode +1)
)

;;; Package: completion/marginalia
;; https://github.com/minad/marginalia
(use-package! marginalia
  :custom
  (marginalia-annotators '(marginalia-annotators-heavy marginalia-annotators-light nil))

  :init
  (marginalia-mode)

  :general
  (:keymaps '(minibuffer-local-map)
   "M-c" #'marginalia-cycle)
)


;;; Package: completion/consult

(use-package! consult-selectrum
  :after (selectrum consult)
  :load-path "~/.emacs.d/.local/straight/repos/consult"
  :demand t
)

;; https://github.com/minad/consult
(use-package! consult
  :custom
  (completion-in-region-function #'consult-completion-in-region) ;; was selectrum-completion-in-region
  (consult-async-input-debounce 0.5)                             ;; was 0.25
  (consult-async-input-throttle 0.8)                             ;; was 0.5
  (consult-narrow-key ">")                                       ;; was empty
  (consult-widen-key "<")                                        ;; was empty
  (consult-config `(;; changing the theme while moving the cursor is annoying, so turn this off
                    (consult-theme :preview-key nil)
                    ;; the same in the file/buffer selection
                    (consult-buffer :preview-key nil)
                    ;; ... and in the swiper substitute
                    (consult-line :preview-key nil)))
  (consult-goto-line-numbers nil)
  (consult-preview-key nil)

  :init
  ;; Optionally tweak the register preview window.
  ;; This adds zebra stripes, sorting and hides the mode line of the window.
  (advice-add #'register-preview :override #'consult-register-window)

  (defun my-project-root ()
    (locate-dominating-file "." ".git"))
  (setq consult-project-root-function #'my-project-root)

  :config

  ;; this forces recentf to load directly, not delayed. So a C-x C-b directly after starting emacs
  ;; will show previously used files
  (recentf-mode +1)

  :general

  ;; C-c bindings (mode-specific-map)
  ("C-c m"    #'consult-mode-command)
  ("C-c b"    #'consult-bookmark)
  ("C-c k"    #'consult-kmacro)

  ;; C-x bindings (ctl-x-map)
  ("C-x M-:"  #'consult-complex-command)      ;; was: repeat-complex-command
  ("C-x C-b"  #'consult-buffer)               ;; was: switch-to-buffer
  ("C-x 4 b"  #'consult-buffer-other-window)  ;; was: switch-to-buffer-other-window
  ("C-x 5 b"  #'consult-buffer-other-frame)   ;; was: switch-to-buffer-other-frame

  ;; Custom M-# bindings for fast register access
  ("M-#"      #'consult-register-load)
  ("M-'"      #'consult-register-store)       ;; was: abbrev-prefix-mark
  ("C-M-#"    #'consult-register)

  ;; Other custom bindings
  ("M-y"      #'consult-yank-pop)             ;; was: yank-pop
  ("<help> a" #'consult-apropos)              ;; was: apropos-command

  ;; M-g bindings (goto-map)
  ("M-g g"    #'consult-goto-line)            ;; was: goto-line
  ("M-g M-g"  #'consult-goto-line)            ;; was: goto-line
  ("M-g o"    #'consult-outline)
  ("M-g k"    #'consult-mark)
  ("M-g K"    #'consult-global-mark)
  ("M-g i"    #'consult-imenu)
  ("M-g I"    #'consult-project-imenu)
  ("M-g e"    #'consult-error)
  ("M-g l"    #'consult-line)                  ;; similar to swiper

  ;; M-s bindings (search-map)
  ("M-s f"    #'consult-find)
  ("M-g L"    #'consult-locate)
  ("M-s g"    #'consult-git-grep)
  ("M-s G"    #'consult-grep)
  ("M-s r"    #'consult-ripgrep)
  ("M-s l"    #'consult-line)
  ("M-s m"    #'consult-multi-occur)
  ("M-s k"    #'consult-keep-lines)
  ("M-s u"    #'consult-focus-lines)           ;; run with C-u to show all lines again

  ("M-s o"    #'consult-line)                  ;; was: occur

  (:keymaps '(compilation-mode-map compilation-minor-mode-map)
   "e" #'consult-compile-error)
)


;;; Package: lang/c-mode

(after! cc-mode
  (defun my-c-mode-setup ()
    ;;(eglot-ensure)

    ;; need to check the mode because I run this also at the revert hook!
    (modify-syntax-entry ?_ "w")
    (setq c-recognize-knr-p nil)

    ;; might later be changed by dtrt-indent, but this is the default for new files
    (setq indent-tabs-mode t)

    ;; use "// " for commenting in both C and C++
    (setq comment-start "// "
          comment-end "")

    (c-add-style "qt-gnu"
                 '("gnu" (c-access-key .
                        "\\<\\(signals\\|public\\|protected\\|private\\|public slots\\|protected slots\\|private slots\\):")))

    (if (and buffer-file-name (string-match "/linux" buffer-file-name))
       ;; only for Linux C files
       (progn (c-set-style "linux-tabs-only")
            (setq tab-width 8
              c-basic-offset 8))
      (c-set-style "qt-gnu")
      (setq tab-width 4
            c-basic-offset 4)
    ))
  (add-hook 'c-mode-hook #'my-c-mode-setup)
  (add-hook 'c++-mode-hook #'my-c-mode-setup)
  (setq-default c-electric-flag nil)
  )




;;; Package: lang/compile

(after! compile
  (setq compilation-scroll-output t)

  (defun my-colorize-compilation-buffer ()
    (let ((inhibit-read-only t))
      (ansi-color-apply-on-region (point-min) (point-max))))
  (add-hook 'compilation-filter-hook #'my-colorize-compilation-buffer)

  (defun my-compile-autoclose (buffer string)
    "Auto close compile log if there are no errors"
    (when (string-match "finished" string)
      (delete-window (get-buffer-window buffer t))
      (bury-buffer-internal buffer)))
  (add-to-list 'compilation-finish-functions #'my-compile-autoclose)

  ;; the next-error function weirdly stops at "In file included from
  ;; config.cpp:14:0:". Stop that:
  ;; http://stackoverflow.com/questions/15489319/how-can-i-skip-in-file-included-from-in-emacs-c-compilation-mode
  ;; (setcar (nthcdr 5 (assoc 'gcc-include compilation-error-regexp-alist-alist)) 0)
  )




;;; Package: lang/elisp

(after! lisp-mode
  (defun my-emacs-lisp-mode-setup ()
    (interactive)
    "My emacs lisp mode setup function."
    ;; "-" is almost always part of a function- or variable-name
    (modify-syntax-entry ?- "w")

    ;; The following changes the imenu "M-g i" to care most about my ";;;" comments
    (setq lisp-imenu-generic-expression '())
    (setq imenu-generic-expression
          (list
           (list (purecopy "Type")
                 (purecopy (concat "^\\s-*("
                                   (eval-when-compile
                                     (regexp-opt
                                      '(;; Elisp
                                        "defgroup" "deftheme"
                                        "define-widget" "define-error"
                                        "defface" "cl-deftype" "cl-defstruct"
                                        ;; CL
                                        "deftype" "defstruct"
                                        "define-condition" "defpackage"
                                        ;; CLOS and EIEIO
                                        "defclass")
                                      t))
                                   "\\s-+'?\\(" lisp-mode-symbol-regexp "\\)"))
                 2)
           (list (purecopy "Variable")
                 (purecopy (concat "^\\s-*("
                                   (eval-when-compile
                                     (regexp-opt
                                      '(;; Elisp
                                        "defconst" "defcustom"
                                        ;; CL
                                        "defconstant"
                                        "defparameter" "define-symbol-macro")
                                      t))
                                   "\\s-+\\(" lisp-mode-symbol-regexp "\\)"))
                 2)
           ;; For `defvar'/`defvar-local', we ignore (defvar FOO) constructs.
           (list (purecopy "Variable")
                 (purecopy (concat "^\\s-*(defvar\\(?:-local\\)?\\s-+\\("
                                   lisp-mode-symbol-regexp "\\)"
                                   "[[:space:]\n]+[^)]"))
                 1)
           (list "Function"
                 (purecopy (concat "^\\s-*("
                                   (eval-when-compile
                                     (regexp-opt
                                      '("defun" "defmacro"
                                        ;; Elisp.
                                        "defun*" "defsubst" "define-inline"
                                        "define-advice" "defadvice" "define-skeleton"
                                        "define-compilation-mode" "define-minor-mode"
                                        "define-global-minor-mode"
                                        "define-globalized-minor-mode"
                                        "define-derived-mode" "define-generic-mode"
                                        "ert-deftest"
                                        "cl-defun" "cl-defsubst" "cl-defmacro"
                                        "cl-define-compiler-macro" "cl-defgeneric"
                                        "cl-defmethod"
                                        ;; CL.
                                        "define-compiler-macro" "define-modify-macro"
                                        "defsetf" "define-setf-expander"
                                        "define-method-combination"
                                        ;; CLOS and EIEIO
                                        "defgeneric" "defmethod")
                                      t))
                                   "\\s-+\\(" lisp-mode-symbol-regexp "\\)"))
                 2)
           (list "require"
                 (concat "^\\s-*(require\\s-+'\\(" lisp-mode-symbol-regexp "\\)")
                 1)
           (list "use-package"
                 (concat "^\\s-*(use-package\\s-+\\(" lisp-mode-symbol-regexp "\\)")
                 1)
           (list "Section"
                 "^;;[;]\\{1,8\\} \\(.*$\\)"
                 1))))
  (add-hook 'emacs-lisp-mode-hook #'my-emacs-lisp-mode-setup))




;;; Package: lang/prog-mode

;; Show trailing whitespace when programming

(defun my-show-trailing-whitespace ()
  "Show trailing whitespace."
  (interactive)
  (setq show-trailing-whitespace t))

(defun my-hide-trailing-whitespace ()
  "Hide trailing whitespace."
  (interactive)
  (setq show-trailing-whitespace nil))

(after! prog-mode
  (add-hook 'prog-mode-hook #'my-show-trailing-whitespace)
  (add-hook 'prog-mode-hook #'goto-address-mode))




;;; Package: lang/eglot

(after! eglot
  (add-to-list 'eglot-server-programs `((c++-mode c-mode)
                                        ,(if (string= (system-name) "desktop") "/usr/bin/clangd-11" "/usr/bin/clangd-11")
                                        "--background-index"
                                        "--suggest-missing-includes"
                                        "-j=1"
                                        "--compile-commands-dir=build"))
  (map! :map eglot-mode-map
        "C-c r" #'eglot-rename
        "C-c a" #'eglot-code-actions
        "C-c o" #'eglot-code-action-organize-imports
        "C-c h" #'eldoc
        "C-c d" #'xref-find-definitions) ;; Also M-.
)



;;; Package: lang/completion-compile

(use-package! my-compile
  :load-path doom-private-dir
  :defer t

  :general
  ("S-<f7>" #'my-compile-select-command-and-run)
  ("<f7>"   #'my-compile)
)




;;; Package: lang/magit

(after! magit
  ;; Open magit window full-screen
  (setq magit-display-buffer-function #'magit-display-buffer-fullframe-status-v1)
  ;; When calling magit-status, save all buffers without further ado
  (setq magit-save-repository-buffers 'dontask)

  ;; make [MASTER] appear at the end of the summary line
  (setq magit-log-show-refname-after-summary t)

  ;; Switch repositories with magit-list-repositories
  (setq magit-repository-directories
        '(
          ("~/d"      . 1)
          ("~/src"    . 1)
          )))

(after! git-commit
  ;; Anything longer will be highlighted
  (setq git-commit-summary-max-length 70))

(map!
 "M-g m" #'magit-status
 "M-g M" #'magit-list-repositories)




;;; Package: lang/meson

(use-package! meson-mode
  :mode (("\\meson.build\\'" . meson-mode))
  :config
  (setq meson-indent-basic 4))




;;; Package: lang/nim

(after! nim-mode
  (setq nim-pretty-triple-double-quotes nil)

  (setq nim-font-lock-keywords-extra
        `(;; export properties
          (,(nim-rx
             line-start (1+ " ")
             (? "case" (+ " "))
             (group
              (or identifier quoted-chars) "*"
              (? (and "[" word "]"))
              (0+ (and "," (? (0+ " "))
                       (or identifier quoted-chars) "*")))
             (0+ " ") (or ":" "{." "=") (0+ nonl)
             line-end)
           (1 'nim-font-lock-export-face))
          ;; Number literal
          (,(nim-rx nim-numbers)
           (0 'nim-font-lock-number-face))
          ;; Highlight identifier enclosed by "`"
          (nim-backtick-matcher
           (10 font-lock-constant-face prepend))

          ;; Highlight word after ‘is’ and ‘distinct’
          (,(nim-rx " " (or "is" "distinct") (+ " ")
                    (group identifier))
           (1 font-lock-type-face))
          ;; pragma
          (nim-pragma-matcher . (0 'nim-font-lock-pragma-face))))

  (add-hook 'nim-mode-hook #'rainbow-delimiters-mode)
  (add-hook 'nim-mode-hook #'subword-mode)
  (add-hook 'nim-mode-hook #'nimsuggest-mode)
)

;;; Package: lang/plantuml

(after! plantuml-mode
  (setq plantuml-jar-path "/home/schurig/.cache/plantuml.jar"))




;;; Package: lang/python

(after! python
    (defun my-python-setup ()
      (interactive)
      (setq indent-tabs-mode t
            python-indent-offset 4
            tab-width 4
            ;; this fixes the weird indentation when entering a colon
            ;; from http://emacs.stackexchange.com/questions/3322/python-auto-indent-problem
            electric-indent-chars (delq ?: electric-indent-chars)))
    (add-hook 'python-mode-hook #'my-python-setup))



;;; Package: lang/sh-script

(after! sh-script
  (defun my-sh-mode-setup ()
    (interactive)
    (setq-local indent-tabs-mode t)
    (setq tab-width 4)

    ;; Tab positions for M-i
    (setq tab-stop-list '(4 8 12 16 20 24 28 32 36 40 44 48 52 56 60 64 68 72 76 80 84))

    ;; (setq smie-config--buffer-local '((4 :after "{" 4)))
    )

  (add-hook 'sh-mode-hook  #'my-sh-mode-setup))




;;; Package: lang/text-mode

(remove-hook 'text-mode-hook #'auto-fill-mode)




;;; Package: org/org

;; If you use `org' and don't want your org files in the default location below,
;; change `org-directory'. It must be set before org loads!
(setq org-replace-disputed-keys t)

(after! org
  (setq org-directory "~/org/"
        org-fontify-quote-and-verse-blocks nil
        org-fontify-whole-heading-line nil
        org-hide-leading-stars nil
        org-startup-indented nil)
  (electric-indent-mode -1)
  ;; PlantUML
  (setq org-plantuml-jar-path "/usr/local/bin/plantuml.1.2020.16.jar")
  (org-babel-do-load-languages 'org-babel-load-languages
                                 '(plantuml . t))
  (remove-hook 'org-mode-hook #'org-superstar-mode)
  (remove-hook 'org-open-at-point-functions #'doom-set-jump-h)

  (map! :map org-mode-map
        "C-,"  #'embark-act)
)



;;; Package: org/org-pdftools

(use-package! org-pdftools
  :hook (org-mode . org-pdftools-setup-link))



;;; Package: org/ox

(after! ox
  :defer t
  :config
  ;; The following make some +OPTIONS permanent:
  ;; #+OPTIONS ':t
  (setq org-export-with-smart-quotes t)
  ;; #+OPTIONS num:nil
  (setq org-export-with-section-numbers nil)
  ;; #+OPTIONS stat:t
  ;; (setq org-export-with-statistics-cookies nil)
  ;; #+OPTIONS toc:nil, use "#+TOC: headlines 2" or similar if you need a headline
  (setq org-export-with-toc nil)
  ;; #+OPTIONS ^:{}
  (setq org-export-with-sub-superscripts nil)

  ;; This exports broken links as [BROKEN LINK %s], so we can actually
  ;; find them. The default value nil just aborts the export process
  ;; with an error message "Unable to resolve link: nil". This doesn't
  ;; give any hint on which line the broken link actually is :-(
  (setq org-export-with-broken-links 'mark)

  (setq org-export-time-stamp-file nil))



;;; Package: org/ox-html

(after! ox-html
  (setq org-html-postamble-format '(("en" "<p class=\"author\">Author: %a</p><p class=\"creator\">Created with %c</p>")))
  (setq org-html-validation-link nil)
  (setq org-html-postamble nil)
  (setq org-html-style-default "<style type=\"text/css\">\n <!--/*--><![CDATA[/*><!--*/\n  body { text-align: center; font-family: \"Aria\", sans-serif; }\n  #content { margin: 0 auto; width: 860px; text-align: left; }\n  #text-table-of-contents > ul > li { margin-top: 1em; }\n  .title  { text-align: center; }\n  .todo   { color: red; }\n  .done   { color: green; }\n  .WAIT, .DELE   { color: blue; }\n  .done   { color: green; }\n  .tag    { background-color: #eee; font-family: monospace;\n            padding: 2px; font-size: 80%; font-weight: normal; }\n  .timestamp { color: #bebebe; }\n  .timestamp-kwd { color: #5f9ea0; }\n  .right  { margin-left: auto; margin-right: 0px;  text-align: right; }\n  .left   { margin-left: 0px;  margin-right: auto; text-align: left; }\n  .center { margin-left: auto; margin-right: auto; text-align: center; }\n  .underline { text-decoration: underline; }\n  #postamble p, #preamble p { font-size: 90%; margin: .2em; }\n  p.verse { margin-left: 3%; }\n  pre {\n    border: 1px solid #ccc;\n    box-shadow: 3px 3px 3px #eee;\n    padding: 8pt;\n    font-family: monospace;\n    overflow: auto;\n    margin: 1em 0;\n  }\n  pre.src {\n    position: relative;\n    overflow: visible;\n    padding-top: 8pt;\n  }\n  pre.src:before {\n    display: none;\n    position: absolute;\n    background-color: white;\n    top: -10px;\n    right: 10px;\n    padding: 3px;\n    border: 1px solid black;\n  }\n  pre.src:hover:before { display: inline;}\n  pre.src-sh:before    { content: 'sh'; }\n  pre.src-bash:before  { content: 'sh'; }\n  pre.src-emacs-lisp:before { content: 'Emacs Lisp'; }\n  pre.src-R:before     { content: 'R'; }\n  pre.src-perl:before  { content: 'Perl'; }\n  pre.src-java:before  { content: 'Java'; }\n  pre.src-sql:before   { content: 'SQL'; }\n\n  table { border-collapse:collapse; }\n  caption.t-above { caption-side: top; }\n  caption.t-bottom { caption-side: bottom; }\n  td, th { vertical-align:top;  }\n  th.right  { text-align: center;  }\n  th.left   { text-align: center;   }\n  th.center { text-align: center; }\n  td.right  { text-align: right;  }\n  td.left   { text-align: left;   }\n  td.center { text-align: center; }\n  dt { font-weight: bold; }\n  .footpara:nth-child(2) { display: inline; }\n  .footpara { display: block; }\n  .footdef  { margin-bottom: 1em; }\n  .figure { padding: 1em; }\n  .figure p { text-align: center; }\n  .inlinetask {\n    padding: 10px;\n    border: 2px solid gray;\n    margin: 10px;\n    background: #ffffcc;\n  }\n  #org-div-home-and-up\n   { text-align: right; font-size: 70%; white-space: nowrap; }\n  textarea { overflow-x: auto; }\n  .linenr { font-size: smaller }\n  .code-highlighted { background-color: #ffff00; }\n  .org-info-js_info-navigation { border-style: none; }\n  #org-info-js_console-label\n    { font-size: 10px; font-weight: bold; white-space: nowrap; }\n  .org-info-js_search-highlight\n    { background-color: #ffff00; color: #000000; font-weight: bold; }\n  .ulClassNameOrID > li {}\n  /*]]>*/-->\n</style>")
  (setq org-html-table-default-attributes '(:border "2" :cellspacing "0" :cellpadding "6"))
  (setq org-html-postamble t))



;;; Package: ox-hugo

;; https://ox-hugo.scripter.co/

;; (use-package! ox-hugo
;;   :commands (org-hugo-export-wim-to-md)
;;   :after ox
;; )
(after! org
    (defun org2hugo-ensure-properties ()
    (let ((mandatory `(("EXPORT_HUGO_SECTION" . "en")
                       ("EXPORT_FILE_NAME" . "filename")
                       ("EXPORT_DATE" . ,(format-time-string "%Y-%m-%d" (org-current-time)))))
          (optional '(("EXPORT_HUGO_TAGS" . "")
                      ("EXPORT_HUGO_CATEGORIES" . "")))
          (first))

      ;; Insert path to content directory
      (unless (car (plist-get (org-export-get-environment 'hugo) :hugo-base-dir))
        (save-excursion
          (goto-char 1)
          (insert "#+HUGO_BASE_DIR: ../\n\n")))
      ;; loop through mandatory entries, enter them into property if not there, note first missing one
      (dolist (elem mandatory)
        (unless (org-entry-get nil (car elem) t)
          (org-entry-put nil (car elem) (cdr elem))
          (unless first
            (setq first (car elem)))))
      ;; loop through optional entries, enter them into property if not there
      (dolist (elem optional)
        (unless (org-entry-get nil (car elem) t)
          (org-entry-put nil (car elem) (cdr elem))))
      ;; move behind first mandatory entry
      (when first
        (goto-char (org-entry-beginning-position))
        ;; The following opens the drawer
        (forward-line 1)
        (beginning-of-line 1)
        (when (looking-at org-drawer-regexp)
          (org-flag-drawer nil))
        ;; And now move to the drawer property
        (search-forward (concat ":" first ":"))
        (end-of-line))
      ;; return first non-filled entry
      first))


  (defun org2hugo ()
    (interactive)
    (save-window-excursion
      (unless (org2hugo-ensure-properties)
        (let ((title (org-entry-get nil "TITLE" t))
              (file "/tmp/blog.md") ;; TODO
              (blog
               ))

          ;; Create block
          (end-of-line)
          (search-backward ":EXPORT_HUGO_SECTION:")
          (org-hugo-export-wim-to-md)
          ))))

  (map! :map org-mode-map
        "C-c h" #'org2hugo)
)


;;; Package: comm/elfeed

;; https://github.com/skeeto/elfeed
;; http://nullprogram.com/blog/2013/09/04/

(after! elfeed

  ;; Optics
  (setq elfeed-search-date-format '("%Y-%m-%d %H:%M" 17 :left)
        elfeed-search-title-min-width 55
        elfeed-search-title-max-width 55)

  ;; Ignore junk
  (setq elfeed-search-filter "@2-week-ago -junk ")

  ;; Don't truncate URLs, doesn't work nicely with embark
  (setq elfeed-show-truncate-long-urls nil)

  ;; Entries older than 2 weeks are marked as read
  (add-hook 'elfeed-new-entry-hook
            (elfeed-make-tagger :before "2 weeks ago"
                                :remove 'unread))

  ;; from http://pragmaticemacs.com/emacs/read-your-rss-feeds-in-emacs-with-elfeed/
  (defun my-elfeed-quit ()
    "Wrapper to save the elfeed db to disk before burying buffer"
    (interactive)
    (elfeed-db-save)
    (kill-buffer-and-window))

  (defun elfeed-dead-months (months)
    "Return a list of feeds that haven't posted en entry in MONTHS months."
    (cl-block
        (macroexp-let* ((living-feeds (make-hash-table :test 'equal))
                        (seconds (* months 24.0 60 60))
                        (threshold (- (float-time) seconds)))
                       (with-elfeed-db-visit (entry feed)
                         (let ((date (elfeed-entry-date entry)))
                           (when (> date threshold)
                             (setf (gethash (elfeed-feed-url feed) living-feeds) t))))
                       (cl-loop for url in (elfeed-feed-list)
                                unless (gethash url living-feeds)
                                collect url))))
  (elfeed-dead-months 1.0)


  (map! :map elfeed-search-mode-map
        "q" #'my-elfeed-quit)
)


(after! elfeed-org
  (setq rmh-elfeed-org-files (list (concat doom-private-dir "elfeed.org")))
)


;; from http://pragmaticemacs.com/emacs/read-your-rss-feeds-in-emacs-with-elfeed/
(defun my-elfeed-load-db-and-open ()
  "Wrapper to load the elfeed db from disk before opening"
  (interactive)
  (require 'elfeed)
  (setq elfeed-show-entry-switch #'switch-to-buffer)
  (elfeed-db-load)
  (elfeed)
  (elfeed-search-update--force)
  (run-with-timer 0.5 nil #'elfeed-update))

(map! "M-g f" #'my-elfeed-load-db-and-open)




;;; Package: comm/circe

(use-package circe
  :commands (circe)

  :hook (
         (circe-channel-mode . enable-lui-autopaste)
         (circe-channel-mode . my-maybe-log-channel)
         )

  :preface
  (defun irc ()
    "Connect to Freenode via Circe."
    (interactive)
    (circe "Freenode"))

  :config
  (setq circe-reduce-lurker-spam t
        circe-use-cycle-completion t
        circe-network-options
        `(("Freenode"
             :host "chat.freenode.net"
             :server-buffer-name "⇄ Freenode"
             :port "6697"
             :tls t
             :nick "schurig"
             :nickserv-password ,(funcall (plist-get (car (auth-source-search :host "irc.freenode.net" :max 1)) :secret))
             :channels (:after-auth "#emacs" "#emacs-circe")
             )
          ))
  ;; (circe-set-display-handler "JOIN" (lambda (&rest ignored) nil))
  ;; (circe-set-display-handler "PART" (lambda (&rest ignored) nil))
  (defun circe-command-RECONNECT (&optional ignored)
    (circe-reconnect))
)


(use-package circe-color-nicks
  :after circe
  :init
  (enable-circe-color-nicks)
)


(use-package! tracking
  :after circe
  :init
  (tracking-mode)
  :config
  (setq tracking-most-recent-first t
        tracking-position 'end)
)


(use-package! lui
  :defer t
  :config
  (setq lui-flyspell-p t)
  ;; (setq lui-flyspell-alist '(("#hamburg" "german8")
  ;;                            (".*" "american")))
)


(use-package! lui-logging
  :commands (enable-lui-logging)
  :preface
  (defvar my-logged-irc-channels
    '("#emacs")
    "List of channels to log.")

  (defun my-maybe-log-channel ()
    "Maybe start logging the an IRC channel."
    (when (-contains? my-logged-irc-channels (buffer-name))
      (enable-lui-logging)))

  :config
  (setq lui-logging-directory (concat doom-local-dir "logging"))
)


;;; Package: comm/erc

;; out your credentials into .authinfo[.gpg], e.g. like this:
;; machine irc.freenode.net login USERNAME password PASSWORD

;; https://old.reddit.com/r/emacs/comments/8ml6na/tip_how_to_make_erc_fun_to_use/
(use-package! erc
  :disabled t
  :preface
  (defun my-erc ()
    "Connects to ERC, or switch to last active buffer."
    (interactive)
    (if (get-buffer "irc.freenode.net:6667")
        (erc-track-switch-buffer 1)
      (erc :server "irc.freenode.net" :port 6667 :nick "rememberYou")))

  (defun my-erc-reset-track-mode ()
    "Resets ERC track mode."
    (interactive)
    (setq erc-modified-channels-alist nil)
    (erc-modified-channels-update)
    (erc-modified-channels-display)
    (force-mode-line-update))

  (defun my-erc-preprocess (string)
    "Avoids channel flooding."
    (setq str (string-trim (replace-regexp-in-string "\n+" " " str))))

  :hook (;;(ercn-notify . my/erc-notify)
         (erc-send-pre . my/erc-preprocess))
  :custom
  (erc-autojoin-channels-alist '(("freenode.net" "#pandorabox")))
  (erc-autojoin-timing 'ident)
  (erc-header-line-format "%n on %t (%m)")
  (erc-join-buffer 'bury)
  (erc-kill-buffer-on-part t)
  (erc-kill-queries-on-quit t)
  (erc-kill-server-buffer-on-quit t)
  (erc-fill-function 'erc-fill-static)
  (erc-fill-static-center 22)
  (erc-hide-list '("JOIN" "PART" "QUIT"))
  (erc-lurker-hide-list '("JOIN" "PART" "QUIT"))
  (erc-lurker-threshold-time 43200)
  (erc-prompt-for-nickserv-password nil)
  (erc-server-reconnect-attempts 5)
  (erc-server-reconnect-timeout 3)
  (erc-track-exclude-types '("JOIN" "MODE" "NICK" "PART" "QUIT"
                             "324" "329" "332" "333" "353" "477"))
  :config
  (add-to-list 'erc-modules 'notifications)
  (add-to-list 'erc-modules 'spelling)
  (erc-services-mode 1)
  (erc-update-modules))



;;; Packages: comm/mu4e

(after! mu4e
  ;; setting this again because .doom.d/modules/email/mu4e/config.el overwrites it
  (setq message-send-mail-function #'message-send-mail-with-sendmail)
  (setq mu4e-get-mail-command "~/.local/bin/mbsync.sh")

  ;; Optics
  (setq mu4e-headers-fields '(
                              (:human-date . 8)
                              (:flags . 5)
                              (:from-or-to . 20)
                              (:mailing-list . 8)
                              (:thread-subject . 60)
                              )
        mu4e-maildir-shortcuts '( (:maildir "/inbox"     :key  ?i)
                                  (:maildir "/barebox"   :key  ?b)
                                  (:maildir "/darc-sdr"  :key  ?d)
                                  (:maildir "/elecraft"  :key  ?e)
                                  (:maildir "/etnaviv"   :key  ?v)
                                  (:maildir "/linuxham"  :key  ?l)
                                  (:maildir "/zephyr"    :key  ?z)
                                  (:maildir "/sent"      :key  ?s)
                                  (:maildir "/trash"     :key  ?t)
                                  )
        mu4e-headers-date-format "%d.%m.%y"
        mu4e-headers-time-format "%H:%M"
        mu4e-use-fancy-chars nil
        mu4e-headers-results-limit 1000)

  ;; Completing read will use Selectrum
  (setq mu4e-completing-read-function #'completing-read)

  ;; Attachment handling
  (setq mu4e-attachment-dir "~/Downloads")

  ;; Replying
  (setq mu4e-compose-dont-reply-to-self t)

  ;; Updating/Indexing
  (setq mu4e-update-interval 600
        mu4e-index-lazy-check nil)


  ;; make "H" (help) work in mu4e
  (add-to-list 'Info-directory-list (concat straight-base-dir "straight/repos/mu/mu4e/"))

  ;; see also https://www.djcbsoftware.nl/code/mu/mu4e/Keybindings.html
  (map! :map mu4e-main-mode-map
        "c" #'mu4e-compose-new
        "u" #'mu4e-update-mail-and-index
        :map mu4e-headers-mode-map
        "n" #'mu4e-headers-next-unread
        "p" #'mu4e-headers-prev-unread
        ;; swap refile and reply
        "R" #'mu4e-headers-mark-for-refile
        "r" #'mu4e-compose-reply)

  (defun mu4e~main-redraw-buffer ()
    (with-current-buffer mu4e-main-buffer-name
      (let ((inhibit-read-only t)
            (pos (point))
            (addrs (mu4e-personal-addresses)))
        (erase-buffer)
        (insert
         "\n"
         (propertize "  Basics\n\n" 'face 'mu4e-title-face)
         (mu4e~main-action-str "\t* [c]ompose a new message\n" 'mu4e-compose-new)
         (if mu4e-maildir-shortcuts
             ""
           (mu4e~main-action-str "\t* [j]ump to some maildir\n" 'mu4e-jump-to-maildir))
         (mu4e~main-action-str "\t* enter a [s]earch query\n" 'mu4e-search)
         "\n"
         (propertize "  Bookmarks\n\n" 'face 'mu4e-title-face)
         (mu4e~main-bookmarks)
         "\n"
         (if mu4e-maildir-shortcuts
             (concat (propertize "  Maildirs\n\n" 'face 'mu4e-title-face)
                     (mu4e~main-maildirs)
                     "\n")
           "")
         (propertize "  Misc\n\n" 'face 'mu4e-title-face)

         ;; show the queue functions if `smtpmail-queue-dir' is defined
         (if (file-directory-p smtpmail-queue-dir)
             (mu4e~main-view-queue)
           "")
         (mu4e~main-action-str "\t* [u]pdate email & database\n"
                               'mu4e-update-mail-and-index)
         (mu4e~main-action-str "\t* [H]elp\n" 'mu4e-display-manual)
         (mu4e~main-action-str "\t* [q]uit\n" 'mu4e-quit)

         "\n"
         (propertize "  Info\n\n" 'face 'mu4e-title-face)
         (mu4e~key-val "messages"
                       (format "%d" (plist-get mu4e~server-props :doccount)) "messages")
         (mu4e~key-val "version" mu4e-mu-version)
         ;; (if mu4e-main-hide-personal-addresses ""
         ;;   (mu4e~key-val "personal addresses" (if addrs (mapconcat #'identity addrs ", "  ) "none")))
         )

        (if mu4e-main-hide-personal-addresses ""
          (unless (mu4e-personal-address-p user-mail-address)
            (mu4e-message (concat
                           "Tip: `user-mail-address' ('%s') is not part "
                           "of mu's addresses; add it with 'mu init
                        --my-address='") user-mail-address)))
        (mu4e-main-mode)
        (goto-char pos))))
)
(map! "M-g n" #'=mu4e ;; was next-error
      "M-g p" nil)    ;; was previous-error
