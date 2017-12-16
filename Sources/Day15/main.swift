import Foundation
import Lib

struct Generator: Sequence, IteratorProtocol {
  let factor: Int
  var value: Int

  mutating func next() -> Int? {
    value = (value * factor) % 0x7fffffff
    return value
  }
}

print("PART 1")
print(zip(Generator(factor: 16807, value: 783), 
          Generator(factor:48271, value: 325))
        .prefix(40_000_000)
        .filter { (a,b) in (a&0xffff) == (b&0xffff) }
        .count)

print("PART 2")
print(zip(Generator(factor: 16807, value: 783).lazy.filter{ $0 % 4 == 0 },
          Generator(factor:48271, value: 325).lazy.filter{ $0 % 8 == 0 })
        .prefix(5_000_000)
        .filter { (a,b) in (a&0xffff) == (b&0xffff) }
        .count)
