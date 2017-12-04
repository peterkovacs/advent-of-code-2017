import Foundation
import Lib
import FootlessParser
//import CommonCrypto

let number = { Int($0)! } <^> oneOrMore( digit )
let parser = oneOrMore( number <* zeroOrMore( whitespace ) )

extension Collection where Element: Comparable {
  func minmax() -> (Element, Element) {
    var min = self.first!
    var max = self.first!

    for i in self {
      if min > i {
        min = i
      }
      if max < i {
        max = i
      }
    }

    return (min, max)
  }
}

let data = STDIN.map { try! parse( parser, $0 ) }
let part1 = data.map { $0.minmax() }.map { $1 - $0 }.reduce(0, +)
print( part1 )

let part2 = data.map { (line: [Int]) -> (Int) in
  let pair = Array( line.lazyCombos(n: 2).filter { $0[0] % $0[1] == 0 || $0[1] % $0[0] == 0 } )

  assert( pair.count == 1 )
  assert( pair[0].count == 2 )

  return (pair[0].max()! / pair[0].min()!)
}.reduce(0, +)
print( part2 )
