import Foundation
import Lib
import FootlessParser

extension Array where Element: Equatable {
  func spin( _ n: Int ) -> Array<Element> {
    let n = n % count
    return Array( suffix(n) ) + prefix( count - n )
  }

  func exchange( a: Int, b: Int ) -> Array<Element> {
    var result = self
    result.swapAt( a, b )
    return result
  }

  func partner( a: Element, b: Element ) -> Array<Element> {
    guard let a = index(of: a), let b = index(of: b) else { return self }
    return exchange( a: a, b: b )
  }
}

typealias Action = ([Character]) -> [Character]

let spin: Parser<Character,Action> = { n in { input in input.spin( n ) } } <^> (char("s") *> unsignedInteger)
let exchange: Parser<Character,Action> = curry({ a, b in { input in input.exchange( a: a, b: b ) } }) <^> (char("x") *> unsignedInteger) <*> (char("/") *> unsignedInteger)
let partner: Parser<Character,Action> = curry({ a, b in { input in input.partner( a: a, b: b ) } }) <^> (char("p") *> any()) <*> (char("/") *> any())

let dancers: [Character] = [ "a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p" ]
let input = readLine(strippingNewline: true)!
let actions: [Action] = try! parse( separated( spin <|> exchange <|> partner, by: char(",") ), input )

let part1 = actions.reduce(dancers) { $1($0) }
print(part1.map{ String($0) }.joined())

var cycle: Int = 0
var cycles = actions.reduce(dancers) { $1($0) }
for i in 1..<10_000 {
  if cycles == dancers {
    cycle = i
    break
  }
  cycles = actions.reduce(cycles) { $1($0) }
}

var part2 = dancers
for _ in (1_000_000_000 - (1_000_000_000 % cycle))..<1_000_000_000 {
  part2 = actions.reduce(part2) { $1($0) }
}
print( part2.map{ String($0) }.joined() )
