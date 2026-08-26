;; -*- coding: utf-8-unix; lexical-binding: t; -*-

;; Inserts Zero-Width Space

;; With org-mode you may want to define this as well
;; (setq org-emphasis-regexp-components
;;      '("   ('\"{\x200B" "-     .,:!?;'\")}\\[\x200B" "     
;; ,\"'" "." 1))

;; Assign key (for instance C-c C-x *)
;; (global-set-key (kbd "C-c C-x *") 'insert-zero-width-space)

;;;###autoload
(defun insert-zero-width-space ()
  (interactive)
  (insert-char #x200b))

(provide 'insert-zero-width-space)
