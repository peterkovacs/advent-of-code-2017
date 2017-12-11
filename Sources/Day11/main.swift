import Foundation
import Lib
import FootlessParser
//import CommonCrypto

func steps(to: (Int, Int)) -> Int {
  let x = abs(to.0)
  let y = abs(to.1) - x

  return x + y / 2
}

func part1(input: String) -> (Int,Int) {
  let n = { _ in { (a:(Int,Int)) in ( a.0, a.1 + 2 ) } } <^> string( "n" )
  let ne = { _ in { (a:(Int,Int)) in ( a.0 + 1, a.1 + 1 ) } } <^> string( "ne" )
  let nw = { _ in { (a:(Int,Int)) in ( a.0 - 1, a.1 + 1 ) } } <^> string( "nw" )
  let s = { _ in { (a:(Int,Int)) in ( a.0, a.1 - 2 ) } } <^> string( "s" )
  let se = { _ in { (a:(Int,Int)) in ( a.0 + 1, a.1 - 1 ) } } <^> string( "se" )
  let sw = { _ in { (a:(Int,Int)) in ( a.0 - 1, a.1 - 1 ) } } <^> string( "sw" )
  let parser = separated( ne <|> nw <|> n <|> se <|> sw <|> s, by: char(","), initial: (0,0), accumulator: { $1( $0 ) } )

  return try! parse( parser, input)
}

func part2(input: String) -> (Int, Int, Int) {

  func compare( _ a: Int, _ b: Int, _ c: Int ) -> (Int, Int, Int) {
    let x = steps(to: (a,b))
    if x > c {
      return (a,b,x)
    } else {
      return (a,b,c)
    }
  }

  let n = { _ in { (a:(Int,Int,Int)) in compare( a.0, a.1 + 2, a.2) } } <^> string( "n" )
  let ne = { _ in { (a:(Int,Int,Int)) in compare( a.0 + 1, a.1 + 1, a.2) } } <^> string( "ne" )
  let nw = { _ in { (a:(Int,Int,Int)) in compare( a.0 - 1, a.1 + 1, a.2) } } <^> string( "nw" )
  let s = { _ in { (a:(Int,Int,Int)) in compare( a.0, a.1 - 2, a.2) } } <^> string( "s" )
  let se = { _ in { (a:(Int,Int,Int)) in compare( a.0 + 1, a.1 - 1, a.2) } } <^> string( "se" )
  let sw = { _ in { (a:(Int,Int,Int)) in compare( a.0 - 1, a.1 - 1, a.2) } } <^> string( "sw" )
  let parser = separated( ne <|> nw <|> n <|> se <|> sw <|> s, by: char(","), initial: (0,0,0), accumulator: { $1( $0 ) } )

  return try! parse( parser, input)
}

let input = readLine(strippingNewline: true)!
print( steps(to: part1(input: input)) )
print( part2(input: input).2 )


