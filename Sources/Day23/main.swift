import Foundation
import Lib
import FootlessParser

enum Value {
  case int(Int)
  case reg(Character)
}

enum Instruction {
  case `set`(Character,Value)
  case sub(Character,Value)
  case mul(Character,Value)
  case jnz(Value,Value)
}

struct CPU: CustomStringConvertible {
  var registers = [Character:Int]()
  var instructions: [Instruction]
  var pc: Array<Instruction>.Index
  var mul = 0

  init<S: Sequence>(_ i: S) where S.Element == Instruction {
    instructions = Array(i)
    pc = instructions.startIndex
  }

  mutating func exec() -> Bool {
    guard pc < instructions.endIndex else { return false }

    switch instructions[pc] {
    case .set(let r, let v):
      registers[r, default: 0] = self[v]
      pc = instructions.index(pc, offsetBy: 1)

    case .sub(let r, let v):
      registers[r, default: 0] -= self[v]
      pc = instructions.index(pc, offsetBy: 1)

    case .mul(let r, let v):
      mul += 1
      registers[r, default: 0] *= self[v]
      pc = instructions.index(pc, offsetBy: 1)


    case .jnz(let a, let b):
      if self[a] != 0 {
        pc = instructions.index(pc, offsetBy: self[b])
      } else {
        pc = instructions.index(pc, offsetBy: 1)
      }
    }

    return true
  }

  subscript( _ v: Value ) -> Int {
    switch v {
    case .int(let value):
      return value
    case .reg(let c):
      return registers[c, default: 0]
    }
  }

  static var parser: Parser<Character, Instruction> {
    let register: Parser<Character,Character> = oneOf("abcdefghijklmnopqrstuvwxyz")
    let value: Parser<Character,Value> = ({ .int($0) } <^> integer) <|> ({ .reg($0) } <^> register)
    return
      curry({ .set($0, $1) }) <^> ( string( "set " ) *> register ) <*> ( char(" ") *> value ) <|>
      curry({ .sub($0, $1) }) <^> ( string( "sub " ) *> register ) <*> ( char(" ") *> value ) <|>
      curry({ .mul($0, $1) }) <^> ( string( "mul " ) *> register ) <*> ( char(" ") *> value ) <|>
      curry({ .jnz($0, $1) }) <^> ( string( "jnz " ) *> value ) <*> ( char(" ") *> value )
  }

  var description: String {
    return "CPU(registers: \(registers), \n    pc: \(pc) \(pc < instructions.endIndex ? String(describing: instructions[pc]) : "END"))"
  }
}

let instructions = STDIN.map { try! parse( CPU.parser, $0 ) }
var part1 = CPU( instructions )
while part1.exec() { }
print( "PART 1", part1.mul )

// Part 2 is counting the *non-primes* starting with 106500 and incrementing by 17.

extension Int {
  var isPrime: Bool {
    var i = 2
    while i*i <= self {
      if self % i == 0 {
        return false
      }

      i+=1
    }

    return true
  }
}


let part2 = stride( from: 106500, through: 123500, by: 17 ).filter { !$0.isPrime }.count
print("PART 2", part2)
