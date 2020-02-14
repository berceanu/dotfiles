;; Added by Package.el.  This must come before configurations of
;; installed packages.  Don't delete this line.  If you don't want it,
;; just comment it out by adding a semicolon to the start of the line.
;; You may delete these explanatory comments.
(package-initialize)

(add-to-list 'load-path "~/.emacs.d/el-get/el-get")

(unless (require 'el-get nil 'noerror)
  (with-current-buffer
      (url-retrieve-synchronously
       "https://raw.githubusercontent.com/dimitri/el-get/master/el-get-install.el")
    (goto-char (point-max))
    (eval-print-last-sexp)))

(add-to-list 'el-get-recipe-path "~/.emacs.d/el-get-user/recipes")

(el-get-bundle better-defaults)
(el-get-bundle color-theme-zenburn (load-theme 'zenburn t))
(el-get-bundle markdown-mode)
(el-get-bundle epresent)
(el-get-bundle elpy)
(el-get-bundle matlab-mode)


;; Emacs various
(setq inhibit-splash-screen t)
(setq frame-title-format "%b")
(put 'downcase-region 'disabled nil)
(defalias 'yes-or-no-p 'y-or-n-p)
(column-number-mode 1)
(setq doc-view-continuous t)
(setq 
  bookmark-default-file "~/.emacs.d/bookmarks" ;; keep my ~/ clean
  bookmark-save-flag 1)                        ;; autosave each change
(setq savehist-additional-variables        ;; also save...
      '(search-ring regexp-search-ring)    ;; ... my search entries
      savehist-file "~/.emacs.d/savehist") ;; keep my home clean
(savehist-mode t)                          ;; do customization before activate

;; For markdown-mode preview
(setq markdown-command "pandoc")

;; Menlo font from https://github.com/hbin/top-programming-fonts
(set-frame-font "InconsolataGo Nerd Font:pixelsize=18")

;; Org-Babel languages
(org-babel-do-load-languages
 'org-babel-load-languages
 '((python . t)
   (shell . t)
   ))

;; Org-Mode
(setq org-confirm-babel-evaluate nil)

;; Display inline images
(setq org-startup-with-inline-images t)


;;; my own functions

;; prevent accidental use of C-w (kill-region)
(defun my-kill-region ()
  (interactive)
  (if (region-active-p)
      (call-interactively 'kill-region)
    (message "Region not active, didn't kill")))
;;
(global-set-key (kbd "C-w") 'my-kill-region)

 
;; LaTeX citation statistics
(defun trim-string (string)
  "Remove white spaces in beginning and ending of STRING.
White space here is any of: space, tab, emacs newline (line feed,
ASCII 10)."
  (replace-regexp-in-string "\\`[ \t\n]*" "" (replace-regexp-in-string "[ \t\n]*\\'" "" string)))
;;
(defun print-to-org-table (alist)
  "Outputs an association list to an org table in a new buffer.
This function takes an asssociation list, alist, as input and
opens a new buffer in org-mode where it prints the list as a
2-column table."
  (with-current-buffer (get-buffer-create "*zork*")
    (erase-buffer)
    (turn-on-orgtbl)
    (insert "| Key | Occurences |\n")
    (insert "|-----+------------|\n")
    (dolist (x alist)
      (insert (format "| %s | %s |\n" (car x) (cdr x))))
    (org-table-align)
    (display-buffer (current-buffer))))
;;
(defun freqs (list)
  "Count item frequency in a list.
Given a list as input, this function outputs a (sorted) alist
where the key-value pairs are the items in the original list and
their number of appearances."
  (let ((h (make-hash-table :test 'equal)))
    (dolist (key list) ;; loop key through elements of list
      ;; build hash table, counting occurences
      (puthash key (1+ (gethash key h 0)) h))
    (let ((r nil)) ;; initialize results list r
      ;; build results alist from hash table h
      (maphash (lambda (k v) (push (cons k v) r)) h)
      ;; sort results by frequency of occurence
      (sort r (lambda (x y) (> (cdr x) (cdr y)))))))
;;
(defun extract-cite-keys-region (beginning end)
  "Extract BibTeX citation keys in the region.
BibTeX keys are contained as arguments of the various \cite
commands present in the region, eg. \cite{key1, key2, key3}. This
function parses the region and returns a list of all the keys."
  (interactive "r")
  (message "Extracting BibTeX keys in region ... ")

  (save-excursion
    (goto-char beginning)
    (let ((case-fold-search nil)
          (cite-regexp "\\\\cite{\\([^}]+\\)}")
          (key "")
          (split-key ())
          (keys ()))

      (while (and (< (point) end)
                  (re-search-forward cite-regexp end t))
        ;; We only want the content, not the text properties. We take
        ;; the match of the first (and only) capturing group defined
        ;; in the regex.
        (setq key (buffer-substring-no-properties (match-beginning 1) (match-end 1)))
        (setq split-key (split-string key ","))
        ;; trim whitespaces and newlines
        (setq split-trim-key (mapcar 'trim-string split-key))
        (setq keys (append keys split-trim-key)))

      (print-to-org-table (freqs keys)))))
;;
(global-set-key "\C-ce" 'extract-cite-keys-region)
