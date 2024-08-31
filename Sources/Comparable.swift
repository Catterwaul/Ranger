public extension Comparable {
  /// - Parameters maximum: A transformation of `minimum`.
  @inlinable static func ... (minimum: Self, maximum: (Self) -> Self) -> ClosedRange<Self> {
    minimum...maximum(minimum)
  }

  /// - Parameters maximum: A transformation of `minimum`.
  @inlinable static func ..< (minimum: Self, maximum: (Self) -> Self) -> Range<Self> {
    minimum..<maximum(minimum)
  }

  
  /// Clamp a value within an inclusive range.
  @inlinable func clamped(to limits: ClosedRange<Self>) -> Self {
    min(Swift.max(limits.lowerBound, self), limits.upperBound)
  }
}

//MARK: - Self: AdditiveArithmetic
/// - Remark: option+
infix operator ±: AdditionPrecedence

public extension Comparable where Self: AdditiveArithmetic {
  /// `bound - range...bound + range`
  /// - Remark: option+
  @inlinable static func ± (bound: Self, range: Self) -> ClosedRange<Self> {
    bound - range...bound + range
  }
}

//MARK: -
public extension Strideable where Stride: SignedInteger {
  @inlinable func clamped(to limits: Range<Self>) -> Self {
    clamped(to: ClosedRange(limits))
  }
}
