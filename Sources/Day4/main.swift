import Foundation
import Lib
import FootlessParser
//import CommonCrypto

let passphrase = extend <^> oneOrMore( oneOrMore( alphanumeric ) <* whitespace ) <*> oneOrMore( alphanumeric )
let passphrases = STDIN.map { try! parse( passphrase, $0 ) }

let part1 = passphrases.filter { p in
  return Set(p).count == p.count
}

print( part1.count )

let part2 = passphrases.filter { p in
  return Set( p.map { String($0.sorted()) } ).count == p.count
}
print( part2.count )
