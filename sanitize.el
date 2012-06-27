;; Script sanitizing script
;; by Hideki Saito
;;
;; Summary: A simple script that sanitizes text
;;
;; Background: Certain CMS system I use causes encoding issue 
;; when certain character, which would appear when original 
;; texts are prepared using word processor softwares.
;; This script removes those texts with acceptable ones.
;;
;; Function: Replaces unusable texts.
;;
;; Install:
;; Add the following to .emacs
;; (require 'sanitize)
;;

(provide 'sanitize)

(defun sanitize-buffer ()
  "Sanitize buffer for certain proprietary CMS system."
  (interactive)
  ;; Curly quote (x2019) replaced to quote
  (beginning-of-buffer)
  (replace-string "\x2019" "'")
  
  ;; ... (x2026) replaced to ...
  (beginning-of-buffer)
  (replace-string "\x2026" "...")
  
  ;; Quotes (x201c, x201d)
  (beginning-of-buffer)
  (replace-string "\x201c" "\x22")
  (beginning-of-buffer)
  (replace-string "\x201d" "\x22")

  ;; Two spaces after period. (HTML doesn't understand them anyways)
  (beginning-of-buffer)
  (replace-string "\x2e\x20\x20" "\x2e\x20")
  
  ;; Return to the top of the buffer
  (beginning-of-buffer)
  )
