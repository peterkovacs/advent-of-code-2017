import Foundation
import Lib
import FootlessParser
//import CommonCrypto

let passphrase = extend <^> oneOrMore( oneOrMore( alphanumeric ) <* whitespace ) <*> oneOrMore( alphanumeric )
let passphrases = STDIN.map { try! parse( passphrase, $0 ) }

let part1 = passphrases.filter { p in
  var words = Frequency<String>()
  words.add( p )
  
  return words.count == p.count
}

print( part1.count )

let part2 = passphrases.filter { p in
  var words = Frequency<String>()
  words.add( p.map { String($0.sorted()) } )

  return words.count == p.count
}
print( part2.count )
