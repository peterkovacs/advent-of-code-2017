import Foundation
import Lib
import FootlessParser
//import CommonCrypto

let parser = { a in { b in (a, b) } } <^> unsignedInteger <*> (string( " <-> " ) *> separated( unsignedInteger, by: string( ", " ) ))
let input = Dictionary( uniqueKeysWithValues: STDIN.map{ try! parse(parser, $0) } )

func part1(input: [Int:[Int]]) -> Int {
  var data = Set<Int>([0])
  var working = input[0, default: []]

  while !working.isEmpty {
    let next = working.removeFirst()
    if data.update(with: next) == nil {
      working.append( contentsOf: input[next, default: []] )
    }
  }
  return data.count
}
print(part1(input: input))


func part2(input: [Int:[Int]]) -> Int {
  var number = 1
  var part2 = Set<Int>([0])
  var input = input
  var working = input[0, default: []]

  input[0] = nil

  while !input.isEmpty {
    while !working.isEmpty {
      let next = working.removeFirst()
      if part2.update(with: next) == nil {
        working.append(contentsOf: input[next, default: []])
        input[next] = nil
      }
    }

    number += 1
    if let first = input.first {
      working = first.value
      input[first.key] = nil
    }
  }

  return number
}
print(part2(input: input))
