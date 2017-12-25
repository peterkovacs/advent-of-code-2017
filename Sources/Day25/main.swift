import Foundation
import Lib
//import FootlessParser
//import CommonCrypto

enum State {
  case a, b, c, d, e, f
}

var tape = Array(repeating: false, count: 1024*1024)
var position = tape.startIndex.advanced( by: 512*1024)
let start = position
var state = State.a

func run() {
  switch (state, tape[position]) {
  case (.a, false):
    tape[position] = true
    position += 1
    state = .b

  case (.a, true):
    tape[position] = false
    position -= 1
    state = .c

  case (.b, false):
    tape[position] = true
    position -= 1
    state = .a
  case (.b, true):
    // tape[position] = true
    position += 1
    state = .c

  case (.c, false):
    tape[position] = true
    position += 1
    state = .a
  case (.c, true):
    tape[position] = false
    position -= 1
    state = .d

  case (.d, false):
    tape[position] = true
    position -= 1
    state = .e
  case (.d, true):
    // tape[position] = true
    position -= 1
    state = .c

  case (.e, false):
    tape[position] = true
    position += 1
    state = .f
  case (.e, true):
    // tape[position] = true
    position += 1
    state = .a

  case (.f, false):
    tape[position] = true
    position += 1
    state = .a
  case (.f, true):
    // tape[position] = true
    position += 1
    state = .e
  }


}

for _ in 0..<12261543 {
  run()
}

print( tape.reduce(0) { $0 + ($1 ? 1 : 0) } )
