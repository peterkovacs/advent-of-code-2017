import Foundation
import Lib
import FootlessParser
//import CommonCrypto

func steps(to: (Int, Int)) -> Int {
  let x = abs(to.0)
  let y = abs(to.1) - x

  return x + y / 2
}

typealias Point = (Int,Int,Int)
func parse(input: String, combine: @escaping (Point)->Point ) -> Point {

  let n = { _ in { (a:Point) in combine((a.0, a.1 + 2, a.2)) } } <^> string( "n" )
  let ne = { _ in { (a:Point) in combine((a.0 + 1, a.1 + 1, a.2)) } } <^> string( "ne" )
  let nw = { _ in { (a:Point) in combine((a.0 - 1, a.1 + 1, a.2)) } } <^> string( "nw" )
  let s = { _ in { (a:Point) in combine((a.0, a.1 - 2, a.2)) } } <^> string( "s" )
  let se = { _ in { (a:Point) in combine((a.0 + 1, a.1 - 1, a.2)) } } <^> string( "se" )
  let sw = { _ in { (a:Point) in combine((a.0 - 1, a.1 - 1, a.2)) } } <^> string( "sw" )
  let parser = separated( ne <|> nw <|> n <|> se <|> sw <|> s, by: char(","), initial: (0,0,0), accumulator: { $1( $0 ) } )

  return try! FootlessParser.parse( parser, input)
}

let input = readLine(strippingNewline: true)!
print( parse(input: input) { ( $0.0, $0.1, steps(to: ($0.0, $0.1)) ) }.2 )
print( parse(input: input) { (a: Point) in
    let x = steps(to: (a.0, a.1))
    if x > a.2 {
      return (a.0, a.1, x)
    } else {
      return a
    }
  }.2 )


