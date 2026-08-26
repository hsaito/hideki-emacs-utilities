;; -*- coding: utf-8-unix; lexical-binding: t; -*-
;;; uuid.el --- UUID Generation Script (multi-version)
;;; Written by Hideki Saito

;;; Code:

(require 'cl-lib)

(defun uuid--bytes-to-hex (bytes)
  (mapconcat (lambda (b) (format "%02x" b)) bytes ""))

(defun uuid--random-bytes (n)
  (let (res)
    (dotimes (_ n)
      (push (random 256) res))
    (nreverse res)))

(defun uuid--set-version (bytes ver)
  "Set UUID version VER (1–8) in BYTES (16-byte list)."
  ;; version is high 4 bits of byte 6 (0-based)
  (let* ((b (nth 6 bytes))
         (b (logior (logand b #x0f) (lsh ver 4))))
    (setf (nth 6 bytes) b)
    bytes))

(defun uuid--set-variant-rfc4122 (bytes)
  "Set RFC 4122 variant in BYTES (16-byte list)."
  ;; variant is high bits of byte 8 (0-based)
  (let* ((b (nth 8 bytes))
         (b (logior (logand b #x3f) #x80))) ; 10xx xxxx
    (setf (nth 8 bytes) b)
    bytes))

(defun uuid--format (bytes)
  "Format 16-byte UUID BYTES as xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx."
  (let ((hex (uuid--bytes-to-hex bytes)))
    (format "%s-%s-%s-%s-%s"
            (substring hex 0 8)
            (substring hex 8 12)
            (substring hex 12 16)
            (substring hex 16 20)
            (substring hex 20 32))))

;; ----------------------------------------------------------------------
;; Generate each version of UUID
;; ----------------------------------------------------------------------

;; No interactive generation for UUID v3 and v5

(defun uuid-generate-v3 (namespace name)
  "Generate UUID v3 (MD5)."
  (let* ((ns-bytes (uuid--hex-to-bytes namespace))
         (hash (md5 (concat ns-bytes name) nil nil t))
         (bytes (cl-loop for i from 0 below 16
                         collect (aref hash i))))
    (uuid--format
     (uuid--set-variant-rfc4122
      (uuid--set-version bytes 3)))))


(defun uuid-generate-v5 (namespace name)
  "Generate UUID v5 (SHA-1)."
  (let* ((ns-bytes (uuid--hex-to-bytes namespace))
         (hash (secure-hash 'sha1 (concat ns-bytes name) nil nil t))
         (bytes (cl-loop for i from 0 below 16
                         collect (aref hash i))))
    (uuid--format
     (uuid--set-variant-rfc4122
      (uuid--set-version bytes 5)))))

(defun uuid-generate-v4 ()
  "Generate a RFC 4122 UUID v4 (random)."
  (let* ((bytes (uuid--random-bytes 16)))
    (uuid--format
     (uuid--set-variant-rfc4122
      (uuid--set-version bytes 4)))))

(defun uuid-generate-v7 ()
  "Generate a UUID v7 (Unix-ms timestamp + random)."
  (let* ((now (float-time))
         (ms (floor (* now 1000)))          ; 48-bit
         (bytes (uuid--random-bytes 16)))
    ;; unix_ms 48bit → bytes[0..5]
    (setf (nth 0 bytes) (logand (lsh ms -40) #xff))
    (setf (nth 1 bytes) (logand (lsh ms -32) #xff))
    (setf (nth 2 bytes) (logand (lsh ms -24) #xff))
    (setf (nth 3 bytes) (logand (lsh ms -16) #xff))
    (setf (nth 4 bytes) (logand (lsh ms -8)  #xff))
    (setf (nth 5 bytes) (logand ms           #xff))
    (uuid--format
     (uuid--set-variant-rfc4122
      (uuid--set-version bytes 7)))))

(defun uuid-generate-nil ()
  "Generate the nil UUID (all zeros)."
  (uuid--format (make-list 16 0)))

(defun uuid-generate-max ()
  "Generate the max UUID (all ones, RFC 9562)."
  (uuid--format (make-list 16 #xff)))

;; ----------------------------------------------------------------------
;; Interactive insertion
;; ----------------------------------------------------------------------

;;;###autoload
(defun insert-uuid-v4 ()
  "Insert a random UUID v4."
  (interactive)
  (insert (uuid-generate-v4)))

;;;###autoload
(defun insert-uuid-v7 ()
  "Insert a time-ordered UUID v7."
  (interactive)
  (insert (uuid-generate-v7)))

;;;###autoload
(defun insert-uuid-nil ()
  "Insert the nil UUID."
  (interactive)
  (insert (uuid-generate-nil)))

;;;###autoload
(defun insert-uuid-max ()
  "Insert the max UUID."
  (interactive)
  (insert (uuid-generate-max)))

;;;###autoload
(defun insert-uuid-select-version (ver)
  "Insert a UUID of selected version VER (symbol).
Supported: 'v4, 'v7, 'nil, 'max."
  (interactive
   (list (intern (completing-read "UUID version: "
                                  '("v4" "v7" "nil" "max")
                                  nil t "v4"))))
  (insert
   (pcase ver
     ('v4  (uuid-generate-v4))
     ('v7  (uuid-generate-v7))
     ('nil (uuid-generate-nil))
     ('max (uuid-generate-max))
     (_    (error "Unsupported UUID version: %S" ver)))))

(provide 'uuid)

;;; uuid.el ends here
