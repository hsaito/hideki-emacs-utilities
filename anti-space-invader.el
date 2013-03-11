;; -*- coding: utf-8-unix; -*-
;;; anti-space-invader.el --- Anti-Space Invader

;;; Commentary:
;; 
;; Summary: Eradicates two spaces after period into single space
;;
;; Background:
;; Either one-space after period and single space after period are correct in sentence spacing.
;; This script will make a life easier for those using single space when they come across documents prepared using two-spaces.
;; 
;; Limitations:
;; This is simple search and replace, so it does not detect cases that such two-space after period usage may be legit.
;; (Also, reverse conversion is not simple.)
;;
;; References:
;; http://en.wikipedia.org/wiki/Sentence_spacing
;; http://www.slate.com/articles/technology/technology/2011/01/space_invaders.html
;; 
;; Install:
;; Add the following to .emacs
;; (require 'anti-space-invader)
;;

;;; Code:

(defun anti-space-invader()
  "Eradicate two spaces after period and replace with single space."
  (interactive)
  (beginning-of-buffer)
  (replace-string "\x2e\x20\x20" "\x2e\x20")
  
  ;; Return to the top of the buffer
  (beginning-of-buffer)
  )

(provide 'anti-space-invader)

;;; anti-space-invader.el ends here
