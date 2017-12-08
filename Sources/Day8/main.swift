import Foundation
import Lib
import FootlessParser
//import CommonCrypto


typealias Command = ([String:Int],Int)->([String:Int], Int)
typealias Condition = ([String:Int])->Bool

struct Instruction {
  let command: Command
  let condition: Condition

  static let register = oneOrMore( alphanumeric )
  static let number = { Int($0)! } <^> ( extend <^> char("-" as Character) <*> oneOrMore(digit) ) <|> { Int($0)! } <^> oneOrMore(digit)
  static let command: Parser<Character, Command> = 
    .init(lift: { register, number in 
            return { 
              var registers = $0
              registers[register, default: 0] += number
              return (registers, max($1, registers[register, default: 0]))
            }
          },
          register <* string("inc").between( oneOrMore(whitespace), oneOrMore(whitespace) ), 
          number) <|>
    .init(lift: { register, number in 
            return { 
              var registers = $0
              registers[register, default: 0] -= number
              return (registers, max($1, registers[register, default: 0]))
            }
          },
          register <* string("dec").between( oneOrMore(whitespace), oneOrMore(whitespace) ), 
          number)

  static let condition: Parser<Character, Condition> = { 
    let lt =
      Parser<Character,Condition>(lift: { register, number in { registers in registers[register, default:0] < number } },
          register.between( string(" if " ), string( " < " ) ),
          number )
    let gt =
      Parser<Character,Condition>(lift: { register, number in { registers in registers[register, default:0] > number } },
          register.between( string(" if " ), string( " > " ) ),
          number )
    let lte =
      Parser<Character,Condition>(lift: { register, number in { registers in registers[register, default:0] <= number } },
          register.between( string(" if " ), string( " <= " ) ),
          number )
    let gte = 
      Parser<Character,Condition>(lift: { register, number in { registers in registers[register, default:0] >= number } },
          register.between( string(" if " ), string( " >= " ) ),
          number )
    let eq =
      Parser<Character,Condition>(lift: { register, number in { registers in registers[register, default:0] == number } },
          register.between( string(" if " ), string( " == " ) ),
          number )
    let neq = 
      Parser<Character,Condition>(lift: { register, number in { registers in registers[register, default:0] != number } },
          register.between( string(" if " ), string( " != " ) ),
          number )

    return lt <|> gt <|> lte <|> gte <|> eq <|> neq
  }()
  static let parser = Parser<Character,Instruction>( lift: Instruction.init, command, condition )

  static func parse( line: String ) -> Instruction {
    return try! FootlessParser.parse(parser, line)
  }
}

let instructions = STDIN.map { Instruction.parse(line: $0) }
let (registers,m) = instructions.reduce(([String:Int](), 0)) { result, instruction in
  let (registers, max) = result
  if instruction.condition(registers) {
    return instruction.command(registers, max)
  } else {
    return (registers, max)
  }
}
print(registers.max(by: {$0.1 < $1.1}) as Any)
print(m)
