import Foundation
import CoreGraphics

public struct Coordinate {
  public let x, y: Int
  public typealias Direction = KeyPath<Coordinate, Coordinate>

  public var right: Coordinate { return Coordinate( x: x + 1, y: y ) }
  public var left: Coordinate { return Coordinate( x: x - 1, y: y ) }
  public var up: Coordinate { return Coordinate( x: x, y: y - 1 ) }
  public var down: Coordinate { return Coordinate( x: x, y: y + 1 ) }

  public func neighbors(limitedBy: Int) -> [Coordinate] {
    return neighbors(limitedBy: limitedBy, and: limitedBy )
  }

  public func neighbors(limitedBy xLimit: Int, and yLimit: Int) -> [Coordinate] {
    return [ left, right, up, down ].filter { $0.isValid( x: xLimit, y: yLimit ) } 
  }

  public func isValid( x: Int, y: Int ) -> Bool {
    return self.x >= 0 && self.x < x && self.y >= 0 && self.y < y
  }

  public func neighbors( limitedBy: Int, traveling: Direction ) -> [Coordinate] {
    switch traveling {
    case \Coordinate.down, \Coordinate.up:
      return [ left, right ].filter { $0.isValid( x: limitedBy, y: limitedBy ) }
    case \Coordinate.left, \Coordinate.right:
      return [ down, up ].filter { $0.isValid( x: limitedBy, y: limitedBy ) }
    default: fatalError()
    }
  }

  public func direction(to: Coordinate) -> Direction {
    if abs(self.x - to.x) > abs(self.y - to.y) {
      return self.x > to.x ? \Coordinate.left : \Coordinate.right
    } else {
      return self.y > to.y ? \Coordinate.up : \Coordinate.down
    }
  }

  public init( x: Int, y: Int ) {
    self.x = x
    self.y = y
  }
}

public struct Grid<T>: Sequence {

  public struct Iterator: IteratorProtocol {
    let grid: Grid
    var coordinate: Coordinate

    public mutating func next() -> T? {
      if !coordinate.isValid( x: grid.count, y: grid.count ) {
        coordinate = Coordinate(x: 0, y: coordinate.y+1)
      }
      guard coordinate.isValid( x: grid.count, y: grid.count ) else { return nil }
      defer { coordinate = coordinate.right }

      return grid[ coordinate ]
    }
  }

  public typealias Element = T
  var grid: [Element]
  public let count: Int
  let transform: CGAffineTransform 

  public subscript( x x: Int, y y: Int ) -> Element {
    get { 
      let point = transform(x: x, y: y)
      return grid[ point.y * count + point.x ] 
    }
    set { 
      let point = transform(x: x, y: y)
      grid[ point.y * count + point.x ] = newValue 
    }
  }

  public subscript( _ c: Coordinate ) -> Element {
    get { return self[ x: c.x, y: c.y ] }
    set { self[ x: c.x, y: c.y ] = newValue }
  }

  public subscript( x x: CountableRange<Int>, y y: CountableRange<Int>) -> Grid<Element>? {
    guard x.count == y.count else { return nil }
    return Grid( zip( y, repeatElement( x, count: y.count ) ).lazy.flatMap{ outer in outer.1.map { inner in self[ x: inner, y: outer.0 ] } }, count: x.count, transform: .identity )
  }

  public init?<S: Sequence>( _ input: S, count: Int, transform: CGAffineTransform = .identity ) where S.Element == Element {
    self.grid = Array(input)
    self.count = count
    self.transform = transform

    guard grid.count == count * count else { return nil }
  }

  public init?<S: Sequence>( rotated input: S, count: Int, transform: CGAffineTransform = .identity ) where S.Element == Element {
    self.grid = Array(input)
    self.count = count

    if (count % 2) == 1 {
      self.transform = transform
        .translatedBy(x: CGFloat(count/2), y: CGFloat(count/2))
        .rotated(by: .pi/2)
        .translatedBy(x: -CGFloat(count/2), y: -CGFloat(count/2))
    } else {
      // No idea why +1 needed, but even-count rotations don't line up without it.
      // Probably should've paid more attention in linear algebra
      self.transform = transform
        .translatedBy(x: CGFloat(count/2), y: CGFloat(count/2))
        .rotated(by: .pi/2)
        .translatedBy(x: -CGFloat(count/2), y: -CGFloat(count/2) + 1)
    }

    guard grid.count == count * count else { return nil }
  }

  public init?<S: Sequence>( mirrored input: S, count: Int, transform: CGAffineTransform = .identity ) where S.Element == Element {
    self.grid = Array(input)
    self.count = count
    self.transform = transform
      .scaledBy(x: -1, y: 1)
      .translatedBy(x: -CGFloat(count - 1), y: 0)

    guard grid.count == count * count else { return nil }
  }

  public var rotated: Grid {
    return Grid( rotated: grid, count: count, transform: transform )!
  }

  public var mirrored: Grid {
    return Grid( mirrored: grid, count: count, transform: transform )!
  }

  public func transform(x: Int, y: Int) -> Coordinate {
    let point = CGPoint(x: x, y: y).applying( self.transform ) 
    return Coordinate( x: Int(point.x.rounded()), y: Int(point.y.rounded()) )
  }

  public func makeIterator() -> Iterator {
    return Iterator(grid: self, coordinate: Coordinate(x: 0, y: 0))
  }
}

extension Grid where Grid.Element: Equatable {
  public static func ==(lhs: Grid, rhs: Grid) -> Bool {
    guard lhs.count == rhs.count else { return false }
    return lhs.elementsEqual( rhs )
  }
}

