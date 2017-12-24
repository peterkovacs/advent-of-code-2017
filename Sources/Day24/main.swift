import Foundation
import Lib
import FootlessParser

struct Component: Hashable {
  let a, b: Int

  var value: Int {
    return a+b
  }

  func not( _ val: Int ) -> Int {
    if val == a { return b }
    else { return a }
  }

  var hashValue: Int {
    return a + b
  }
  static func ==(l: Component, r: Component) -> Bool {
    return l.a == r.a && l.b == r.b
  }
}

let parser = curry(Component.init) <^> integer <*> (char("/") *> integer)
let components = Set(STDIN.map{ try! parse( parser, $0 ) })

print(components.count)

func part1( components: Set<Component>, connect: Int ) -> Int {
  let available = components.filter { $0.a == connect || $0.b == connect }
  
  if available.isEmpty {
    return 0
  }

  var result: Int = 0
  for i in available {
    var next = components
    next.remove( i )

    result = max( result, part1( components: next, connect: i.not( connect ) ) + i.value )
  }

  return result
}

print( "PART 1", part1( components: components, connect: 0 ) )

func part2( components: Set<Component>, connect: Int ) -> (length: Int, strength: Int) {
  let available = components.filter { $0.a == connect || $0.b == connect }
  
  if available.isEmpty {
    return (length: 0, strength: 0)
  }

  var result = (length: 0, strength: 0)
  for i in available {
    var next = components
    next.remove( i )

    let (length, strength) = part2( components: next, connect: i.not( connect ) )
    switch (length + 1, strength + i.value) {
    case (result.length, (result.strength+1)...),
         ((result.length+1)..., _):
      result = (length: length + 1, strength: strength + i.value )
    case (...result.length, _): break
    case (_, _): break
    }
  }

  return result
}

print( "PART 2", part2( components: components, connect: 0 ) )
