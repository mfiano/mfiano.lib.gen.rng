(in-package #:mfiano.lib.base.pkg)

(define-package #:mfiano.lib.gen.rng.xoroshiro1024++
  (:local-nicknames
   (#:u #:mfiano.lib.base.util))
  (:shadow
   #:boolean
   #:f32
   #:f64
   #:i8
   #:i16
   #:i32
   #:i64
   #:shuffle
   #:u8
   #:u16
   #:u32
   #:u64)
  (:use #:mfiano.lib.base.util)
  (:export
   #:boolean
   #:bounded
   #:copy
   #:element
   #:f32
   #:f64
   #:i8
   #:i16
   #:i32
   #:i64
   #:jump
   #:jump/long
   #:make-rng
   #:range
   #:rng
   #:shuffle
   #:u8
   #:u16
   #:u32
   #:u64
   #:vector/f32
   #:vector/f64
   #:vector/i8
   #:vector/i16
   #:vector/i32
   #:vector/i64
   #:vector/u8
   #:vector/u16
   #:vector/u32
   #:vector/u64))

(in-package #:mfiano.lib.gen.rng.xoroshiro1024++)

;;; Utilities

(declaim (inline fill-vector))
(defun fill-vector (rng vector func)
  (dotimes (i (length vector))
    (setf (aref vector i) (funcall func rng)))
  vector)

(defmacro %jump (rng jump-state)
  `(let ((state (state ,rng))
         (new-state (make-u64-array ,(length jump-state))))
     (declare (dynamic-extent new-state))
     (do-each (x ,jump-state)
       (dotimes (bit 64)
         (when (logbitp bit x)
           (map-into new-state #'logxor new-state state))
         (next ,rng)
         (let ((temp (aref new-state 15)))
           (dotimes (shift-index 15)
             (setf (aref new-state (- 15 shift-index)) (aref new-state (- 14 shift-index))))
           (setf (aref new-state 0) temp))))
     (replace state new-state)
     (values)))

;;; Seed mixer (splitmix64)

(declaim (inline make-seed-mixer))
(defstruct (seed-mixer
            (:constructor make-seed-mixer (seed-mixer-state))
            (:conc-name nil)
            (:predicate nil)
            (:copier nil))
  (seed-mixer-state 0 :type u:u64))

(define-ftype mix-seed (seed-mixer) u:u64)
(declaim (inline mix-seed))
(defun mix-seed (seed-mixer)
  (let* ((x (u64-incf (seed-mixer-state seed-mixer) #x9e3779b97f4a7c15))
         (x (u64* (logxor x (shr x 30)) #xbf58476d1ce4e5b9))
         (x (u64* (logxor x (shr x 27)) #x94d049bb133111eb)))
    (logxor x (shr x 31))))

;;; Generator (xoroshiro1024++)

(declaim (inline %make-rng))
(defstruct (rng
            (:constructor %make-rng (state))
            (:conc-name nil)
            (:predicate nil)
            (:copier nil))
  (state (make-u64-array 16) :type (u64-array 16))
  (cursor 0 :type (integer 0 15)))

(define-ftype make-rng (u:u64) rng)
(defun make-rng (seed)
  (let ((vector (make-u64-array 16)))
    (fill-vector (make-seed-mixer seed) vector #'mix-seed)
    (%make-rng vector)))

(define-ftype copy (rng) rng)
(defun copy (rng)
  (let ((copy (%make-rng (copy-seq (state rng)))))
    (setf (cursor copy) (cursor rng))
    copy))

(define-ftype next (rng) u:u64)
(declaim (inline next))
(defun next (rng)
  (let* ((state (state rng))
         (old-cursor (cursor rng))
         (cursor (logand (1+ old-cursor) 15)))
    (setf (cursor rng) cursor)
    (let* ((s0 (aref state cursor))
           (s15 (aref state old-cursor))
           (result (u64+ (u64-rotl (u64+ s0 s15) 23) s15)))
      (logxorf s15 s0)
      (setf (aref state old-cursor) (logxor (u64-rotl s0 25) s15 (u64-shl s15 27))
            (aref state cursor) (u64-rotl s15 36))
      result)))

(define-ftype bounded (rng u:u64) u:u64)
(declaim (inline bounded))
(defun bounded (rng bound)
  (flet ((carry-bit (x y)
           (if (< (u64+ x y) (max x y)) 1 0)))
    (declare (inline carry-bit))
    (multiple-value-bind (fraction result) (wide* bound (next rng) 64)
      (multiple-value-bind (low high) (wide* bound (next rng) 64)
        (u64+ result (carry-bit fraction (logior high (shr low 64))))))))

(define-ftype boolean (rng) cl:boolean)
(declaim (inline boolean))
(defun boolean (rng)
  (declare (optimize (speed 3)))
  (= (ldb (byte 1 63) (next rng)) 1))

(define-ftype u8 (rng) u:u8)
(declaim (inline u8))
(defun u8 (rng)
  (declare (optimize (speed 3)))
  (ldb (byte 8 56) (next rng)))

(define-ftype i8 (rng) u:i8)
(declaim (inline i8))
(defun i8 (rng)
  (declare (optimize (speed 3)))
  (u8->i8 (u8 rng)))

(define-ftype u16 (rng) u:u16)
(declaim (inline u16))
(defun u16 (rng)
  (declare (optimize (speed 3)))
  (ldb (byte 16 48) (next rng)))

(define-ftype i16 (rng) u:i16)
(declaim (inline i16))
(defun i16 (rng)
  (declare (optimize (speed 3)))
  (u16->i16 (u16 rng)))

(define-ftype u32 (rng) u:u32)
(declaim (inline u32))
(defun u32 (rng)
  (declare (optimize (speed 3)))
  (ldb (byte 32 32) (next rng)))

(define-ftype i32 (rng) u:i32)
(declaim (inline i32))
(defun i32 (rng)
  (declare (optimize (speed 3)))
  (u32->i32 (u32 rng)))

(define-ftype u64 (rng) u:u64)
(declaim (inline u64))
(defun u64 (rng)
  (next rng))

(define-ftype i64 (rng) u:i64)
(declaim (inline i64))
(defun i64 (rng)
  (u64->i64 (u64 rng)))

(define-ftype f32 (rng) u:f32)
(declaim (inline f32))
(defun f32 (rng)
  (declare (optimize (speed 3)))
  (* (shr (ldb (byte 32 32) (next rng)) 8) #.(expt 2f0 -24)))

(define-ftype f64 (rng) u:f64)
(declaim (inline f64))
(defun f64 (rng)
  (* (shr (next rng) 11) #.(expt 2d0 -53)))

(define-ftype vector/u8 (rng array-size) (u8-array (*)))
(defun vector/u8 (rng length)
  (declare (optimize (speed 3)))
  (fill-vector rng (make-u8-array length) #'u8))

(define-ftype vector/i8 (rng array-size) (i8-array (*)))
(defun vector/i8 (rng length)
  (declare (optimize (speed 3)))
  (fill-vector rng (make-i8-array length) #'i8))

(define-ftype vector/u16 (rng array-size) (u16-array (*)))
(defun vector/u16 (rng length)
  (declare (optimize (speed 3)))
  (fill-vector rng (make-u16-array length) #'u16))

(define-ftype vector/i16 (rng array-size) (i16-array (*)))
(defun vector/i16 (rng length)
  (declare (optimize (speed 3)))
  (fill-vector rng (make-i16-array length) #'i16))

(define-ftype vector/u32 (rng array-size) (u32-array (*)))
(defun vector/u32 (rng length)
  (declare (optimize (speed 3)))
  (fill-vector rng (make-u32-array length) #'u32))

(define-ftype vector/i32 (rng array-size) (i32-array (*)))
(defun vector/i32 (rng length)
  (declare (optimize (speed 3)))
  (fill-vector rng (make-i32-array length) #'i32))

(define-ftype vector/u64 (rng array-size) (u64-array (*)))
(defun vector/u64 (rng length)
  (declare (optimize (speed 3)))
  (fill-vector rng (make-u64-array length) #'u64))

(define-ftype vector/i64 (rng array-size) (i64-array (*)))
(defun vector/i64 (rng length)
  (declare (optimize (speed 3)))
  (fill-vector rng (make-i64-array length) #'i64))

(define-ftype vector/f32 (rng array-size) (f32-array (*)))
(defun vector/f32 (rng length)
  (declare (optimize (speed 3)))
  (fill-vector rng (make-f32-array length) #'f32))

(define-ftype vector/f64 (rng array-size) (f64-array (*)))
(defun vector/f64 (rng length)
  (declare (optimize (speed 3)))
  (fill-vector rng (make-f64-array length) #'f64))

(define-ftype range (rng u:i64 u:i64) u:i64)
(defun range (rng min max)
  (assert (< min max))
  (+ min (bounded rng (- max min))))

(define-ftype element (rng sequence) t)
(defun element (rng sequence)
  (let ((length (length sequence)))
    (check-type length u:u64)
    (when (plusp length)
      (elt sequence (bounded rng length)))))

(define-ftype shuffle (rng sequence) sequence)
(defun shuffle (rng sequence)
  (let ((length (length sequence)))
    (check-type length u:i64)
    (dotimes (i (1- length))
      (rotatef (elt sequence i) (elt sequence (range rng i length))))
    sequence))

(define-ftype jump (rng) (values))
(defun jump (rng)
  (declare (optimize (speed 3)))
  (%jump rng #(#x931197d8e3177f17 #xb59422e0b9138c5f #xf06a6afb49d668bb #xacb8a6412c8a1401
               #x12304ec85f0b3468 #xb7dfe7079209891e #x405b7eec77d9eb14 #x34ead68280c44e4a
               #xe0e4ba3e0ac9e366 #x8f46eda8348905b7 #x328bf4dbad90d6ff #xc8fd6fb31c9effc3
               #xe899d452d4b67652 #x45f387286ade3205 #x03864f454a8920bd #xa68fa28725b1b384)))

(define-ftype jump/long (rng) (values))
(defun jump/long (rng)
  (declare (optimize (speed 3)))
  (%jump rng #(#x7374156360bbf00f #x4630c2efa3b3c1f6 #x6654183a892786b1 #x94f7bfcbfb0f1661
               #x27d8243d3d13eb2d #x9701730f3dfb300f #x2f293baae6f604ad #xa661831cb60cd8b6
               #x68280c77d9fe008c #x50554160f5ba9459 #x2fc20b17ec7b2a9a #x49189bbdc8ec9f8f
               #x92a65bca41852cc1 #xf46820dd0509c12a #x52b00c35fbf92185 #x1e5b3b7f589e03c1)))
