import Foundation
import Lib

var jumps = STDIN.map { Int($0)! }
var part1 = jumps

func part1( _ jumps: [Int] ) -> Int {
  var jumps = jumps
  var instruction = jumps.startIndex
  var steps = 0

  while instruction < jumps.endIndex {
    let current = instruction
    steps += 1

    defer { jumps[current] += 1 }

    instruction = jumps.index( instruction, offsetBy: jumps[ instruction ], limitedBy: jumps.endIndex ) ?? jumps.endIndex
  }
  return steps
}

func part2( _ jumps: [Int] ) -> Int {
  var jumps = jumps
  var instruction = jumps.startIndex
  var steps = 0
  while instruction < jumps.endIndex {
    let current = instruction
    steps += 1

    defer { 
      switch jumps[current] {
      case 3...:
        jumps[current] -= 1
      default:
        jumps[current] += 1
      }
    }

    instruction = jumps.index( instruction, offsetBy: jumps[ instruction ], limitedBy: jumps.endIndex ) ?? jumps.endIndex
  }

  return steps
}

print( part1( jumps ) )
print( part2( jumps ) )
