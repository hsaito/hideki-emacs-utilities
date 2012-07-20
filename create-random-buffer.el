;; Create Random Buffer
;; by Hideki Saito (hidekis@gmail.com)
;;
;; Summary: Creates an empty buffer with random numbered name.
;;
;; Background: 
;; Just wanted to make extra "scratch" buffer.
;; 
;; Limitations:
;; Does not handle buffer name collision.
;;
;; Requires:
;; Emacs 24.1 or later
;;
;; Install:
;; Add the following to .emacs
;; (require 'create-random-buffer)
;;

(provide 'create-random-buffer)

(defun create-random-buffer ()
  "Creates an empty buffer with random name."
  (interactive)
  (switch-to-buffer (concat "*temp-" (concat (sha1 (number-to-string (random))) "*")))
  )

(setq random-tempfile-default-directory "~/")

(defun create-random-tempfile ()
  "Creates temporary txt file of random name."
  (interactive)
  (find-file (concat random-tempfile-default-directory (concat "temp-" (sha1 (number-to-string(random))) ".txt")))
  )
