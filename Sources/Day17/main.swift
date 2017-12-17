import Foundation
import Lib

var buffer = [0]
var position = 0
let input = 370
var valueAfter0 = 1

for i in 1...2017 {
  let next = (input+position) % buffer.count + 1
  position = next
  buffer.insert( i, at: next )
  guard buffer[0] == 0 else { fatalError() }
  if buffer[1] != valueAfter0 {
    // print( "\(i) \(valueAfter0) -> \(buffer[1])" )
    valueAfter0 = buffer[1]
  }
}

print( "PART 1", buffer[position + 1] )

var valueAt1 = 1
position = 1
for i in 2...50_000_000 {
  position = (input + position) % (i - 1) + 1
  if position == 1 {
    valueAt1 = i - 1
  }
}

print( "PART 2", valueAt1 )
