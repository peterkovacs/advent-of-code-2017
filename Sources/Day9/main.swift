import Foundation
import Lib
import FootlessParser
//import CommonCrypto

let negated = char("!") *> any() *> pure(0)
let garbageCharacter = noneOf("!>") *> pure(0)
let garbage: Parser<Character, Int> =
  zeroOrMore(negated <|> garbageCharacter, 0, accumulator: +).between(char("<"), char(">"))

func part1(_ n: Int) -> Parser<Character,Int> {
  return 
    lazy({ n + $0 } <^>
         optional( 
           separated( part1(n + 1).between(char("{"), char("}")) <|>
                        garbage,
                      by: char(","), initial: 0, accumulator: +),
           otherwise: 0))
}

let countGarbage: Parser<Character, Int> = 
  zeroOrMore( (negated *> pure(0)) <|>
              (garbageCharacter *> pure(1)), 0, accumulator: + )
  .between(char("<"), char(">"))

func part2() -> Parser<Character,Int> {
  return 
    lazy(
      optional(
        separated( part2().between(char("{"), char("}")) <|>
                     countGarbage,
                   by: char(","), initial: 0, accumulator: +), 
        otherwise: 0))
}

let input = readLine( strippingNewline: true )!
print( try! parse( part1(0), input ) )
print( try! parse( part2(), input ) )
