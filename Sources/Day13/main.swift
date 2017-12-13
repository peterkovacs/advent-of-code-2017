import Foundation
import Lib
import FootlessParser
//import CommonCrypto

struct Firewall {
  let layers: [Int:Int]
  let numberOfLayers: Int

  init<S>( input: S ) where S:Sequence, S.Element == (Int,Int) {
    layers = Dictionary( uniqueKeysWithValues: input )
    numberOfLayers = layers.keys.max() ?? 0
  }

  func severity( at picoseconds: Int, delay: Int = 0 ) -> Int? {
    if let period = layers[picoseconds] {

      if (picoseconds + delay) % (period * 2 - 2) == 0 {
        return picoseconds * period
      }
    }

    return nil
  }

  func canLeaveAt( delay: Int ) -> Bool {
    if (0...numberOfLayers).index( where: { severity(at: $0, delay: delay ) != nil } ) != nil {
      return false
    } else { 
      return true
    }
  }
}

let parser = tuple <^> integer <*> (string( ": " ) *> integer)
let firewall = Firewall( input: STDIN.map { try! parse( parser, $0 ) } )

print( "PART 1" )
print( (0...firewall.numberOfLayers).reduce(0) { $0 + (firewall.severity(at: $1) ?? 0) } )

print( "PART 2" ) 
print( (0...).first( where: { firewall.canLeaveAt(delay: $0) } ) as Any )

