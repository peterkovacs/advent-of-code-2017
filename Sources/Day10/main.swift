import Foundation
import Lib
//import FootlessParser
//import CommonCrypto

let initial = Array(0...255)
let input = readLine(strippingNewline: true)!

extension Array where Element == Int {
  mutating func reverse( times n: Int, startingAt start: Int ) {
    var start = start
    var end = (start + n - 1) % count

    for _ in 0..<(n/2) {
      swapAt( start, end )
      start = (start + 1) % count
      end = (end + count - 1) % count
    }
  }

  func knotHash( _ lengths: [Int], n: Int = 1) -> Array<Element> {
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

  func dense() -> [Element] {
    var result = [Element](repeating: 0, count: count/16)

    for i in stride(from: 0, to: count, by: 16) {
      for j in 0..<16 {
        result[i/16] ^= self[i+j]
      }
    }

    return result
  }

  func hex() -> String {
    var result = ""
    for i in self {
      result += String(format: "%02x", i)
    }
    return result
  }
}

print("PART 1" )

let part1 = initial.knotHash( input.split(separator: ",").map{ Int($0)! } )
print(part1[0] * part1[1])

print( "PART 2" )

var lengths = input.flatMap { $0.unicodeScalars.map{Int($0.value)} }
lengths.append(contentsOf: [17, 31, 73, 47, 23])
let part2 = initial.knotHash( lengths, n: 64 )
print(part2.dense().hex())
