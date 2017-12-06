import Foundation
import Lib
import FootlessParser
//import CommonCrypto

let number = { Int($0)! } <^> oneOrMore( digit )
let parser = extend <^> number <*> oneOrMore( oneOrMore(whitespace) *> number ) 
let memory = MemoryBank( memory: STDIN.flatMap { try! parse( parser, $0 ) } )

func part1( memory: MemoryBank ) -> (Int, MemoryBank) {
  var memory = memory
  var seen = Set<MemoryBank>()
  while true {
    memory.redistribute()

    if seen.update(with: memory) != nil { 
      return (seen.count + 1, memory) 
    }
  }
}

func part2( target: MemoryBank ) -> Int {
  var memory = target
  var n = 0

  while true {
    n += 1
    memory.redistribute()

    if memory == target {
      return n
    }
  }
}

let (n, target) = part1( memory: memory )
let m = part2( target: target )

print( n, m )
