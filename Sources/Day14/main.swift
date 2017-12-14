import Foundation
import Lib
//import FootlessParser
//import CommonCrypto

let input = readLine(strippingNewline: true)!
let memory = (0..<128).map { r in
  return KnotHash( hash: "\(input)-\(r)".unicodeScalars.map { Int($0.value) } )
}

let used = memory.reduce(0) { $0 + $1.hash.reduce(0) { $0 + $1.bits } }
print( used )

var bits = Grid( memory.flatMap { row in (0..<128).map { row[$0] == 1 } }, size: 128 )!
var group = 0

for i in 0..<bits.size {
  for j in 0..<bits.size {
    if bits[x: i, y: j] {
      group += 1

      var work = [Coordinate(x: i, y: j)]

      while !work.isEmpty {
        let next = work.removeFirst()

        bits[next] = false
        let neighbors = next.neighbors(limitedBy: bits.size)

        for c in neighbors {
          guard bits[c] else { continue }
          work.append(c)
        }
      }
    }
  }
}

print( group )
