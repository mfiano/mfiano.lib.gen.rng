(in-package #:mfiano.lib.base.pkg)

(define-package #:mfiano.lib.gen.rng/test
  (:local-nicknames
   (#:u #:mfiano.lib.base.util)
   (#:xoroshiro64* #:mfiano.lib.gen.rng.xoroshiro64*)
   (#:xoroshiro64** #:mfiano.lib.gen.rng.xoroshiro64**)
   (#:xoroshiro128+ #:mfiano.lib.gen.rng.xoroshiro128+)
   (#:xoroshiro128++ #:mfiano.lib.gen.rng.xoroshiro128++)
   (#:xoroshiro128** #:mfiano.lib.gen.rng.xoroshiro128**)
   (#:xoroshiro1024++ #:mfiano.lib.gen.rng.xoroshiro1024++)
   (#:xoroshiro1024* #:mfiano.lib.gen.rng.xoroshiro1024*)
   (#:xoroshiro1024** #:mfiano.lib.gen.rng.xoroshiro1024**)
   (#:xoshiro128+ #:mfiano.lib.gen.rng.xoshiro128+)
   (#:xoshiro128++ #:mfiano.lib.gen.rng.xoshiro128++)
   (#:xoshiro128** #:mfiano.lib.gen.rng.xoshiro128**)
   (#:xoshiro256+ #:mfiano.lib.gen.rng.xoshiro256+)
   (#:xoshiro256++ #:mfiano.lib.gen.rng.xoshiro256++)
   (#:xoshiro256** #:mfiano.lib.gen.rng.xoshiro256**)
   (#:xoshiro512+ #:mfiano.lib.gen.rng.xoshiro512+)
   (#:xoshiro512++ #:mfiano.lib.gen.rng.xoshiro512++)
   (#:xoshiro512** #:mfiano.lib.gen.rng.xoshiro512**))
  (:use #:cl #:1am))

(in-package #:mfiano.lib.gen.rng/test)

(defparameter *seed* #x0123456789abcdef)

(defparameter *bounds*
  (list 1 2 3 7 10 1000 65535 (ash 1 31) (1+ (ash 1 31)) (1- (ash 1 32)) (ash 1 32)
        (1+ (ash 1 63)) (1- (ash 1 64))))

(defun canon-bounded (draw bound size)
  (multiple-value-bind (result fraction) (floor (* bound (funcall draw)) (ash 1 size))
    (let ((high (ash (* bound (funcall draw)) (- size))))
      (ldb (byte size 0) (+ result (if (>= (+ fraction high) (ash 1 size)) 1 0))))))

(defun bounded-matches-exact-p (make-rng copy bounded draw size)
  (let ((rng (funcall make-rng *seed*)))
    (every (lambda (bound)
             (loop :repeat 1000
                   :always (let ((reference (funcall copy rng)))
                             (= (funcall bounded rng bound)
                                (canon-bounded (lambda () (funcall draw reference)) bound size)))))
           (remove-if (lambda (bound) (>= bound (ash 1 size))) *bounds*))))

(defun shuffle-permutes-p (make-rng shuffle)
  (let ((rng (funcall make-rng *seed*))
        (seen-swap nil))
    (and (loop :repeat 100
               :always (let ((pair (funcall shuffle rng (vector 0 1))))
                         (when (equalp pair #(1 0))
                           (setf seen-swap t))
                         (or (equalp pair #(0 1)) (equalp pair #(1 0)))))
         seen-swap
         (loop :repeat 100
               :always (equalp (sort (funcall shuffle rng (coerce (loop :for i :below 50 :collect i)
                                                                  'vector))
                                     #'<)
                               (coerce (loop :for i :below 50 :collect i) 'vector))))))

(defun copy-continues-stream-p (make-rng copy draw)
  (let ((rng (funcall make-rng *seed*)))
    (loop :repeat 5 :do (funcall draw rng))
    (let ((twin (funcall copy rng)))
      (loop :repeat 32 :always (= (funcall draw rng) (funcall draw twin))))))

(defun wide*-exact-p (size)
  (let ((rng (mfiano.lib.gen.rng.xoshiro256++:make-rng *seed*))
        (edges (list 0 1 2 (1- (ash 1 (1- size))) (ash 1 (1- size)) (1- (ash 1 size)))))
    (flet ((exact-p (x y)
             (multiple-value-bind (low high) (u:wide* x y size)
               (and (= low (ldb (byte size 0) (* x y)))
                    (= high (ash (* x y) (- size)))))))
      (and (every (lambda (x) (every (lambda (y) (exact-p x y)) edges)) edges)
           (loop :repeat 10000
                 :always (exact-p (ldb (byte size 0) (mfiano.lib.gen.rng.xoshiro256++:u64 rng))
                                  (ldb (byte size 0) (mfiano.lib.gen.rng.xoshiro256++:u64 rng))))))))
