;; Emacs 23用UTF-32

;; BOMあり版

(defun utf-32-be-unix-pre-write-conversion (from to)
  (set-buffer-multibyte t)
  (goto-char 0)
  (insert #x0000)
  (insert #xFEFF)
  (while (not (eobp))
    (if (> (following-char) #xFFFF)
        (let* ((c (following-char))
               (hi (lsh (logand c #x1F0000) -16))
               (lo (logand c #xFFFF)))
          (delete-char 1)
          (insert hi)
          (insert lo))
      (progn
        (insert #x0000)
        (forward-char)))))

(defun utf-32-be-unix-post-read-conversion (len)
  (if (zerop (following-char))
      (progn
        (forward-char)
        (if (= (following-char) #xFEFF)
            (progn
              (backward-char)
              (delete-char 2)))))
  (while (not (eobp))
    (let ((hi (following-char))
          lo c)
      (delete-char 1)
      (setq lo (following-char))
      (delete-char 1)
      (setq c (logior (lsh hi 16) lo))
      (insert c)))
  (goto-char 0)
  len)

(defun utf-32-be-dos-pre-write-conversion (from to)
  (set-buffer-multibyte t)
  (goto-char 0)
  (insert #x0000)
  (insert #xFEFF)
  (while (not (eobp))
    (if (eolp)
        (progn
          (insert #x0000)
          (insert #x000D)))
    (if (> (following-char) #xFFFF)
        (let* ((c (following-char))
               (hi (lsh (logand c #x1F0000) -16))
               (lo (logand c #xFFFF)))
          (delete-char 1)
          (insert hi)
          (insert lo))
      (progn
        (insert #x0000)
        (forward-char)))))

(defun utf-32-be-dos-post-read-conversion (len)
  (if (zerop (following-char))
      (progn
        (forward-char)
        (if (= (following-char) #xFEFF)
            (progn
              (backward-char)
              (delete-char 2)))))
  (while (not (eobp))
    (let ((hi (following-char))
          lo c)
      (delete-char 1)
      (setq lo (following-char))
      (delete-char 1)
      (setq c (logior (lsh hi 16) lo))
      (if (/= c #x000D)
          (insert c))))
  (goto-char 0)
  len)

(defun utf-32-le-unix-pre-write-conversion (from to)
  (set-buffer-multibyte t)
  (goto-char 0)
  (insert #xFEFF)
  (insert #x0000)
  (while (not (eobp))
    (if (> (following-char) #xFFFF)
        (let* ((c (following-char))
               (hi (lsh (logand c #x1F0000) -16))
               (lo (logand c #xFFFF)))
          (delete-char 1)
          (insert lo)
          (insert hi))
      (progn
        (forward-char)
        (insert #x0000)))))

(defun utf-32-le-unix-post-read-conversion (len)
  (if (= (following-char) #xFEFF)
      (progn
        (forward-char)
        (if (zerop (following-char))
            (progn
              (backward-char)
              (delete-char 2)))))
  (while (not (eobp))
    (let ((lo (following-char))
          hi c)
      (delete-char 1)
      (setq hi (following-char))
      (delete-char 1)
      (setq c (logior (lsh hi 16) lo))
      (insert c)))
  (goto-char 0)
  len)

(defun utf-32-le-dos-pre-write-conversion (from to)
  (set-buffer-multibyte t)
  (goto-char 0)
  (insert #xFEFF)
  (insert #x0000)
  (while (not (eobp))
    (if (eolp)
        (progn
          (insert #x000D)
          (insert #x0000)))
    (if (> (following-char) #xFFFF)
        (let* ((c (following-char))
               (hi (lsh (logand c #x1F0000) -16))
               (lo (logand c #xFFFF)))
          (delete-char 1)
          (insert lo)
          (insert hi))
      (progn
        (forward-char)
        (insert #x0000)))))

(defun utf-32-le-dos-post-read-conversion (len)
  (if (= (following-char) #xFEFF)
      (progn
        (forward-char)
        (if (zerop (following-char))
            (progn
              (backward-char)
              (delete-char 2)))))
  (while (not (eobp))
    (let ((lo (following-char))
          hi c)
      (delete-char 1)
      (setq hi (following-char))
      (delete-char 1)
      (setq c (logior (lsh hi 16) lo))
      (if (/= c #x000D)
          (insert c))))
  (goto-char 0)
  len)

;; BOMなし版

(defun utf-32be-unix-pre-write-conversion (from to)
  (set-buffer-multibyte t)
  (goto-char 0)
  (while (not (eobp))
    (if (> (following-char) #xFFFF)
        (let* ((c (following-char))
               (hi (lsh (logand c #x1F0000) -16))
               (lo (logand c #xFFFF)))
          (delete-char 1)
          (insert hi)
          (insert lo))
      (progn
        (insert #x0000)
        (forward-char)))))

(defun utf-32be-unix-post-read-conversion (len)
  (while (not (eobp))
    (let ((hi (following-char))
          lo c)
      (delete-char 1)
      (setq lo (following-char))
      (delete-char 1)
      (setq c (logior (lsh hi 16) lo))
      (insert c)))
  (goto-char 0)
  len)

(defun utf-32be-dos-pre-write-conversion (from to)
  (set-buffer-multibyte t)
  (goto-char 0)
  (while (not (eobp))
    (if (eolp)
        (progn
          (insert #x0000)
          (insert #x000D)))
    (if (> (following-char) #xFFFF)
        (let* ((c (following-char))
               (hi (lsh (logand c #x1F0000) -16))
               (lo (logand c #xFFFF)))
          (delete-char 1)
          (insert hi)
          (insert lo))
      (progn
        (insert #x0000)
        (forward-char)))))

(defun utf-32be-dos-post-read-conversion (len)
  (while (not (eobp))
    (let ((hi (following-char))
          lo c)
      (delete-char 1)
      (setq lo (following-char))
      (delete-char 1)
      (setq c (logior (lsh hi 16) lo))
      (if (/= c #x000D)
          (insert c))))
  (goto-char 0)
  len)

(defun utf-32le-unix-pre-write-conversion (from to)
  (set-buffer-multibyte t)
  (goto-char 0)
  (while (not (eobp))
    (if (> (following-char) #xFFFF)
        (let* ((c (following-char))
               (hi (lsh (logand c #x1F0000) -16))
               (lo (logand c #xFFFF)))
          (delete-char 1)
          (insert lo)
          (insert hi))
      (progn
        (forward-char)
        (insert #x0000)))))

(defun utf-32le-unix-post-read-conversion (len)
  (while (not (eobp))
    (let ((lo (following-char))
          hi c)
      (delete-char 1)
      (setq hi (following-char))
      (delete-char 1)
      (setq c (logior (lsh hi 16) lo))
      (insert c)))
  (goto-char 0)
  len)

(defun utf-32le-dos-pre-write-conversion (from to)
  (set-buffer-multibyte t)
  (goto-char 0)
  (while (not (eobp))
    (if (eolp)
        (progn
          (insert #x000D)
          (insert #x0000)))
    (if (> (following-char) #xFFFF)
        (let* ((c (following-char))
               (hi (lsh (logand c #x1F0000) -16))
               (lo (logand c #xFFFF)))
          (delete-char 1)
          (insert lo)
          (insert hi))
      (progn
        (forward-char)
        (insert #x0000)))))

(defun utf-32le-dos-post-read-conversion (len)
  (while (not (eobp))
    (let ((lo (following-char))
          hi c)
      (delete-char 1)
      (setq hi (following-char))
      (delete-char 1)
      (setq c (logior (lsh hi 16) lo))
      (if (/= c #x000D)
          (insert c))))
  (goto-char 0)
  len)

;; BOMあり版

(define-coding-system 'utf-32-be-unix
  "UTF-32 (big endian)"
  :coding-type 'utf-16
  :mnemonic ?U
  :eol-type 'unix
  :charset-list '(unicode)
  :pre-write-conversion 'utf-32-be-unix-pre-write-conversion
  :post-read-conversion 'utf-32-be-unix-post-read-conversion)

(define-coding-system 'utf-32-be-dos
  "UTF-32 (big endian)"
  :coding-type 'utf-16
  :mnemonic ?U
  :eol-type 'unix
  :charset-list '(unicode)
  :pre-write-conversion 'utf-32-be-dos-pre-write-conversion
  :post-read-conversion 'utf-32-be-dos-post-read-conversion)

(define-coding-system 'utf-32-be-mac
  "UTF-32 (big endian)"
  :coding-type 'utf-16
  :mnemonic ?U
  :eol-type 'mac
  :charset-list '(unicode)
  :pre-write-conversion 'utf-32-be-unix-pre-write-conversion
  :post-read-conversion 'utf-32-be-unix-post-read-conversion)

(define-coding-system 'utf-32-le-unix
  "UTF-32 (little endian)"
  :coding-type 'utf-16
  :endian 'little
  :mnemonic ?U
  :eol-type 'unix
  :charset-list '(unicode)
  :pre-write-conversion 'utf-32-le-unix-pre-write-conversion
  :post-read-conversion 'utf-32-le-unix-post-read-conversion)

(define-coding-system 'utf-32-le-dos
  "UTF-32 (little endian)"
  :coding-type 'utf-16
  :endian 'little
  :mnemonic ?U
  :eol-type 'unix
  :charset-list '(unicode)
  :pre-write-conversion 'utf-32-le-dos-pre-write-conversion
  :post-read-conversion 'utf-32-le-dos-post-read-conversion)

(define-coding-system 'utf-32-le-mac
  "UTF-32 (little endian)"
  :coding-type 'utf-16
  :endian 'little
  :mnemonic ?U
  :eol-type 'mac
  :charset-list '(unicode)
  :pre-write-conversion 'utf-32-le-unix-pre-write-conversion
  :post-read-conversion 'utf-32-le-unix-post-read-conversion)

;; BOMなし版

(define-coding-system 'utf-32be-unix
  "UTF-32 (big endian)"
  :coding-type 'utf-16
  :mnemonic ?U
  :eol-type 'unix
  :charset-list '(unicode)
  :pre-write-conversion 'utf-32be-unix-pre-write-conversion
  :post-read-conversion 'utf-32be-unix-post-read-conversion)

(define-coding-system 'utf-32be-dos
  "UTF-32 (big endian)"
  :coding-type 'utf-16
  :mnemonic ?U
  :eol-type 'unix
  :charset-list '(unicode)
  :pre-write-conversion 'utf-32be-dos-pre-write-conversion
  :post-read-conversion 'utf-32be-dos-post-read-conversion)

(define-coding-system 'utf-32be-mac
  "UTF-32 (big endian)"
  :coding-type 'utf-16
  :mnemonic ?U
  :eol-type 'mac
  :charset-list '(unicode)
  :pre-write-conversion 'utf-32be-unix-pre-write-conversion
  :post-read-conversion 'utf-32be-unix-post-read-conversion)

(define-coding-system 'utf-32le-unix
  "UTF-32 (little endian)"
  :coding-type 'utf-16
  :endian 'little
  :mnemonic ?U
  :eol-type 'unix
  :charset-list '(unicode)
  :pre-write-conversion 'utf-32le-unix-pre-write-conversion
  :post-read-conversion 'utf-32le-unix-post-read-conversion)

(define-coding-system 'utf-32le-dos
  "UTF-32 (little endian)"
  :coding-type 'utf-16
  :endian 'little
  :mnemonic ?U
  :eol-type 'unix
  :charset-list '(unicode)
  :pre-write-conversion 'utf-32le-dos-pre-write-conversion
  :post-read-conversion 'utf-32le-dos-post-read-conversion)

(define-coding-system 'utf-32le-mac
  "UTF-32 (little endian)"
  :coding-type 'utf-16
  :endian 'little
  :mnemonic ?U
  :eol-type 'mac
  :charset-list '(unicode)
  :pre-write-conversion 'utf-32le-unix-pre-write-conversion
  :post-read-conversion 'utf-32le-unix-post-read-conversion)

(provide 'utf-32)