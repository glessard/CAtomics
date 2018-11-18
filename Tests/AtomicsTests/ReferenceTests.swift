//
//  ReferenceTests.swift
//  AtomicsTests
//
//  Created by Guillaume Lessard on 10/9/18.
//  Copyright © 2018 Guillaume Lessard. All rights reserved.
//

import XCTest
import Dispatch

import Atomics

private struct Point { var x = 0.0, y = 0.0, z = 0.0 }

private class Thing
{
  let id: UInt
  init(_ x: UInt = UInt.randomPositive()) { id = x }
}

private class Witness: Thing
{
  override init(_ x: UInt) { super.init(x) }
  deinit { print("Released     \(id)") }
}

public class ReferenceTests: XCTestCase
{
  public func testUnmanaged()
  {
    var i = UInt.randomPositive()
    var a = AtomicReference(Witness(i))
    do {
      let r1 = a.swap(.none)
      print("Will release \(i)")
      XCTAssert(r1 != nil)
      XCTAssert(a.load() == nil)
    }

    i = UInt.randomPositive()
    XCTAssert(a.swap(Witness(i)) == nil)
    print("Releasing    \(i)")
    XCTAssert(a.swap(nil) != nil)

    i = UInt.randomPositive()
    XCTAssert(a.storeIfNil(Witness(i)) == true)
    let j = UInt.randomPositive()
    print("Will drop    \(j)")
    // a compiler warning is expected for the next line
    XCTAssert(a.swapIfNil(Witness(j)) == false)

    do {
      let v = a.load()
      XCTAssert(v?.id == i)
    }

    print("Will release \(i)")
    XCTAssert(a.take() != nil)
    XCTAssert(a.take() == nil)
  }
}

private let iterations = 200_000//_000

public class ReferenceRaceTests: XCTestCase
{
#if false
  public func testRaceCrash()
  {
    let q = DispatchQueue(label: "", attributes: .concurrent)

    for _ in 1...iterations
    {
      var r: Optional = ManagedBuffer<Int, Int>.create(minimumCapacity: 1, makingHeaderWith: { _ in 1 })
      let closure = {
        while true
        {
          if r != nil
          {
            r = nil
          }
          else
          {
            break
          }
        }
      }

      q.async(execute: closure)
      q.async(execute: closure)
    }

    q.sync(flags: .barrier) {}
  }
#endif

  public func testRaceLoadVersusDeinit()
  {
    let q = DispatchQueue(label: #function, attributes: .concurrent)

    for _ in 1...iterations
    {
      var r = AtomicReference(Thing())

      let closure1 = {
        while let thing = r.load()
        {
          let id = thing.id
          _ = id
        }
      }

      let closure2 = {
        _ = r.swap(nil)
      }

      q.async(execute: closure1)
      q.async(execute: closure2)
    }

    q.sync(flags: .barrier) {}
  }

  public func testRaceAtomicReference()
  {
    let q = DispatchQueue(label: "", attributes: .concurrent)

    for _ in 1...iterations
    {
      let b = ManagedBuffer<Int, Int>.create(minimumCapacity: 1, makingHeaderWith: { _ in 1 })
      var r = AtomicReference(b)
      let closure = {
        while true
        {
          if let buffer = r.take()
          {
            XCTAssert(buffer.header == 1)
          }
          else
          {
            break
          }
        }
      }

      q.async(execute: closure)
      q.async(execute: closure)
    }

    q.sync(flags: .barrier) {}
  }
}
