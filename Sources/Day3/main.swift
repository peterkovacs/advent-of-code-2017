import Foundation
import Lib
//import FootlessParser
//import CommonCrypto

class SpiralGrid {
  typealias Position = (Int,Int)
  var data: [Int?]
  let n: Int

  init( size: Int, with: (SpiralGrid, Int, Position) -> Int ) {
    n = (size & 1) == 0 ? size + 1 : size
    data = [Int?](repeating: nil, count: n * n)

    arrange( with )
  }

  private func arrange( _ with: (SpiralGrid, Int, Position) -> Int ) {
    var stop = 1 
    var position = (n>>1, n>>1)
    var direction = (1,0)
    var number = 1, count = 0

    while( position.0 < n && position.1 < n ) {
      self[position] = with(self, number, position)
      number += 1
      count += 1
      position = ( position.0 + direction.0, position.1 + direction.1 )

      if direction.0 != 0 {
        if count >= stop {
          count = 0
          direction = ( 0, -direction.0 )
        }
      } else if count >= stop {
        direction = ( direction.1, 0 )
        count = 0
        stop += 1
      }
    }
  }

  func neighbors(at pos: Position) -> Int {
    return self[ (pos.0 - 1, pos.1) ] + 
           self[ (pos.0 - 1, pos.1 - 1) ] + 
           self[ (pos.0 - 1, pos.1 + 1) ] +
           self[ (pos.0 + 1, pos.1) ] +
           self[ (pos.0 + 1, pos.1 - 1) ] +
           self[ (pos.0 + 1, pos.1 + 1) ] +
           self[ (pos.0, pos.1 + 1) ] +
           self[ (pos.0, pos.1 - 1) ]
  }

  func distance(to: Position) -> Int {
    return abs(to.0) + abs(to.1) - n + 1
  }

  subscript( at: Position ) -> Int {
    get {
      guard at.0 >= 0, at.0 < n, at.1 >= 0, at.1 < n else { return 0 }
      return data[ at.0 + at.1 * n ] ?? 0
    }

    set {
      data[ at.0 + at.1 * n ] = newValue
    }
  }
}

let target = Int(CommandLine.arguments[1])!
var position: SpiralGrid.Position? = nil
var number: Int? = nil
let grid = SpiralGrid( size: 1000 ) { grid, n, pos in 
  if n == target {
    position = pos
  }

  return n
}
_ = SpiralGrid( size: 10 ) { grid, n, pos in 
  guard n > 1 else { return 1 }

  let value: Int = grid.neighbors(at: pos)

  if value > target {
    number = number ?? value
  }

  return value
}

print( grid.distance( to: position ?? (0,0) ) )
print( number as Any )
