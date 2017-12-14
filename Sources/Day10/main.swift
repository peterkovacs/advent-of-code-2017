import Foundation
import Lib
//import FootlessParser
//import CommonCrypto

let initial = Array(0...255)
let input = readLine(strippingNewline: true)!

print("PART 1" )
let part1 = initial.knotHash( input.split(separator: ",").map{ Int($0)! } )
print(part1[0] * part1[1])

print( "PART 2" )
print( KnotHash( hash: input.flatMap { $0.unicodeScalars.map{ Int($0.value) } } ).hex )
