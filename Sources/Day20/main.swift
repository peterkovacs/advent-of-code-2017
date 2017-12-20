import Foundation
import Lib
import FootlessParser

struct Vector {
  let x: Int
  let y: Int
  let z: Int
}

struct Particle {
  var position: Vector
  var velocity: Vector
  let acceleration: Vector
}

let vector: Parser<Character,Vector> = (curry({ Vector(x: $0, y: $1, z: $2) }) <^> integer <*> (char(",") *> integer) <*> (char(",") *> integer)).between( char("<"), char(">") )
let parser = curry({ Particle(position: $0, velocity: $1, acceleration: $2) }) <^> (string("p=") *> vector) <*> (string( ", v=") *> vector) <*> (string(", a=") *> vector)
var particles = STDIN.map { try! parse( parser, $0 ) }

let part1 = particles.enumerated().map{ element -> (i: Int, a: Int) in 
  let (n, p) = element
  return (i: n, a: abs(p.acceleration.x)+abs(p.acceleration.y)+abs(p.acceleration.z)) 
}.min(by: { $0.a < $1.a })

print(part1 as Any) 

// Part 2
extension Vector: Hashable {
  var hashValue: Int {
    return self.x << 8 ^ self.y << 4 ^ self.z
  }
  static func +(lhs: Vector, rhs: Vector) -> Vector {
    return Vector(x: lhs.x + rhs.x, y: lhs.y + rhs.y, z: lhs.z + rhs.z)
  }
  static func ==(lhs: Vector, rhs: Vector) -> Bool {
    return lhs.x == rhs.x && lhs.y == rhs.y && lhs.z == rhs.z
  }
}

extension Particle {
  func next() -> Particle {
    let velocity = self.velocity + acceleration
    let position = self.position + velocity
    return Particle( position: position, velocity: velocity, acceleration: self.acceleration )
  }
}

for _ in 0...100 {
  particles = Dictionary<Vector,[Particle]>(grouping: particles, by: { $0.position })
    .flatMap { (_, p) in p.count > 1 ? nil : p.first }
    .map { $0.next() }
}
print( particles.count )
