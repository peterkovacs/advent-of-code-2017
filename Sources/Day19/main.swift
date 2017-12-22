import Foundation
import Lib

let size = 201
var grid = Grid<Character>( STDIN.flatMap{ $0 }, count: 201 )!
var coordinate = Coordinate( x: 131, y: 0 )
var direction = \Coordinate.down
var steps = 1
var letters = ""

repeat {
  coordinate = coordinate[keyPath: direction]
  steps += 1

  if grid[coordinate] == "+" {
    let neighbors = coordinate.neighbors(limitedBy: size, traveling: direction).filter { grid[$0] != " " }
    direction = coordinate.direction(to: neighbors[0])
  } else if "ABCDEFGHIJKLMNOPQRSTUVWXYZ".contains( grid[coordinate] ) {
    letters.append( grid[coordinate] )
  }
} while grid[coordinate] != "U"

print( "LETTERS", letters )
print( "STEPS", steps )
