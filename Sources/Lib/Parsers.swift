import FootlessParser

public let unsignedInteger = { Int($0)! } <^> oneOrMore(digit)
public let integer = { Int($0)! } <^> (extend <^> char("-") <*> oneOrMore(digit)) <|> unsignedInteger
public let whitespaces = oneOrMore(FootlessParser.whitespace)

public extension Parser {
  public func between<P>( _ p: Parser<Token,P> ) -> Parser<Token,Output> {
    return self.between( p, p )
  }
}

extension Array {
  func appending( _ element: Element ) -> Array<Element> {
    var result = self
    result.append( element )
    return result
  }
}

public func separated<T,A,B,O>(_ p: Parser<T,A>, by: Parser<T,B>, initial: O, accumulator: @escaping (O,A) -> O) -> Parser<T,O> {
  return Parser { input in
    var working = input
    var results = initial
    
    results = accumulator( results, try p.parse(&working) )
    input = working

    do {
      while true {
        _ = try by.parse(&working)
        results = accumulator( results, try p.parse(&working) )
        input = working
      }
    } catch {
      return results
    }
  }
}

public func separated<T,A,B>( _ p: Parser<T,A>, by: Parser<T,B> ) -> Parser<T,[A]> {
  let initial = [A]()
  return separated(p, by: by, initial: initial) { $0.appending($1) }
}

/** Apply parser once, then repeat until it fails. Returns an array of the results. */
public func oneOrMore <T,A,O> (_ p: Parser<T,A>, _ initial: O, accumulator: @escaping (O, A) -> O ) -> Parser<T,O> {
    return Parser { input in
        let first = try p.parse(&input)
        var result = accumulator( initial, first )
        while true {
            do {
                let next = try p.parse(&input)
                result = accumulator( result, next )
            } catch {
                return result
            }
        }
    }
}

/** Repeat parser until it fails. Returns an array of the results. */
public func zeroOrMore <T,A,O> (_ p: Parser<T,A>, _ initial: O, accumulator: @escaping (O, A) -> O ) -> Parser<T,O> {
    return optional( oneOrMore(p, initial, accumulator: accumulator), otherwise: initial )
}
