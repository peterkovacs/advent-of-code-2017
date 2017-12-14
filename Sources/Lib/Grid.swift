
public struct Coordinate {
  let x, y: Int

  public var right: Coordinate { return Coordinate( x: x + 1, y: y ) }
  public var left: Coordinate { return Coordinate( x: x - 1, y: y ) }
  public var up: Coordinate { return Coordinate( x: x, y: y + 1 ) }
  public var down: Coordinate { return Coordinate( x: x, y: y - 1 ) }

  public func x( _ newValue: Int ) -> Coordinate { return Coordinate( x: newValue, y: y ) }
  public func y( _ newValue: Int ) -> Coordinate { return Coordinate( x: x, y: newValue ) }

  public func neighbors(limitedBy: Int) -> [Coordinate] {
    return neighbors(limitedBy: limitedBy, and: limitedBy )
  }

  public func neighbors(limitedBy xLimit: Int, and yLimit: Int) -> [Coordinate] {
    return [ left, right, up, down ].filter { $0.isValid( x: xLimit, y: yLimit ) } 
  }

  public func isValid( x: Int, y: Int ) -> Bool {
    return self.x >= 0 && self.x < x && self.y >= 0 && self.y < y
  }

  public init( x: Int, y: Int ) {
    self.x = x
    self.y = y
  }
}

public struct Grid<T> {
  var grid: [T]
  public let size: Int

  public subscript( x x: Int, y y: Int ) -> T {
    get { return grid[ y * size + x ] }
    set { grid[ y * size + x ] = newValue }
  }

  public subscript( _ c: Coordinate ) -> T {
    get { return self[ x: c.x, y: c.y ] }
    set { self[ x: c.x, y: c.y ] = newValue }
  }

  public init?<S: Sequence>( _ input: S, size: Int ) where S.Element == T {
    self.grid = Array(input)
    self.size = size

    guard grid.count == size * size else { return nil }
  }
}
