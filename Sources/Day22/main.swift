import Foundation
import Lib
import CoreGraphics
import FootlessParser

let onOff = ( char(".") *> pure(0) ) <|> ( char("#") *> pure(1) )
var input = Grid( try! parse( oneOrMore( onOff ), STDIN.joined() ), count: 25 )!
var part1 = Grid(repeatElement(0, count: 2_001 * 2_001), count: 2_001 )!
part1.copy( grid: input, origin: Coordinate(x: 1001-12, y: 1001-12) )
var part2 = Grid(repeatElement(0, count: 2_001 * 2_001), count: 2_001 )!
part2.copy( grid: input, origin: Coordinate(x: 1001-12, y: 1001-12) )

class Virus {
  var direction: Coordinate.Direction = \.up
  var position: Coordinate
  var cleans = 0, infections = 0

  init( size: Int ) {
    position = Coordinate(x: size / 2 + 1, y: size / 2 + 1)
  }

  func work( grid: inout Grid<Int> ) {
    if grid[ position ] == 1 {
      direction = Coordinate.turn(right: direction)
      cleans += 1
      grid[ position ] = 0
    } else {
      direction = Coordinate.turn(left: direction)
      infections += 1
      grid[ position ] = 1
    }

    position = position[keyPath: direction]
  }
}

var virus = Virus( size: 2001 )

for _ in 0..<10_000 {
  virus.work( grid: &part1 )
}

print( "After 10_000", virus.infections )

class Evolved {
  static let clean = 0
  static let infected = 1
  static let weakened = 2
  static let flagged = 3

  var direction: Coordinate.Direction = \.up
  var position: Coordinate
  var cleans = 0, infections = 0

  init( size: Int ) {
    position = Coordinate(x: size / 2 + 1, y: size / 2 + 1)
  }

  func work( grid: inout Grid<Int> ) {
    switch grid[ position ] {
    case Evolved.clean:
      grid[ position ] = Evolved.weakened
      direction = Coordinate.turn(left: direction)
    case Evolved.weakened:
      grid[ position ] = Evolved.infected
      infections += 1
    case Evolved.infected:
      grid[ position ] = Evolved.flagged
      direction = Coordinate.turn(right: direction)
    case Evolved.flagged:
      grid[ position ] = Evolved.clean
      cleans += 1
      direction = Coordinate.turn(around: direction)
    default:
      fatalError()
    }

    position = position[keyPath: direction]
  }
}

var evolved = Evolved( size: 2001 )

for _ in 0..<10_000_000 {
  evolved.work( grid: &part2 )
}
print( "After 10_000_000", evolved.infections )
