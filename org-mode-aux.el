;; Org auxiliary functions

(defun org-aux-html-validate-off ()
  (interactive)
  (setq org-export-html-validation-link nil)
  )

(defun org-aux-html-validate-on ()
  (interactive)
  (setq org-export-html-validation-link t)
  )

(provide 'org-mode-aux)