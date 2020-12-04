# CAtomics [![Build Status](https://travis-ci.org/glessard/CAtomics.svg?branch=main)](https://travis-ci.org/glessard/CAtomics)
Some atomic functions made available to Swift 3.1 and up, thanks to Clang

This project bridges a subset of Clang's C11 atomics support to Swift, in a manner compatible with [SE-0282](https://github.com/apple/swift-evolution/blob/main/proposals/0282-atomics.md). This package has been the underlying guts of the long-standing (but now deprecated) [SwiftAtomics](https://github.com/glessard/swift-atomics) package since 2017.

### Module CAtomics

`CAtomics` provides atomic operations to Swift using a C-style interface.
`CAtomics` implements the following types:
- `AtomicRawPointer`, `AtomicMutableRawPointer`, `AtomicOpaquePointer`, and versions for `Optional` pointers (`AtomicOptionalRawPointer`, etc.);
- `AtomicInt` and `AtomicUInt`, as well as signed and unsigned versions of the 8-bit, 16-bit, 32-bit and 64-bit integer types;
- `AtomicBool`

Functions defined in `CAtomics` are prefixed with `CAtomics`. All types define `CAtomicsLoad`, `CAtomicsStore`, `CAtomicsExchange`, `CAtomicsCompareAndExchangeWeak` and `CAtomicsCompareAndExchangeStrong`. Additionally, the integer types define `CAtomicsAdd`, `CAtomicsSubtract`, `CAtomicsBitwiseAnd`, `CAtomicsBitwiseOr` and `CAtomicsBitwiseXor`. Finally, `AtomicBool` defines `CAtomicsAnd`, `CAtomicsOr`, and `CAtomicsXor`.

The memory ordering (from `<stdatomic.h>`) can be set by using the `order: MemoryOrder` parameter on each method.
```swift
public enum MemoryOrder : UInt32 {
  case relaxed, acquire, release, acqrel, sequential
}
```

Note that `memory_order_consume` has no equivalent in this module, as (as far as I can tell) clang silently upgrades that ordering to `memory_order_acquire`, making it impossible (at the moment) to test whether an algorithm can properly use `memory_order_consume`. This also means nothing is lost by its absence.

#### Notes on atomics and the law-of-exclusivity:

Atomic types are useful as synchronization points between threads, and therefore have an interesting relationship with Swift's exclusivity checking. They should be initialized at fixed memory locations, such as members of reference types, captured by closures, or in heap allocations. This being said, although the first two work as expected with current Swift, only the latter (heap allocations) is compatible with the thread sanitizer.

In order to use atomics in a way that is acceptable to the thread sanitizer, one must allocate memory for atomic variables using `UnsafeMutablePointer`. Then, pass that pointer to the functions defined in the `CAtomics` module, as needed.

```swift
import CAtomics

class Example {
  private var counter = UnsafeMutablePointer<AtomicInt>.allocate(capacity: 1)
  init() {
    CAtomicsInitialize(counter, 0)
  }

  deinit {
    counter.deallocate()
  }

  func increment(by value: Int = 1) {
    CAtomicsAdd(counter, value, .relaxed)
  }
}
```

#### Requirements

This library requires Swift 3.1 or later. On Linux, it also requires Clang 3.6 or later.
