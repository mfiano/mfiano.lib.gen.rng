(asdf:defsystem #:mfiano.lib.gen.rng
  :description "Implementation of the Xoshiro/Xoroshiro family of PRNGs"
  :author "Michael Fiano <michael.fiano@gmail.com>"
  :license "MIT"
  :homepage "https://github.com/mfiano/mfiano.lib.gen.rng"
  :encoding :utf-8
  :depends-on
  (#:mfiano.lib.base)
  :in-order-to ((test-op (test-op #:mfiano.lib.gen.rng/test)))
  :pathname "src"
  :serial t
  :components
  ((:file "xoroshiro64star")
   (:file "xoroshiro64starstar")
   (:file "xoroshiro128plus")
   (:file "xoroshiro128plusplus")
   (:file "xoroshiro128starstar")
   (:file "xoroshiro1024plusplus")
   (:file "xoroshiro1024star")
   (:file "xoroshiro1024starstar")
   (:file "xoshiro128plus")
   (:file "xoshiro128plusplus")
   (:file "xoshiro128starstar")
   (:file "xoshiro256plus")
   (:file "xoshiro256plusplus")
   (:file "xoshiro256starstar")
   (:file "xoshiro512plus")
   (:file "xoshiro512plusplus")
   (:file "xoshiro512starstar")))

(asdf:defsystem #:mfiano.lib.gen.rng/test
  :description "Unit tests for mfiano.lib.gen.rng"
  :author "Michael Fiano <michael.fiano@gmail.com>"
  :license "MIT"
  :homepage "https://github.com/mfiano/mfiano.lib.gen.rng"
  :encoding :utf-8
  :depends-on
  (#:1am
   #:mfiano.lib.gen.rng)
  :perform (test-op (o c) (symbol-call '#:1am '#:run))
  :pathname "test"
  :serial t
  :components
  ((:file "test")))
