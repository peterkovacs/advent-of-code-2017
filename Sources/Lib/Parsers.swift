import FootlessParser

public let unsignedInteger = { Int($0)! } <^> oneOrMore(digit)
public let integer = { Int($0)! } <^> (extend <^> char("-") <*> oneOrMore(digit)) <|> unsignedInteger
public let whitespaces = oneOrMore(FootlessParser.whitespace)

public extension Parser {
  public func between<P>( _ p: Parser<Token,P> ) -> Parser<Token,Output> {
    return self.between( p, p )
  }
}
