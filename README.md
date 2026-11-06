# mfiano.lib.gen.rng : xoshiro / xoroshiro generators

A tiny, copy-friendly set of Common Lisp PRNG implementations based on David Blackman & Sebastiano Vigna's **xoshiro** and **xoroshiro** families.

Design goals:

- **Portable CL** (no implementation-specific tricks).
- **One file per generator**, intentionally self-contained: each variant duplicates the few utilities it needs so you can copy a single file/package anywhere without dragging a framework behind it.
- **Fast, high-quality non-crypto RNGs** for games, simulation, procedural generation, sampling, shuffling, etc.
- **Consistent API** across all variants: same public function names; only the *native word size* differs.

> These generators are **not cryptographically secure**. If you need adversarial unpredictability, use a CSPRNG.

## What's included

This library covers **17 total variants**:

### xoroshiro (state = 2 words, "small state")
These have the smallest state and are excellent general-purpose RNGs.

- `xoroshiro64*` (2x 32-bit words; total state = 64 bits)
- `xoroshiro64**` (2x 32-bit words; total state = 64 bits)
- `xoroshiro128+` (2x 64-bit words; total state = 128 bits)
- `xoroshiro128++` (2x 64-bit words; total state = 128 bits)
- `xoroshiro128**` (2x 64-bit words; total state = 128 bits)

### xoshiro (larger state, "bigger hammer")
These use more state and generally have stronger statistical behavior for heavy-duty use.

- `xoshiro128+` (4x 32-bit words; total state = 128 bits)
- `xoshiro128++` (4x 32-bit words; total state = 128 bits)
- `xoshiro128**` (4x 32-bit words; total state = 128 bits)
- `xoshiro256+` (4x 64-bit words; total state = 256 bits)
- `xoshiro256++` (4x 64-bit words; total state = 256 bits)
- `xoshiro256**` (4x 64-bit words; total state = 256 bits)
- `xoshiro512+` (8x 64-bit words; total state = 512 bits)
- `xoshiro512++` (8x 64-bit words; total state = 512 bits)
- `xoshiro512**` (8x 64-bit words; total state = 512 bits)

### xoroshiro1024 (huge state, extra cursor state)
These are the "huge state" xoroshiro variants and include an additional cursor/index.

- `xoroshiro1024*` (16x 64-bit words + 4-bit cursor; total state = 1024 bits)
- `xoroshiro1024++` (16x 64-bit words + 4-bit cursor; total state = 1024 bits)
- `xoroshiro1024**` (16x 64-bit words + 4-bit cursor; total state = 1024 bits)

Notes:
- These variants carry an extra internal **cursor/index** (the reference C code uses `p`).

## Package layout

Each generator lives in its own single-file package.

Because each file is intended to be copyable as a single unit, you'll see some duplicated "plumbing" utilities in each file (seed mixer, etc.). That duplication is intentional.

## Quick start

### Create a RNG

All variants expose:

- `make-rng`

Example:

```lisp
(defparameter *rng* (mfiano.lib.gen.rng.xoroshiro64**:make-rng #x0123456789abcdef))
```

Seeds are mixed with **SplitMix64**, then truncated/expanded as needed to populate the variant's internal state.

### Pull values

All variants export the same set of basic functions:

* `u8` `u16` `u32` `u64`
* `i8` `i16` `i32` `i64`
* `f32` `f64`
* `boolean`

Example:

```lisp
(let ((rng (mfiano.lib.gen.rng.xoroshiro64**:make-rng #x0123456789abcdef)))
  (values
    (mfiano.lib.gen.rng.xoroshiro64**:u32 rng)
    (mfiano.lib.gen.rng.xoroshiro64**:f64 rng)
    (mfiano.lib.gen.rng.xoroshiro64**:boolean rng)))
```

### Copy a RNG

* `copy` returns a new RNG object with duplicated state.

This is useful for deterministic branching: "save point" behavior in procedural generation.

## Higher-level helpers

All variants also export convenience utilities:

### `bounded`

```lisp
(bounded rng bound) -> unsigned integer
```

Behavior matches `cl:random` in the sense that results are within `[0, bound)`.

### `range`

```lisp
(range rng min max) -> integer
```

Produces values in `[min, max)` by calling `bounded` on `(- max min)`.

Because `bounded` returns an **unsigned word** value and the function adds `min`, `range` is intended for "safe" signed ranges. In practice:

* Keep `(max - min)` within the variant's bounded domain.
* Keep `min`/`max` within your chosen signed domain.

### `element`

```lisp
(element rng sequence) -> element-or-nil
```

Returns a random element from a sequence. Returns `nil` for empty sequences.

### `shuffle`

```lisp
(shuffle rng sequence) -> sequence
```

In-place Fisher-Yates-style shuffle (on any `elt`-able sequence).

## Floating-point generation (important detail)

The reference xoshiro/xoroshiro implementations treat **low bits as weaker**, and this library follows that philosophy:

* `f32` uses **high bits only** (effectively "shift right then scale").
* `f64` uses **high 53 bits** and scales by `2^-53`.

For 32-bit-word generators that need to synthesize 64-bit or 53-bit quantities, the implementation combines multiple `next` samples using **high-bit extraction** before packing.

This is deliberate: for these families, if you need "good random bits", prefer the high bits.

## Jumping ahead

All variants export:

* `jump`
* `jump/long`

Conceptually:

* `jump` advances the sequence of pseudo-random words by `2^k` (`k` depends on the variant).
* `jump/long` advances even farther.

Why you'd use this:

* Deterministic parallel streams (one stream per thread/job)
* Chunk-based procedural generation (one stream per region)
* Reproducible simulation partitions

## Choosing a variant (practical guidance)

If you don't want to think too hard:

* **Default "small-state, great performance":** `xoroshiro128**` or `xoroshiro128++`
* **Default "bigger state, extra safety margin":** `xoshiro256**` or `xoshiro256++`
* **Need lots of independent streams with huge state:** `xoroshiro1024**` / `xoshiro512**`
* **Tiny 32-bit-word generator:** `xoroshiro64**` (simple, fast)

Rules of thumb:

* Prefer `++` / `**` output scramblers when available if you care about "nice" output quality.
* Prefer larger-state variants for extremely heavy simulation or when you want more statistical margin.
* Prefer the small xoroshiro variants for compact state and speed.

## Determinism and reproducibility

Given:

* same seed,
* same variant,
* same sequence of calls,

you'll get identical output sequences across runs.

The library deliberately keeps each variant's behavior "local": no global PRNG state, and no implicit reseeding.

## API reference (common to all variants)

All variants export the following symbols:

### Construction / state

* `rng` (type / struct)
* `make-rng (seed)`
* `copy (rng)`

### Core sampling

* `boolean (rng) -> boolean`
* `u8 u16 u32 u64 (rng) -> unsigned`
* `i8 i16 i32 i64 (rng) -> signed`
* `f32 (rng) -> single-float`
* `f64 (rng) -> double-float`

### Containers

* `vector/u8 vector/u16 vector/u32 vector/u64`
* `vector/i8 vector/i16 vector/i32 vector/i64`
* `vector/f32 vector/f64`

### Helpers

* `bounded (rng bound) -> unsigned`
* `range (rng min max) -> signed`
* `element (rng sequence) -> element-or-nil`
* `shuffle (rng sequence) -> sequence`

### Jumping

* `jump (rng) -> (values)`
* `jump/long (rng) -> (values)`

## Example: xoroshiro64** usage

```lisp
(defpackage #:demo
  (:use #:cl)
  (:local-nicknames (#:r #:mfiano.lib.gen.rng.xoroshiro64**)))

(in-package #:demo)

(let* ((rng (r:make-rng #x0123456789abcdef))
       (dice (r:range rng 1 7))
       (picked (r:element rng #(a b c d e)))
       (noise (r:f64 rng)))
  (list dice picked noise))
```

## Implementation notes (for readers poking at the code)

* **SplitMix64** is used to expand a single 64-bit seed into the internal state words.
* 32-bit word variants typically use the **high bits** of **SplitMix64** output to initialize state words.
* The `u64` and `f64` helpers in 32-bit word variants may consume multiple `next` calls to synthesize wider values while avoiding weak low bits.
* Everything is written to be friendly to inlining and "just copy this file into your project".

## What this library is *not*

* Not a cryptographic RNG.
* Not a giant RNG framework with registries and pluggable backends.
* Not a promise that every statistical test battery will always be happy forever.

It's a practical toolkit: fast deterministic generators with a predictable API, designed to be easy to embed.

## License and attribution

Licensed under the MIT License.

The algorithms are based on the xoshiro/xoroshiro family designed by David Blackman and Sebastiano Vigna.
