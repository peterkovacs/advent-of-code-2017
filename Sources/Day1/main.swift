import Foundation
import FootlessParser
import Lib
//import CommonCrypto

struct Part1<T: Collection>: Sequence, IteratorProtocol {
  let s: T
  var index: T.Index

  init( _ s: T ) {
    self.s = s
    self.index = s.startIndex
  }

  mutating func next() -> (T.Element, T.Element)? {
    guard index != s.endIndex else { return nil }

    let next = s.index( index, offsetBy: 1)
    defer { index = next }

    guard next != s.endIndex else {
      // ( last, first )
      return ( s[ index ], s.first! )
    }

    return ( s[ index ], s[ next ] )
  }
}

struct Part2<T: Collection>: Sequence, IteratorProtocol {
  let s: T
  var index: T.Index

  init( _ s: T ) {
    self.s = s
    self.index = s.startIndex
  }

  func index( _ index: T.Index ) -> T.Index {
    let count = s.count / 2
    let distance = s.distance( from: index, to: s.endIndex )

    if distance > count {
      return s.index( index, offsetBy: count )
    } else {
      return s.index( s.startIndex, offsetBy: count - distance )
    }
  }

  mutating func next() -> (T.Element, T.Element)? {
    guard index != s.endIndex else { return nil }

    let next = index( index )
    defer { index = s.index( index, offsetBy: 1 ) }

    return ( s[ index ], s[ next ] )
  }
}


let number = { Int(String($0))! } <^> digit
let parser = oneOrMore( number )

let digits: Array<Int> = try! parse( parser, readLine( strippingNewline: true )! )

let part1 = Part1(digits).filter { $0.0 == $0.1 }.reduce(0) { $0 + $1.0 } 
print(part1)

let part2 = Part2(digits).filter { $0.0 == $0.1 }.reduce(0) { $0 + $1.0 } 
print(part2)
