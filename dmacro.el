;; -*- coding: utf-8-unix; lexical-binding: t; -*-
;;
;;      dmacro.el - Key input repetition and execution
;;
;;	Version 2.0
;;
;;      1993 4/14        original idea by Toshiyuki Masui @ Sharp
;;                         implemented by Makoto Oowata @ Nagaoka Univ. of Tech.
;;                          refinement by Toshiyuki Masui @ Sharp
;;	1995 3/30 modified for Emacs19 by Toshiyuki Masui @ Sharp
;;
;;	2002 3    XEmacs Compatibility by Eiji Obata obata@suzuki.kuee.kyoto-u.ac.jp
;;                                        Nobuyuki Mine zah07175@rose.zero.ad.jp
;;      2016 2/16      English version by Hideki Saito hideki@hidekisaito.com
;;              Modification for HELPA by Hideki Saito hideki@hidekisaito.com
;;
;;

;;
;; dmacro.el predicts user's repeated input to predict
;; the following input. *dmacro-key* defines "repeat key"
;; which predicts detection and execution of the repeated
;; commands.
;; 
;; For instance if the user type:
;;     abcabc
;; and then press the "repeat key" and dmacro.el detects
;; the repeated input of "abc" and then the resulting
;; text will show:
;;     abcabcabc
;; Another example, if the user type:
;;     abcdefab
;; and then press the "repeat key" then dmacro.el determines
;; this as a repetition of "abcdef" which completes the
;; rest of the string, making the resulting text:
;;     abcdefabcdef
;; Pressing the "repeat key" will cause the text will repeat
;; "abcdef" making the resulting text:
;;     abcdefabcdefabcdef
;;
;; All key inputs are considered and executed for example,
;; given:
;;     line1
;;     line2
;;     line3
;;     line4
;; and then changing the above to:
;;     % line1
;;     % line2
;;     line3
;;     line4
;; and pressing "repeat key" will update the text:
;;     % line1
;;     % line2
;;     % line3
;;     line4
;; As you can see above, it will add "%" every time the
;; "repeat key" is pressed.
;; 
;; You can think of this as if the keyboard macro is
;; determined automatically by recognizing repeat pattern.
;; Normally the keyboard macro requires user to specifically
;; define them prior to their execution, but dmacro.el
;; can execute such command even after the user realizes
;; that he/she wants to repeats the previous input. Also
;; the method of defining macro is simplified compared to
;; the keyboard macro, which the user has to define
;; begin/end of the macro.
;;  
;; * Use examples
;;  
;; - String replace
;;
;; We'll think of an example where you want to replace
;; "abc" to "def." Typical key input for searching
;; "abc" is "Ctrl-S a b c ESC" and it can be replaced to
;; "DEL DEL DEL d e f" to replace it to "def."
;; By pressing "repeat key" after the input of
;; "Ctrl-S a b c ESC" the user can press the "repeat key"
;; resulting "DEL DEL DEL d e f" is predicted to replace
;; next "abc" with "def" as a result. Continuing to press the
;; "repeat key" will change the next "abc" into "def" as well.
;; Like the example above, "repeat key" can be used to
;; sequentially replace strings one after another.
;; 
;; * Drawing using lines
;; 
;; Repeating pattern can be drawn easily, for example:、
;;   ─┐┌┐┌┐┌┐┌┐┌┐┌┐┌┐┌┐┌┐┌┐┌┐┌┐┌┐
;;     └┘└┘└┘└┘└┘└┘└┘└┘└┘└┘└┘└┘└┘
;; You can use scripts like keisen.el and draw:
;;   ─┐┌┐
;;     └┘
;; press the "repeat key" will make it:
;;   ─┐┌┐
;;     └┘└┘
;; and pressing "repeat key" will update it:
;;   ─┐┌┐┌┐
;;     └┘└┘└┘
;; Another example:
;;  ┌─┐┌─┐┌─┐┌─┐┌─┐┌─┐┌─┐┌─┐
;;  └─┘└─┘└─┘└─┘└─┘└─┘└─┘└─┘
;; the drawing above can be created by just having the following:
;;  ┌─┐  ─
;;  └─┘
;; then pressing the "repeat key" as needed.。
;;  
;; * Method of predicting repetition
;;  
;; There are many way to predict inputs, but dmacro.el prioritize
;; this as the following:
;; 
;;  (1) If there is a pattern that repeats twice immediately prior to the
;;      input of the "repeat key" then prioritize that. If there are multiple
;;      patterns that are repeating, prioritize the longer one.
;; 
;;      For the input of "teetee" it is possible to interpret this as repetition of
;;      "tee" or "ee" but in this case, it uses "tee" as a repetition. 
;;  (2) Without meeting the condition (1) previous input
;;      <s> is a part of the previous string, such as
;;      <s> <t> <s> then it will predict <t> first, then
;;      <s> <t>. At this time, it prioritize the longest
;;      <s> then the shortest <t> within. 
;;
;;      For example "abracadabra" the longest one is <s>="abra" the prediction will be
;;      <s> <t>="cadabra" as a prioritized detection.
;;
;; * XEmacs compatibility, Super, Hyper, Alt key compatibility
;;
;; This version supports XEmacs。
;; Currently, it is tested with GNu Emacs 18, 19, 20, 21 XEmacs 21.
;; Previous dmacro did not support Super, Hyper, Alt keys but this version supports
;; these keys.
;; It is possible to set *dmacro-key* to Super, Hyper, Alt, Meta
;; but the following should be noted:
;;
;; * *dmacro-key* designation
;; For GNU Emacs
;;   For using Control as Modifier key only, it is possible to specify "\C-t" as
;;   a string. But [?\M-t], [?\s-t], [?\H-t], [?\A-t] should be used for
;;   Meta, Super, hyper, Alt respectively.
;;
;; For XEmacs
;;   The limitation does not above does not apply. It is possible to specify
;;   keys, for example [(super t)] for Super key.
;;
;; * Configuration
;;
;;  Define the following in initialization scripts like .emacs.
;;
;; (defconst *dmacro-key* "\C-t" "Repeat Key")
;; (global-set-key *dmacro-key* 'dmacro-exec)
;; (autoload 'dmacro-exec "dmacro" nil t)
;;
;; Contact information for Original:
;; Toshiyuki Masui
;; Sharp Corporation Software Lab.
;; masui@shpcsl.sharp.co.jp
;;
;; Contact information as of June 3rd, 2002
;; Toshiyuki Masui
;; Sony Computer Science Laboratories, Inc. 
;; masui@acm.org
;;

(defvar dmacro-array-type
  (if (and (boundp 'emacs-major-version)
	   (>= emacs-major-version 19))
      'vector 'string)
  "Type of the array processed internally by dmacro.
Use vector for > emacs 19.
With string, it does not handle hyper, super, alt
correctly.
Vector should be fine with GNU Emacs 18 (Nemacs)")

(fset 'dmacro-concat
      (cond ((eq dmacro-array-type 'string) 'concat)
	    ((eq dmacro-array-type 'vector) 'vconcat)))
	    
(fset 'dmacro-subseq
      (cond ((featurep 'xemacs) 'subseq)
            ((and (eq dmacro-array-type 'vector)
                  (boundp 'emacs-major-version)
                  (eq emacs-major-version 19))
             (require 'cl)
             'subseq)
            (t 'substring)))
 
(defvar *dmacro-arry* nil "Repeat Key")
(defvar *dmacro-arry-1* nil "Partial Array for the Repeat Key")

(setq dmacro-key
      (cond ((eq dmacro-array-type 'string)
             *dmacro-key*)
            (t
             (let ((key *dmacro-key*))
               (cond ((featurep 'xemacs)
                      (if (arrayp key)
                          (mapvector 'character-to-event key)
                        (vector (character-to-event key))))
                     (t
                      (vconcat key)))))))

(setq dmacro-keys (dmacro-concat dmacro-key dmacro-key))

;;;###autoload
(defun dmacro-exec ()
  "Detect key repetition and execute it."
  (interactive)
  (let ((s (dmacro-get)))
    (if (null s)
	(message "Cannot find input repetition.")
      (execute-kbd-macro s)
      )
    ))

(defun dmacro-event (e)
  (cond
   ((integerp e) e)
   ((eq e 'backspace) 8)
   ((eq e 'tab) 9)
   ((eq e 'enter) 13)
   ((eq e 'return) 13)
   ((eq e 'escape) 27)
   ((eq e 'delete) 127)
   (t 0)
   ))

(defun dmacro-recent-keys ()
  (cond ((eq dmacro-array-type 'vector) (recent-keys))
	((eq dmacro-array-type 'string)
	 (let ((s (recent-keys)) )
	   (if (stringp s) s
	     (concat (mapcar 'dmacro-event s))
	     )))))

(defun dmacro-get ()
  (let ((rkeys (dmacro-recent-keys)) arry)
    (if (if (featurep 'xemacs)
            (let ((keys (vconcat dmacro-key
                                 (or *dmacro-arry-1* *dmacro-arry*)
                                 dmacro-key)))
              (equal keys
                     (subseq rkeys (- (length keys)))))
          (equal dmacro-keys (dmacro-subseq rkeys (- (length dmacro-keys)))))
        (progn
          (setq *dmacro-arry-1* nil)
          *dmacro-arry*)
      (setq arry (dmacro-search (dmacro-subseq rkeys 0 (- (length dmacro-key)))))
      (if (null arry)
          (setq *dmacro-arry* nil)
        (let ((s1 (car arry)) (s2 (cdr arry)))
          (setq *dmacro-arry* (dmacro-concat s2 s1)
                *dmacro-arry-1* (if (equal s1 "") nil s1))
          (setq last-kbd-macro *dmacro-arry*)
          (if (equal s1 "") *dmacro-arry* s1))
        ))))

(defun dmacro-search (array)
  (let* ((arry (dmacro-array-reverse array))
         (sptr  1)
         (dptr0 (dmacro-array-search (dmacro-subseq arry 0 sptr) arry sptr))
         (dptr dptr0)
         maxptr)
    (while (and dptr0
                (not (dmacro-array-search dmacro-key (dmacro-subseq arry sptr dptr0))))
      (if (= dptr0 sptr)
          (setq maxptr sptr))
      (setq sptr (1+ sptr))
      (setq dptr dptr0)
      (setq dptr0 (dmacro-array-search (dmacro-subseq arry 0 sptr) arry sptr))
      )
    (if (null maxptr)
        (let ((predict-arry (dmacro-array-reverse (dmacro-subseq arry (1- sptr) dptr))))
          (if (dmacro-array-search dmacro-key predict-arry)
              nil
            (cons predict-arry (dmacro-array-reverse (dmacro-subseq arry 0 (1- sptr)))))
          )
      (cons "" (dmacro-array-reverse (dmacro-subseq arry 0 maxptr)))
      )
    ))

(defun dmacro-array-reverse (arry)
  (dmacro-concat (reverse (mapcar 'identity arry))))

(defun dmacro-array-search (pat arry &optional start)
  (let* ((len (length pat))
	 (max (- (length arry) len))
	 p found
	 )
    (setq p (if start start 0))
    (while (and (not found) (<= p max))
      (setq found (equal pat (dmacro-subseq arry p (+ p len))))
      (if (not found) (setq p (1+ p)))
      )
    (if found p nil)
    ))

