import Foundation
import Lib
import FootlessParser
//import CommonCrypto

enum Value {
  case int(Int)
  case reg(Character)
}

enum Instruction {
  case snd(Character)
  case `set`(Character,Value)
  case add(Character,Value)
  case mul(Character,Value)
  case mod(Character,Value)
  case rcv(Character)
  case jgz(Value,Value)
}

struct CPU {
  var frequency = 0
  var registers = [Character:Int]()
  var instructions: [Instruction]
  var pc: Array<Instruction>.Index

  init<S: Sequence>(_ i: S) where S.Element == Instruction {
    instructions = Array(i)
    pc = instructions.startIndex
  }

  mutating func exec() -> Int? {
    switch instructions[pc] {
    case .snd(let r):
      frequency = registers[r, default: 0]
      pc = instructions.index(pc, offsetBy: 1)

    case .set(let r, let v):
      registers[r, default: 0] = self[v]
      pc = instructions.index(pc, offsetBy: 1)

    case .add(let r, let v):
      registers[r, default: 0] += self[v]
      pc = instructions.index(pc, offsetBy: 1)

    case .mul(let r, let v):
      registers[r, default: 0] *= self[v]
      pc = instructions.index(pc, offsetBy: 1)

    case .mod(let r, let v):
      registers[r, default: 0] %= self[v]
      pc = instructions.index(pc, offsetBy: 1)

    case .rcv(let r):
      if registers[r, default: 0] != 0 {
        return frequency
      }
      pc = instructions.index(pc, offsetBy: 1)

    case .jgz(let a, let b):
      if self[a] > 0 {
        pc = instructions.index(pc, offsetBy: self[b])
      } else {
        pc = instructions.index(pc, offsetBy: 1)
      }
    }

    return nil
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
      { .snd($0) } <^> (string( "snd " ) *> register) <|>
      curry({ .set($0, $1) }) <^> ( string( "set " ) *> register ) <*> ( char(" ") *> value ) <|>
      curry({ .add($0, $1) }) <^> ( string( "add " ) *> register ) <*> ( char(" ") *> value ) <|>
      curry({ .mul($0, $1) }) <^> ( string( "mul " ) *> register ) <*> ( char(" ") *> value ) <|>
      curry({ .mod($0, $1) }) <^> ( string( "mod " ) *> register ) <*> ( char(" ") *> value ) <|>
      { .rcv($0) } <^> (string( "rcv " ) *> register) <|>
      curry({ .jgz($0, $1) }) <^> ( string( "jgz " ) *> value ) <*> ( char(" ") *> value )
  }
}

struct Duet {
  var registers = [Character:Int]()
  var instructions: [Instruction]
  var pc: Array<Instruction>.Index
  var queue = [Int]()

  init<S: Sequence>(number: Int, _ i: S) where S.Element == Instruction {
    instructions = Array(i)
    pc = instructions.startIndex
    registers["p"] = number
  }

  mutating func rcv(_ value: Int) {
    queue.append(value)
  }

  // returns false if blocked
  mutating func exec( send: (Int)->() ) -> Bool {
    switch instructions[pc] {
    case .snd(let r):
      send( registers[r, default: 0] )
      pc = instructions.index(pc, offsetBy: 1)

    case .set(let r, let v):
      registers[r, default: 0] = self[v]
      pc = instructions.index(pc, offsetBy: 1)

    case .add(let r, let v):
      registers[r, default: 0] += self[v]
      pc = instructions.index(pc, offsetBy: 1)

    case .mul(let r, let v):
      registers[r, default: 0] *= self[v]
      pc = instructions.index(pc, offsetBy: 1)

    case .mod(let r, let v):
      registers[r, default: 0] %= self[v]
      pc = instructions.index(pc, offsetBy: 1)

    case .rcv(let r):
      if queue.isEmpty {
        return false
      } else {
        registers[r] = queue[0]
        queue = Array(queue.dropFirst())
      }

      pc = instructions.index(pc, offsetBy: 1)

    case .jgz(let a, let b):
      if self[a] > 0 {
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
}

let instructions = STDIN.map { try! parse( CPU.parser, $0 ) }
var cpu = CPU( instructions )
while true {
  guard let recovered = cpu.exec() else { continue }
  print( "PART 1", recovered )
  break
}

var a = Duet(number: 0, instructions)
var b = Duet(number: 1, instructions)
var part2 = 0

while true {
  if a.exec( send: { b.rcv($0) } ) || b.exec( send: { part2 += 1; a.rcv($0) } ) { continue }
  print( "PART 2", part2 )
  break
}
