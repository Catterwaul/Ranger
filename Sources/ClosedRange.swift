import HMAlgorithms
import HMNumerics

public extension ClosedRange {
  /// A range whose bounds are the extremes of a given sequence.
  ///
  /// - Returns: `nil` if the sequence is empty.
  init?(encompassing bounds: some Sequence<Bound>) {
    guard let initialRange = (bounds.first.map { $0...$0 })
    else { return nil }

    self = bounds.dropFirst().reduce(into: initialRange) { range, bound in
      if bound < range.lowerBound {
        range = bound...range.upperBound
      } else if bound > range.upperBound {
        range = range.lowerBound...bound
      }
    }
  }
}

public extension ClosedRange where Bound: Strideable, Bound.Stride: SignedInteger {
  init(_ slice: SubSequence) {
    self = slice.first!...slice.last!
  }
}

public extension ClosedRange where Bound: ExpressibleByIntegerLiteral {
  /// From zero to the upper bound, inclusive.
  @inlinable init(_ range: PartialRangeThrough<Bound>) {
    self = 0...range.upperBound
  }
}

public extension ClosedRange where Bound: AdditiveArithmetic {
  /// `upperBound - lowerBound`
  var magnitude: Bound { upperBound - lowerBound }
}

public extension ClosedRange where Bound: Numeric {
  /// Linear interpolation between `lowerBound` and `upperBound`.
  subscript(normalized normalizedValue: Bound) -> Bound {
    normalizedValue * magnitude + lowerBound
  }
}

public extension ClosedRange where Bound: FloatingPoint {
  static func / (range: Self, bound: Bound) -> Self {
    (range.lowerBound / bound)...(range.upperBound / bound)
  }

  /// A value whose unit is the `magnitude` of this range,
  /// and whose origin is `lowerBound`.
  ///
  /// - Note: Not clamped between 0 and 1.
  ///
  /// - Returns: `nil` when the range has zero magnitude.
  func normalize(_ bound: Bound) -> Bound? {
    try? (bound - lowerBound) ÷ magnitude
  }
}

public extension Sequence {
  /// The sorted ranges,
  func accumulated<Bound>() -> some Sequence<Element>
  where Element == ClosedRange<Bound> {
    sorted(by: \.lowerBound).accumulated {
      guard $0.overlaps($1) else { return nil }

      // Either $0.lowerBound is lower, or the lower bounds are equivalent.
      return $0.lowerBound...Swift.max($0.upperBound, $1.upperBound)
    }
  }
}

// MARK: - Bound: AdditiveArithmetic
public extension ClosedRange where Bound: AdditiveArithmetic {
  func 🏓(
    by contiguousAdvancement: Bound,
    startingAt start: Bound
  ) -> some Sequence<Bound> {
    guard contains(start) else {
      return AnySequence(AnySequence<Bound>.empty)
    }

    var advancement = contiguousAdvancement

    typealias Operate = (Bound, Bound) -> Bound
    var pingPong: Operate = (+)
    var contiguouslyAdvance: Operate = (-)

    return AnySequence(
      sequence(first: start) { previous in
        pingPongIterate: do {
          defer { advancement += contiguousAdvancement }

          let pingPonged = pingPong(previous, advancement)

          guard self.contains(pingPonged)
          else { break pingPongIterate }

          (pingPong, contiguouslyAdvance) = (contiguouslyAdvance, pingPong)
          return pingPonged
        }

        let contiguouslyAdvanced = contiguouslyAdvance(previous, contiguousAdvancement)
        return self.contains(contiguouslyAdvanced)
          ? contiguouslyAdvanced
          : nil
      }
    )
  }
}

public extension ClosedRange where Bound: AdditiveArithmetic & ExpressibleByIntegerLiteral {
  func 🏓(startingAt start: Bound) -> some Sequence<Bound> {
    🏓(by: 1, startingAt: start)
  }
}

public extension ClosedRange where Bound: BinaryInteger {
  func 🏓(by firstAdvancement: Bound = 1) -> some Sequence<Bound> {
    🏓(by: firstAdvancement, startingAt: (upperBound + lowerBound) / 2)
  }
}

public extension ClosedRange where Bound: FloatingPoint {
  func 🏓(by firstAdvancement: Bound = 1) -> some Sequence<Bound> {
    🏓(by: firstAdvancement, startingAt: (upperBound + lowerBound) / 2)
  }
}

// MARK: -

/// A type that can be represented as a `ClosedRange`.
public protocol ClosedRangeConvertible {
  associatedtype Bound: Comparable
  var closedRange: ClosedRange<Bound> { get }
}


extension ClosedRange: ClosedRangeConvertible {
  public var closedRange: Self { self }
}

extension PartialRangeThrough: ClosedRangeConvertible where Bound: ExpressibleByIntegerLiteral {
  /// From zero to the upper bound, inclusive.
  public var closedRange: ClosedRange<Bound> { .init(self) }
}

extension PartialRangeUpTo: ClosedRangeConvertible
where
  Bound: ExpressibleByIntegerLiteral & Strideable,
  Bound.Stride: SignedNumeric
{
  /// From zero to the upper bound, exclusive.
  public var closedRange: ClosedRange<Bound> { .init(PartialRangeThrough(self)) }
}
