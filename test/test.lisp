(in-package #:mfiano.lib.gen.rng/test)

(test xoroshiro64*.state
  (let ((rng (xoroshiro64*:make-rng #x0123456789abcdef)))
    (is (equalp (xoroshiro64*:vector/u32 rng 4)
                #(#xd0433c1d #x9063d494 #x4aa5ea1c #x1ac2f157)))))

(test xoroshiro64**.state
  (let ((rng (xoroshiro64**:make-rng #x0123456789abcdef)))
    (is (equalp (xoroshiro64**:vector/u32 rng 4)
                #(#x2a0592a2 #x3e64dcda #xa7b251ad #xb9d6d66f)))))

(test xoroshiro128+.state
  (let ((rng (xoroshiro128+:make-rng #x0123456789abcdef)))
    (is (equalp (xoroshiro128+:vector/u64 rng 4)
                #(#xeaed8aa2d9317b30 #xb300b6f0786253c8 #x4753ec6d32d7fadf #x371c7ae10fed1d49)))))

(test xoroshiro128+.jump
  (let ((rng (xoroshiro128+:make-rng #x0123456789abcdef)))
    (xoroshiro128+:jump rng)
    (is (equalp (xoroshiro128+:vector/u64 rng 4)
                #(#x29a2d7b03c998d16 #x52856f54184752e1 #xb00f938f3c268a85 #x60afe1892808c8a2)))))

(test xoroshiro128+.jump/long
  (let ((rng (xoroshiro128+:make-rng #x0123456789abcdef)))
    (xoroshiro128+:jump/long rng)
    (is (equalp (xoroshiro128+:vector/u64 rng 4)
                #(#x9cf6bec9b8dd553f #x6a9b1eb12ec1eb55 #x5d362b622fe49871 #x840ba04d606d91d8)))))

(test xoroshiro128++.state
  (let ((rng (xoroshiro128++:make-rng #x0123456789abcdef)))
    (is (equalp (xoroshiro128++:vector/u64 rng 4)
                #(#x2abfea6a9af18078 #x2132616b35565259 #x850378c3b2e42309 #x326df705cc29056d)))))

(test xoroshiro128++.jump
  (let ((rng (xoroshiro128++:make-rng #x0123456789abcdef)))
    (xoroshiro128++:jump rng)
    (is (equalp (xoroshiro128++:vector/u64 rng 4)
                #(#xcc9f12f94907e479 #xcf25af7c6e7a7de2 #x9c7fbdf3273d14d5 #x3d5927bac72021f4)))))

(test xoroshiro128++.jump/long
  (let ((rng (xoroshiro128++:make-rng #x0123456789abcdef)))
    (xoroshiro128++:jump/long rng)
    (is (equalp (xoroshiro128++:vector/u64 rng 4)
                #(#x4a1a5e6cf844ca66 #xd118c5a0ff44380e #xa951af8fe7221595 #x9695a5ecb502e9e5)))))

(test xoroshiro128**.state
  (let ((rng (xoroshiro128**:make-rng #x0123456789abcdef)))
    (is (equalp (xoroshiro128**:vector/u64 rng 4)
                #(#x3decabf6a07ece5d #xd8caa67a2884c0b0 #x75087dad072f611a #x8f38cf79ddca4436)))))

(test xoroshiro128**.jump
  (let ((rng (xoroshiro128**:make-rng #x0123456789abcdef)))
    (xoroshiro128**:jump rng)
    (is (equalp (xoroshiro128**:vector/u64 rng 4)
                #(#x190ce06ca450b4e3 #x277f4ba3278492c2 #xe655afb43767fa74 #x5e73dd33bf0c2537)))))

(test xoroshiro128**.jump/long
  (let ((rng (xoroshiro128**:make-rng #x0123456789abcdef)))
    (xoroshiro128**:jump/long rng)
    (is (equalp (xoroshiro128**:vector/u64 rng 4)
                #(#xebae8853d59a8b0d #xbae07946143962a0 #x3715bbe2df1899ad #x100e082db019b0ce)))))

(test xoroshiro1024++.state
  (let ((rng (xoroshiro1024++:make-rng #x0123456789abcdef)))
    (is (equalp (xoroshiro1024++:vector/u64 rng 4)
                #(#x66e6d0c53d052162 #x1034a327442fe5f5 #xf2c83364e212c161 #x51e71885e6ff3d1d)))))

(test xoroshiro1024++.jump
  (let ((rng (xoroshiro1024++:make-rng #x0123456789abcdef)))
    (xoroshiro1024++:jump rng)
    (is (equalp (xoroshiro1024++:vector/u64 rng 4)
                #(#x9e0366e11548d1bd #x151366e777e38cb8 #x4b62525f1c507149 #x7c572e9a09eca37e)))))

(test xoroshiro1024++.jump/long
  (let ((rng (xoroshiro1024++:make-rng #x0123456789abcdef)))
    (xoroshiro1024++:jump/long rng)
    (is (equalp (xoroshiro1024++:vector/u64 rng 4)
                #(#x7d87ae18eb0ab922 #x9b43a29b75eefd4e #xf2815981d03ee25c #x6ecb68d0dee0e78a)))))

(test xoroshiro1024*.state
  (let ((rng (xoroshiro1024*:make-rng #x0123456789abcdef)))
    (is (equalp (xoroshiro1024*:vector/u64 rng 4)
                #(#xa1a6017d8087aee9 #xb8fec064033e3a1a #xef515734e1c80684 #x216f0832f3466098)))))

(test xoroshiro1024*.jump
  (let ((rng (xoroshiro1024*:make-rng #x0123456789abcdef)))
    (xoroshiro1024*:jump rng)
    (is (equalp (xoroshiro1024*:vector/u64 rng 4)
                #(#x9ac8e3c50d71e63f #x50313734208b5a8a #xfe000f3fd67a9e02 #x21bd6604936728ba)))))

(test xoroshiro1024*.jump/long
  (let ((rng (xoroshiro1024*:make-rng #x0123456789abcdef)))
    (xoroshiro1024*:jump/long rng)
    (is (equalp (xoroshiro1024*:vector/u64 rng 4)
                #(#x6b63b8a9499197a8 #x5fa3f487ba346145 #x98e4af95040c8cea #x297d036b55eb3568)))))

(test xoroshiro1024**.state
  (let ((rng (xoroshiro1024**:make-rng #x0123456789abcdef)))
    (is (equalp (xoroshiro1024**:vector/u64 rng 4)
                #(#xa2c2a42038d4ec3d #x3819987c267eb726 #xa437023430223ecf #x26c27c4ef6c0b41b)))))

(test xoroshiro1024**.jump
  (let ((rng (xoroshiro1024**:make-rng #x0123456789abcdef)))
    (xoroshiro1024**:jump rng)
    (is (equalp (xoroshiro1024**:vector/u64 rng 4)
                #(#x49f3ddd5575780b6 #x59040b863dc87e21 #x424cc4bf928bbf12 #x8a595cbd91a3670b)))))

(test xoroshiro1024**.jump/long
  (let ((rng (xoroshiro1024**:make-rng #x0123456789abcdef)))
    (xoroshiro1024**:jump/long rng)
    (is (equalp (xoroshiro1024**:vector/u64 rng 4)
                #(#xd925454b059b2f0f #x152ed2dfcf0a3f6f #xabe43b9db6f34c7a #xbbfb84c326b44db0)))))

(test xoshiro128+.state
  (let ((rng (xoshiro128+:make-rng #x0123456789abcdef)))
    (is (equalp (xoshiro128+:vector/u32 rng 4)
                #(#xb84e513a #x9d3ab76c #xdc0a6c4e #x9e2f57e9)))))

(test xoshiro128+.jump
  (let ((rng (xoshiro128+:make-rng #x0123456789abcdef)))
    (xoshiro128+:jump rng)
    (is (equalp (xoshiro128+:vector/u32 rng 4)
                #(#x19c85ebe #x0fdd94d3 #x315fb008 #x8cb688f0)))))

(test xoshiro128+.jump/long
  (let ((rng (xoshiro128+:make-rng #x0123456789abcdef)))
    (xoshiro128+:jump/long rng)
    (is (equalp (xoshiro128+:vector/u32 rng 4)
                #(#xdb2b10c4 #xb900092e #x9bcd873a #xf5629b67)))))

(test xoshiro128++.state
  (let ((rng (xoshiro128++:make-rng #x0123456789abcdef)))
    (is (equalp (xoshiro128++:vector/u32 rng 4)
                #(#x3ca2d563 #x003929fd #xbc50150e #xda8e7909)))))

(test xoshiro128++.jump
  (let ((rng (xoshiro128++:make-rng #x0123456789abcdef)))
    (xoshiro128++:jump rng)
    (is (equalp (xoshiro128++:vector/u32 rng 4)
                #(#x05527145 #x58624415 #x579eedae #x30148d9e)))))

(test xoshiro128++.jump/long
  (let ((rng (xoshiro128++:make-rng #x0123456789abcdef)))
    (xoshiro128++:jump/long rng)
    (is (equalp (xoshiro128++:vector/u32 rng 4)
                #(#xb3b607b4 #x25d45aab #x31298d0a #x391610f4)))))

(test xoshiro128**.state
  (let ((rng (xoshiro128**:make-rng #x0123456789abcdef)))
    (is (equalp (xoshiro128**:vector/u32 rng 4)
                #(#xa2c2a03d #x05fc280f #x798a149a #xb6e3956c)))))

(test xoshiro128**.jump
  (let ((rng (xoshiro128**:make-rng #x0123456789abcdef)))
    (xoshiro128**:jump rng)
    (is (equalp (xoshiro128**:vector/u32 rng 4)
                #(#x8a1e66f8 #xce12aca4 #x80298a02 #xf33ad9c0)))))

(test xoshiro128**.jump/long
  (let ((rng (xoshiro128**:make-rng #x0123456789abcdef)))
    (xoshiro128**:jump/long rng)
    (is (equalp (xoshiro128**:vector/u32 rng 4)
                #(#x3aaec919 #x923e78af #xc42f193f #x07e2aa6d)))))

(test xoshiro256+.state
  (let ((rng (xoshiro256+:make-rng #x0123456789abcdef)))
    (is (equalp (xoshiro256+:vector/u64 rng 4)
                #(#xb84e513af0d61289 #x59cd62a4c5dd2cfe #x52e0c41802c78054 #xa03584666d44e729)))))

(test xoshiro256+.jump
  (let ((rng (xoshiro256+:make-rng #x0123456789abcdef)))
    (xoshiro256+:jump rng)
    (is (equalp (xoshiro256+:vector/u64 rng 4)
                #(#x7b1c2f8df2dd51a1 #xdf6ca3c209891b78 #x41cb13dfb254db28 #x0b955d4fcd240afe)))))

(test xoshiro256+.jump/long
  (let ((rng (xoshiro256+:make-rng #x0123456789abcdef)))
    (xoshiro256+:jump/long rng)
    (is (equalp (xoshiro256+:vector/u64 rng 4)
                #(#x64a3283d7d943624 #x7e1df87c0ba14492 #x9937f8ba6899c375 #xdf6824fed336e2e2)))))

(test xoshiro256++.state
  (let ((rng (xoshiro256++:make-rng #x0123456789abcdef)))
    (is (equalp (xoshiro256++:vector/u64 rng 4)
                #(#xb2f2a310e96bd1c5 #xb54062465b950493 #x87aca4a9668814b0 #xf13d2e2448a9cffb)))))

(test xoshiro256++.jump
  (let ((rng (xoshiro256++:make-rng #x0123456789abcdef)))
    (xoshiro256++:jump rng)
    (is (equalp (xoshiro256++:vector/u64 rng 4)
                #(#x6fec1e9555509931 #xa41a1ad2c6c39ff1 #xd1185a07f739d388 #x9f656c8d0d8617f9)))))

(test xoshiro256++.jump/long
  (let ((rng (xoshiro256++:make-rng #x0123456789abcdef)))
    (xoshiro256++:jump/long rng)
    (is (equalp (xoshiro256++:vector/u64 rng 4)
                #(#x1ce12a91fe4a5e56 #xf24fdfd146f55159 #x8a72f26d8e11b993 #x0ec1ec2365ff51fb)))))

(test xoshiro256**.state
  (let ((rng (xoshiro256**:make-rng #x0123456789abcdef)))
    (is (equalp (xoshiro256**:vector/u64 rng 4)
                #(#xa2c2a42038d4ec3d #x05fc25d0738e7b0f #x625e7bff938e701e #x1ba4ddc6fe2b5726)))))

(test xoshiro256**.jump
  (let ((rng (xoshiro256**:make-rng #x0123456789abcdef)))
    (xoshiro256**:jump rng)
    (is (equalp (xoshiro256**:vector/u64 rng 4)
                #(#xa6c7c7bc2f6f5f50 #x012060ba17b45e7c #xc2864a4b5a524de8 #x7566de6c37068e7f)))))

(test xoshiro256**.jump/long
  (let ((rng (xoshiro256**:make-rng #x0123456789abcdef)))
    (xoshiro256**:jump/long rng)
    (is (equalp (xoshiro256**:vector/u64 rng 4)
                #(#x72d1ee527e23c070 #xb377e715a442ec11 #x8818d1b2e64e9438 #x78975225d92927f9)))))

(test xoshiro512+.state
  (let ((rng (xoshiro512+:make-rng #x0123456789abcdef)))
    (is (equalp (xoshiro512+:vector/u64 rng 4)
                #(#x450aef363dfd775b #xe870f24102e18cbb #x3b78990da2f133db #xa0e71e900708f170)))))

(test xoshiro512+.jump
  (let ((rng (xoshiro512+:make-rng #x0123456789abcdef)))
    (xoshiro512+:jump rng)
    (is (equalp (xoshiro512+:vector/u64 rng 4)
                #(#xef0d7784834bc596 #x15911a40fa9cbb33 #xe16ad1430b9db9f2 #x0406d954f43a1526)))))

(test xoshiro512+.jump/long
  (let ((rng (xoshiro512+:make-rng #x0123456789abcdef)))
    (xoshiro512+:jump/long rng)
    (is (equalp (xoshiro512+:vector/u64 rng 4)
                #(#xea550521b1c15ddf #xf4fcfb1f69329b68 #xadaa27be925fe116 #xef71323485a36f17)))))

(test xoshiro512++.state
  (let ((rng (xoshiro512++:make-rng #x0123456789abcdef)))
    (is (equalp (xoshiro512++:vector/u64 rng 4)
                #(#x0dfd3329882456d3 #x1f6c94ec575a3704 #xc988322160d3b7ac #x70874f0233aff569)))))

(test xoshiro512++.jump
  (let ((rng (xoshiro512++:make-rng #x0123456789abcdef)))
    (xoshiro512++:jump rng)
    (is (equalp (xoshiro512++:vector/u64 rng 4)
                #(#xa81ac08e84524efb #xc16bf9b4e9694f76 #xa6d328fa68807560 #x8bfa96af0de5bdf9)))))

(test xoshiro512++.jump/long
  (let ((rng (xoshiro512++:make-rng #x0123456789abcdef)))
    (xoshiro512++:jump/long rng)
    (is (equalp (xoshiro512++:vector/u64 rng 4)
                #(#xa313f65c85a837a3 #xbf93b30365028218 #x327a1eded75ff6aa #x8cbae2c7464fbd78)))))

(test xoshiro512**.state
  (let ((rng (xoshiro512**:make-rng #x0123456789abcdef)))
    (is (equalp (xoshiro512**:vector/u64 rng 4)
                #(#xa2c2a42038d4ec3d #x05fc25d0738e7b0f #x8cdae320589ff91e #x5ef9741cae1d2a1c)))))

(test xoshiro512**.jump
  (let ((rng (xoshiro512**:make-rng #x0123456789abcdef)))
    (xoshiro512**:jump rng)
    (is (equalp (xoshiro512**:vector/u64 rng 4)
                #(#x5efad7e868fde265 #x6da719b6d4fa8db9 #x03b39d8bb00a5ce8 #x5aff32926c103989)))))

(test xoshiro512**.jump/long
  (let ((rng (xoshiro512**:make-rng #x0123456789abcdef)))
    (xoshiro512**:jump/long rng)
    (is (equalp (xoshiro512**:vector/u64 rng 4)
                #(#xbde57c6814ae4814 #x91de16153f539916 #x0439d088676fc9bc #x10aa0e6e65b179c1)))))