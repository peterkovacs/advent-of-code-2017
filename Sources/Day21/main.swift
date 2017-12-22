import Foundation
import Lib
import FootlessParser
import CoreGraphics
//import CommonCrypto

let onOff = ( char(".") *> pure(0) ) <|> ( char("#") *> pure(1) )
let input = { Grid($0.joined(), count: $0.count)! } <^> separated( count(2...3, onOff), by: char("/") )
let output = { Grid($0.joined(), count: $0.count)! } <^> separated( count(3...4, onOff), by: char("/") )
let parser = tuple <^> input <*> (string( " => " ) *> output)

var grid = Grid( [ 0, 1, 0, 0, 0, 1, 1, 1, 1 ], count: 3 )!
let patterns = STDIN.map { try! parse( parser, $0 ) }

func expand( pattern: Grid<Int> ) -> Grid<Int> {
  for (match, expansion) in patterns {
    if match == pattern ||
       match.mirrored == pattern || 
       match.rotated == pattern || 
       match.rotated.mirrored == pattern || 
       match.rotated.rotated == pattern || 
       match.rotated.rotated.mirrored == pattern || 
       match.rotated.rotated.rotated == pattern || 
       match.rotated.rotated.rotated.mirrored == pattern {
      return expansion
     }
  }

  return pattern
}

func copy( grid: Grid<Int>, into: inout Grid<Int>, origin: Coordinate ) {
  for y in origin.y..<(origin.y+grid.count) {
    for x in origin.x..<(origin.x+grid.count) {
      into[x: x, y: y] = grid[x: x - origin.x, y: y - origin.y]
    }
  }
}

func expand( grid: Grid<Int> ) -> Grid<Int> {
  var result: Grid<Int>

  if grid.count % 2 == 0 {
    let count = (grid.count * 3) / 2
    result = Grid<Int>( repeatElement(0, count: count * count), count: count )!

    for y in stride(from: 0, to: grid.count, by: 2) {
      for x in stride(from: 0, to: grid.count, by: 2) {
        let g = grid[x: x..<(x+2), y: y..<(y+2)]!
        copy(grid: expand(pattern: g), into: &result, origin: Coordinate( x: x * 3 / 2, y: y * 3 / 2 ))
      }
    }
  } else {
    let count = (grid.count * 4) / 3
    result = Grid<Int>( repeatElement(0, count: count * count), count: count )!

    for y in stride(from: 0, to: grid.count, by: 3) {
      for x in stride(from: 0, to: grid.count, by: 3) {
        let g = grid[x: x..<(x+3), y: y..<(y+3)]!
        copy(grid: expand(pattern: g), into: &result, origin: Coordinate( x: x * 4 / 3, y: y * 4 / 3 ))
      }
    }
  }
  return result
}

func print<T: CustomStringConvertible>( grid g: Grid<T> ) {
  print( "COORDINATES" )
  for y in 0..<g.count {
    for x in 0..<g.count {
      print((x,y), " -> ", g.transform( x: x, y: y ))
    }
  }
  print()

  for y in 0..<g.count {
    for x in 0..<g.count {
      print(g[x: x, y: y], terminator: "")
    }
    print()
  }
  print()
}

for i in 0..<5 {
  grid = expand( grid: grid )
}

print( grid.reduce(0, +) )

for i in 5..<18 {
  grid = expand( grid: grid )
}

print( grid.reduce(0, +) )

