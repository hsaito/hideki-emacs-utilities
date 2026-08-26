;; -*- coding: utf-8-unix; lexical-binding: t; -*-
;;; utf-32.el --- UTF-32 Support for Emacs

;;; Commentary:
;; UTF-32 support for Emacs using binary coding-type and explicit
;; pre/post conversion between Emacs characters and UTF-32 byte streams.
;;
;; Original idea and structure based on older utf-32.el, rewritten
;; for modern Emacs (multibyte/unibyte aware, byte-level conversion).

;; Written by Hideki Saito

;;; Code:

;; ------------------------------------------------------------
;; Basic Utility
;; ------------------------------------------------------------

(defun utf-32--char-code (ch)
  "Return Unicode codepoint for CH.
For modern Emacs, the character code is effectively the UCS value."
  (if (integerp ch) ch (encode-char ch 'ucs)))

(defun utf-32--encode-codepoint-be (cp)
  "Return a list of 4 bytes (0-255) for codepoint CP in UTF-32BE."
  (list (logand (lsh cp -24) #xff)
        (logand (lsh cp -16) #xff)
        (logand (lsh cp -8)  #xff)
        (logand cp           #xff)))

(defun utf-32--encode-codepoint-le (cp)
  "Return a list of 4 bytes (0-255) for codepoint CP in UTF-32LE."
  (list (logand cp           #xff)
        (logand (lsh cp -8)  #xff)
        (logand (lsh cp -16) #xff)
        (logand (lsh cp -24) #xff)))

(defun utf-32--insert-bytes (bytes)
  "Insert BYTES (list of 0-255) into current buffer as unibyte chars."
  (dolist (b bytes)
    (insert (char-to-string b))))

(defun utf-32--read-4-bytes (str idx)
  "Read 4 bytes from STR starting at IDX, return (CP . NEXT-IDX).
CP is the reconstructed codepoint, NEXT-IDX is the next index."
  (let* ((b0 (aref str idx))
         (b1 (aref str (1+ idx)))
         (b2 (aref str (+ idx 2)))
         (b3 (aref str (+ idx 3)))
         (cp (logior (lsh b0 24)
                     (lsh b1 16)
                     (lsh b2 8)
                     b3)))
    (cons cp (+ idx 4))))

(defun utf-32--read-4-bytes-le (str idx)
  "Read 4 bytes from STR starting at IDX as UTF-32LE, return (CP . NEXT-IDX)."
  (let* ((b0 (aref str idx))
         (b1 (aref str (1+ idx)))
         (b2 (aref str (+ idx 2)))
         (b3 (aref str (+ idx 3)))
         (cp (logior b0
		     (lsh b1 8)
		     (lsh b2 16)
		     (lsh b3 24))))
    (cons cp (+ idx 4))))

;; ------------------------------------------------------------
;; Common primitives for writing (pre-write)
;; ------------------------------------------------------------

(defun utf-32--pre-write-conversion (from to endian bom eol-type)
  "Convert region [FROM, TO] to UTF-32 byte stream.

ENDIAN is symbol 'be or 'le.
BOM is non-nil to emit BOM.
EOL-TYPE is symbol 'unix or 'dos (Provisionally use unix for Mac)"
  (save-excursion
    (goto-char from)
    (let* ((text (buffer-substring from to)))
      ;; Remove the text and switch unibyte buffer
      (delete-region from to)
      (set-buffer-multibyte nil)
      (goto-char from)
      ;; BOM
      (when bom
        (let ((bom-cp #x0000feff))
	  (utf-32--insert-bytes
	   (if (eq endian 'be)
	       (utf-32--encode-codepoint-be bom-cp)
	     (utf-32--encode-codepoint-le bom-cp)))))
      ;; Main
      (let ((len (length text))
	    (i 0))
        (while (< i len)
	  (let* ((ch (aref text i))
                 (cp (utf-32--char-code ch)))
	    (cond
	     ;; In case of DOS, insert CR before CR
	     ((and (eq eol-type 'dos)
		   (= cp ?\n))
	      ;; CR
	      (utf-32--insert-bytes
	       (if (eq endian 'be)
		   (utf-32--encode-codepoint-be ?\r)
                 (utf-32--encode-codepoint-le ?\r)))
	      ;; LF
	      (utf-32--insert-bytes
	       (if (eq endian 'be)
		   (utf-32--encode-codepoint-be ?\n)
                 (utf-32--encode-codepoint-le ?\n))))
	     (t
	      (utf-32--insert-bytes
	       (if (eq endian 'be)
		   (utf-32--encode-codepoint-be cp)
                 (utf-32--encode-codepoint-le cp)))))
	    (setq i (1+ i)))))))
  ;; Return the len as is because of the way Emacs handles it
  (- to from))

;; ------------------------------------------------------------
;; Common primitives for reading (post-read)
;; ------------------------------------------------------------

(defun utf-32--safe-insert-codepoint (cp)
  "Insert CP as an Emacs character safely."
  (cond
   ;; Valid Unicode range
   ((<= cp #x10FFFF)
    (insert (char-to-string cp)))
   ;; Surrogate or invalid → replace with U+FFFD
   (t
    (insert (char-to-string #xFFFD)))))


(defun utf-32--post-read-conversion (len endian bom eol-type)
  "Convert current buffer (unibyte UTF-32 bytes) to multibyte text.

LEN is original length (unused but kept for API compatibility).
ENDIAN is 'be or 'le.
BOM is non-nil if BOM should be stripped.
EOL-TYPE is 'unix or 'dos."
  (save-excursion
    (goto-char (point-min))
    (let* ((raw (string-make-unibyte
		 (buffer-substring-no-properties (point-min) (point-max))))
	   (raw-len (length raw))
	   (idx 0)
	   (out (get-buffer-create " *utf-32-temp*")))
      (with-current-buffer out
        (erase-buffer)
        (set-buffer-multibyte t))
      ;; Removes BOM
      (when (and bom (>= raw-len 4))
        (let* ((pair (if (eq endian 'be)
                         (utf-32--read-4-bytes raw idx)
		       (utf-32--read-4-bytes-le raw idx)))
	       (cp (car pair))
	       (next (cdr pair)))
	  (when (= cp #x0000feff)
	    (setq idx next)))
        )
      ;; Restore the body
      (while (<= (+ idx 3) (1- raw-len))
        (let* ((pair (if (eq endian 'be)
                         (utf-32--read-4-bytes raw idx)
		       (utf-32--read-4-bytes-le raw idx)))
	       (cp (car pair))
	       (next (cdr pair)))
	  (setq idx next)
	  (cond
	   ;; For DOS throw out CR, and convert LF to return
	   ((and (eq eol-type 'dos)
                 (= cp ?\r))
	    ;; Do nothing (wait for the next LF)
	    )
	   ((and (eq eol-type 'dos)
                 (= cp ?\n))
	    (with-current-buffer out
	      (insert "\n")))
	   (t
	    (with-current-buffer out
	      (utf-32--safe-insert-codepoint cp)))))
	)
      ;; Replace the buffer
      (erase-buffer)
      (set-buffer-multibyte t)
      (insert-buffer-substring out)
      (kill-buffer out)
      (goto-char (point-min))))
  len)

;; ------------------------------------------------------------
;; Individual pre/post conversion wrappers
;; ------------------------------------------------------------

;; BE / LE, BOM Present and not present UNIX / DOS

(defun utf-32be-with-signature-unix-pre-write-conversion (from to)
  (utf-32--pre-write-conversion from to 'be t 'unix))

(defun utf-32be-with-signature-unix-post-read-conversion (len)
  (utf-32--post-read-conversion len 'be t 'unix))

(defun utf-32be-with-signature-dos-pre-write-conversion (from to)
  (utf-32--pre-write-conversion from to 'be t 'dos))

(defun utf-32be-with-signature-dos-post-read-conversion (len)
  (utf-32--post-read-conversion len 'be t 'dos))

(defun utf-32le-with-signature-unix-pre-write-conversion (from to)
  (utf-32--pre-write-conversion from to 'le t 'unix))

(defun utf-32le-with-signature-unix-post-read-conversion (len)
  (utf-32--post-read-conversion len 'le t 'unix))

(defun utf-32le-with-signature-dos-pre-write-conversion (from to)
  (utf-32--pre-write-conversion from to 'le t 'dos))

(defun utf-32le-with-signature-dos-post-read-conversion (len)
  (utf-32--post-read-conversion len 'le t 'dos))

(defun utf-32be-unix-pre-write-conversion (from to)
  (utf-32--pre-write-conversion from to 'be nil 'unix))

(defun utf-32be-unix-post-read-conversion (len)
  (utf-32--post-read-conversion len 'be nil 'unix))

(defun utf-32be-dos-pre-write-conversion (from to)
  (utf-32--pre-write-conversion from to 'be nil 'dos))

(defun utf-32be-dos-post-read-conversion (len)
  (utf-32--post-read-conversion len 'be nil 'dos))

(defun utf-32le-unix-pre-write-conversion (from to)
  (utf-32--pre-write-conversion from to 'le nil 'unix))

(defun utf-32le-unix-post-read-conversion (len)
  (utf-32--post-read-conversion len 'le nil 'unix))

(defun utf-32le-dos-pre-write-conversion (from to)
  (utf-32--pre-write-conversion from to 'le nil 'dos))

(defun utf-32le-dos-post-read-conversion (len)
  (utf-32--post-read-conversion len 'le nil 'dos))

;; Provisionally use unix for Mac

(defun utf-32be-with-signature-mac-pre-write-conversion (from to)
  (utf-32be-with-signature-unix-pre-write-conversion from to))

(defun utf-32be-with-signature-mac-post-read-conversion (len)
  (utf-32be-with-signature-unix-post-read-conversion len))

(defun utf-32le-with-signature-mac-pre-write-conversion (from to)
  (utf-32le-with-signature-unix-pre-write-conversion from to))

(defun utf-32le-with-signature-mac-post-read-conversion (len)
  (utf-32le-with-signature-unix-post-read-conversion len))

(defun utf-32be-mac-pre-write-conversion (from to)
  (utf-32be-unix-pre-write-conversion from to))

(defun utf-32be-mac-post-read-conversion (len)
  (utf-32be-unix-post-read-conversion len))

(defun utf-32le-mac-pre-write-conversion (from to)
  (utf-32le-unix-pre-write-conversion from to))

(defun utf-32le-mac-post-read-conversion (len)
  (utf-32le-unix-post-read-conversion len))

;; ------------------------------------------------------------
;; coding-system definitions
;; ------------------------------------------------------------

;; Realize UTF-32 using utf-8 base, but with pre/post processing.

(define-coding-system 'utf-32be-with-signature-unix
  "UTF-32 (big endian, BOM, Unix LF)."
  :coding-type 'utf-8
  :mnemonic ?U
  :eol-type 'unix
  :charset-list '(unicode)
  :pre-write-conversion 'utf-32be-with-signature-unix-pre-write-conversion
  :post-read-conversion 'utf-32be-with-signature-unix-post-read-conversion)

(define-coding-system 'utf-32be-with-signature-dos
  "UTF-32 (big endian, BOM, DOS CRLF)."
  :coding-type 'utf-8
  :mnemonic ?U
  :eol-type 'dos
  :charset-list '(unicode)
  :pre-write-conversion 'utf-32be-with-signature-dos-pre-write-conversion
  :post-read-conversion 'utf-32be-with-signature-dos-post-read-conversion)

(define-coding-system 'utf-32be-with-signature-mac
  "UTF-32 (big endian, BOM, Mac-style; currently treated as Unix LF)."
  :coding-type 'utf-8
  :mnemonic ?U
  :eol-type 'unix
  :charset-list '(unicode)
  :pre-write-conversion 'utf-32be-with-signature-mac-pre-write-conversion
  :post-read-conversion 'utf-32be-with-signature-mac-post-read-conversion)

(define-coding-system 'utf-32le-with-signature-unix
  "UTF-32 (little endian, BOM, Unix LF)."
  :coding-type 'utf-8
  :mnemonic ?U
  :eol-type 'unix
  :charset-list '(unicode)
  :pre-write-conversion 'utf-32le-with-signature-unix-pre-write-conversion
  :post-read-conversion 'utf-32le-with-signature-unix-post-read-conversion)

(define-coding-system 'utf-32le-with-signature-dos
  "UTF-32 (little endian, BOM, DOS CRLF)."
  :coding-type 'utf-8
  :mnemonic ?U
  :eol-type 'dos
  :charset-list '(unicode)
  :pre-write-conversion 'utf-32le-with-signature-dos-pre-write-conversion
  :post-read-conversion 'utf-32le-with-signature-dos-post-read-conversion)

(define-coding-system 'utf-32le-with-signature-mac
  "UTF-32 (little endian, BOM, Mac-style; currently treated as Unix LF)."
  :coding-type 'utf-8
  :mnemonic ?U
  :eol-type 'unix
  :charset-list '(unicode)
  :pre-write-conversion 'utf-32le-with-signature-mac-pre-write-conversion
  :post-read-conversion 'utf-32le-with-signature-mac-post-read-conversion)

(define-coding-system 'utf-32be-unix
  "UTF-32 (big endian, no BOM, Unix LF)."
  :coding-type 'utf-8
  :mnemonic ?U
  :eol-type 'unix
  :charset-list '(unicode)
  :pre-write-conversion 'utf-32be-unix-pre-write-conversion
  :post-read-conversion 'utf-32be-unix-post-read-conversion)

(define-coding-system 'utf-32be-dos
  "UTF-32 (big endian, no BOM, DOS CRLF)."
  :coding-type 'utf-8
  :mnemonic ?U
  :eol-type 'dos
  :charset-list '(unicode)
  :pre-write-conversion 'utf-32be-dos-pre-write-conversion
  :post-read-conversion 'utf-32be-dos-post-read-conversion)

(define-coding-system 'utf-32be-mac
  "UTF-32 (big endian, no BOM, Mac-style; currently treated as Unix LF)."
  :coding-type 'utf-8
  :mnemonic ?U
  :eol-type 'unix
  :charset-list '(unicode)
  :pre-write-conversion 'utf-32be-mac-pre-write-conversion
  :post-read-conversion 'utf-32be-mac-post-read-conversion)

(define-coding-system 'utf-32le-unix
  "UTF-32 (little endian, no BOM, Unix LF)."
  :coding-type 'utf-8
  :mnemonic ?U
  :eol-type 'unix
  :charset-list '(unicode)
  :pre-write-conversion 'utf-32le-unix-pre-write-conversion
  :post-read-conversion 'utf-32le-unix-post-read-conversion)

(define-coding-system 'utf-32le-dos
  "UTF-32 (little endian, no BOM, DOS CRLF)."
  :coding-type 'utf-8
  :mnemonic ?U
  :eol-type 'dos
  :charset-list '(unicode)
  :pre-write-conversion 'utf-32le-dos-pre-write-conversion
  :post-read-conversion 'utf-32le-dos-post-read-conversion)

(define-coding-system 'utf-32le-mac
  "UTF-32 (little endian, no BOM, Mac-style; currently treated as Unix LF)."
  :coding-type 'utf-8
  :mnemonic ?U
  :eol-type 'unix
  :charset-list '(unicode)
  :pre-write-conversion 'utf-32le-mac-pre-write-conversion
  :post-read-conversion 'utf-32le-mac-post-read-conversion)

(provide 'utf-32)

;;; utf-32.el ends here