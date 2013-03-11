;; -*- coding: utf-8-unix -*-
;;; org-mode-aux.el --- Org Auxiliary Functions

;;; Commentary:
;; 

;;; Code:

(defun org-aux-html-validate-off ()
  "Disable HTML validation link when exporting HTML."
  (interactive)
  (setq org-export-html-validation-link nil)
  )

(defun org-aux-html-validate-on ()
  "Enable HTML validation link when exporting HTML."
  (interactive)
  (setq org-export-html-validation-link t)
  )

(provide 'org-mode-aux)

;;; org-mode-aux.el ends here
