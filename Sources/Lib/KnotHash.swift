import Foundation

public extension Array where Element == Int {
  public mutating func reverse( times n: Int, startingAt start: Int ) {
    var start = start
    var end = (start + n - 1) % count

    for _ in 0..<(n/2) {
      swapAt( start, end )
      start = (start + 1) % count
      end = (end + count - 1) % count
    }
  }

  public func knotHash( _ lengths: [Int], n: Int = 1) -> Array<Element> {
    var position = 0, skip = 0
    var result = self

    for _ in 0..<n {
      for i in lengths {
        result.reverse( times: i, startingAt: position )

        position += i
        position += skip
        position %= result.count
        skip += 1
      }
    }

    return result
  }

  public func dense() -> [Element] {
    var result = [Element](repeating: 0, count: count/16)

    for i in stride(from: 0, to: count, by: 16) {
      for j in 0..<16 {
        result[i/16] ^= self[i+j]
      }
    }

    return result
  }

  public func hex() -> String {
    var result = ""
    for i in self {
      result += String(format: "%02x", i)
    }
    return result
  }
}

public struct KnotHash {
  public typealias Index = Array<Int>.Index
  public let hash: Array<Int>
  public init<S: Sequence>( hash: S ) where S.Element == Int {
    var lengths = Array(hash)
    lengths.append(contentsOf: [17, 31, 73, 47, 23])
    self.hash = Array(0..<256).knotHash( lengths, n: 64 ).dense()
  }

  public var hex: String {
    get {
      return hash.hex()
    }
  }

  public subscript( _ index: Index ) -> Int {
    // each element of the hash represents 8 bits
    let i = index / 8
    let j = index % 8
    let offset = [ 0b10000000, 0b01000000, 0b00100000, 0b00010000, 0b00001000, 0b00000100, 0b00000010, 0b00000001 ]
    return (hash[i] & offset[j]) >> (7 - j)
  }
}
