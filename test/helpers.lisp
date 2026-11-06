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