(in-package #:mfiano.lib.base.pkg)

(define-package #:mfiano.lib.gen.rng.xoroshiro128++
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

(in-package #:mfiano.lib.gen.rng.xoroshiro128++)

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
         (next ,rng)))
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

;;; Generator (xoroshiro128++)

(declaim (inline %make-rng))
(defstruct (rng
            (:constructor %make-rng (state))
            (:conc-name nil)
            (:predicate nil)
            (:copier nil))
  (state (make-u64-array 2) :type (u64-array 2)))

(define-ftype make-rng (u:u64) rng)
(defun make-rng (seed)
  (let ((vector (make-u64-array 2)))
    (fill-vector (make-seed-mixer seed) vector #'mix-seed)
    (%make-rng vector)))

(define-ftype copy (rng) rng)
(defun copy (rng)
  (%make-rng (copy-seq (state rng))))

(define-ftype next (rng) u:u64)
(declaim (inline next))
(defun next (rng)
  (let* ((state (state rng))
         (s0 (aref state 0))
         (s1 (aref state 1))
         (result (u64+ (u64-rotl (u64+ s0 s1) 17) s0)))
    (logxorf s1 s0)
    (setf (aref state 0) (logxor (u64-rotl s0 49) s1 (u64-shl s1 21))
          (aref state 1) (u64-rotl s1 28))
    result))

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
    (dotimes (i (- length 2))
      (rotatef (elt sequence i) (elt sequence (range rng i length))))
    sequence))

(define-ftype jump (rng) (values))
(defun jump (rng)
  (declare (optimize (speed 3)))
  (%jump rng #(#x2bd7a6a6e99c2ddc #x0992ccaf6a6fca05)))

(define-ftype jump/long (rng) (values))
(defun jump/long (rng)
  (declare (optimize (speed 3)))
  (%jump rng #(#x360fd5f2cf8d5d99 #x9c6e6877736c46e3)))
