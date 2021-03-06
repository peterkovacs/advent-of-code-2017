import Foundation
import Lib
import FootlessParser
//import CommonCrypto


typealias Command = ([String:Int])->[String:Int]
typealias Condition = ([String:Int])->Bool

struct Instruction {
  let command: Command
  let condition: Condition

  static let register = oneOrMore( alphanumeric )
  static let command: Parser<Character, Command> = 
    .init(lift: { register, number in 
            return { 
              var registers = $0
              registers[register, default: 0] += number
              registers["maximum"] = max( registers[register, default: 0], registers["maximum", default: 0] )
              return registers
            }
          },
          register <* string("inc").between( whitespaces ), 
          integer) <|>
    .init(lift: { register, number in 
            return { 
              var registers = $0
              registers[register, default: 0] -= number
              registers["maximum"] = max( registers[register, default: 0], registers["maximum", default: 0] )
              return registers
            }
          },
          register <* string("dec").between( whitespaces ), 
          integer)

  static let condition: Parser<Character, Condition> = { 
    let lt =
      Parser<Character,Condition>(lift: { register, number in { registers in registers[register, default:0] < number } },
          register.between( string(" if " ), string( " < " ) ),
          integer )
    let gt =
      Parser<Character,Condition>(lift: { register, number in { registers in registers[register, default:0] > number } },
          register.between( string(" if " ), string( " > " ) ),
          integer )
    let lte =
      Parser<Character,Condition>(lift: { register, number in { registers in registers[register, default:0] <= number } },
          register.between( string(" if " ), string( " <= " ) ),
          integer )
    let gte = 
      Parser<Character,Condition>(lift: { register, number in { registers in registers[register, default:0] >= number } },
          register.between( string(" if " ), string( " >= " ) ),
          integer )
    let eq =
      Parser<Character,Condition>(lift: { register, number in { registers in registers[register, default:0] == number } },
          register.between( string(" if " ), string( " == " ) ),
          integer )
    let neq = 
      Parser<Character,Condition>(lift: { register, number in { registers in registers[register, default:0] != number } },
          register.between( string(" if " ), string( " != " ) ),
          integer )

    return lt <|> gt <|> lte <|> gte <|> eq <|> neq
  }()
  static let parser = Parser<Character,Instruction>( lift: Instruction.init, command, condition )

  static func parse( line: String ) -> Instruction {
    return try! FootlessParser.parse(parser, line)
  }
}

let instructions = STDIN.map { Instruction.parse(line: $0) }
var registers = instructions.reduce([String:Int]()) { registers, instruction in
  if instruction.condition(registers) {
    return instruction.command(registers)
  } else {
    return registers
  }
}
let maximum = registers.remove( at: registers.index(forKey:"maximum")! )
print(registers.max(by: {$0.1 < $1.1}) as Any)
print(maximum)
