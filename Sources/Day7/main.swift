import Foundation
import Lib
import FootlessParser
//import CommonCrypto

class Program: CustomStringConvertible { 
  var parent: Program?
  let name: String
  let weight: Int
  var children: [Program]

  init( name: String, weight: Int ) {
    self.name = name
    self.weight = weight
    self.children = []
    self.parent = nil
  }

  var description: String {
    if children.isEmpty {
      return "\(name) (\(weight))"
    } else {
      return "\(name) (\(weight)/\(totalWeight)) -> [\(children.map{ "\($0.name) (\($0.weight)/\($0.totalWeight))" }.joined( separator: ", " ))]"
    }
  }

  var totalWeight: Int {
    return weight + children.reduce(0) { $0 + $1.totalWeight }
  }

  // false if children have unequal weights && children are balanced.
  var isBalanced: Bool {
    guard children.count > 0 else { return true }
    guard children.reduce( true, { $0 && $1.isBalanced }) else { return true }
    
    let weight = children[0].totalWeight 
    for child in children.dropFirst() {
      if weight != child.totalWeight { return false }
    }

    return true
  }
}

let name = oneOrMore( alphanumeric )
let weight = { Int($0)! } <^> oneOrMore( digit ).between( char("("), char(")") )
let parser = 
{ name in 
  { weight in 
    { children in 
      (name, weight, children ?? [])
    } 
  } 
} <^> name <*> // name
    ( oneOrMore( whitespace ) *> weight ) <*> // (weight)
      optional( string(" -> ") *> // optionally, -> child, child, child
                (extend <^> name <*> zeroOrMore( string(", ") *> name ) ) )

let input = STDIN.map { try! parse( parser, $0 ) }
let programs = Dictionary(uniqueKeysWithValues: input.map { (name, weight, _) in return ( name, Program(name: name, weight: weight) ) })

input.forEach { (name, weight, children) in
  guard children.count > 0 else { return }

  let parent = programs[name]!
  children.forEach {
    let child = programs[$0]!
    child.parent = parent
    parent.children.append( child )
  }
}

// Part 1
let root = programs.values.filter { $0.parent == nil }.first!
print("PART 1")
print(root)

// Part 2
print( "PART 2" )
let unbalanced = Array(programs.values.filter { !$0.isBalanced })
for i in unbalanced {
  print(i)
}
