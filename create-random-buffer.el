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
;; Install:
;; Add the following to .emacs
;; (require 'create-random-buffer)
;;

(provide 'create-random-buffer)

(defun create-random-buffer ()
  "Creates an empty buffer with random name."
  (interactive)
  (switch-to-buffer (concat "*" (concat (sha1 (number-to-string (random))) "*")))
  )

(defun create-random-tempfile ()
  "Creates temporary txt file of random name."
  (interactive)
  (switch-to-buffer (concat "temp-" (sha1 (number-to-string(random))) ".txt"))
  );; Create Random Buffer
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
;; Install:
;; Add the following to .emacs
;; (require 'create-random-buffer)
;;

(provide 'create-random-buffer)

(defun create-random-buffer ()
  "Creates an empty buffer with random numbered name."
  (interactive)
  (switch-to-buffer (concat "*" (concat (number-to-string (random)) "*")))
  )
