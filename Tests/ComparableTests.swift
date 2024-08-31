import Ranger
import Testing

struct ComparableTests {
  @Test func rangeOperators() {
    #expect(2...{ $0 + 3 } == 2...5)
    #expect(2..<{ $0 * 3 } == 2..<6)
  }

  @Test func minusToPlus() {
    #expect(2 ± 3 == -1...5)
  }

  @Test func clamped() {
    #expect("C".clamped(to: "F"..."P") == "F")
  }

  @Test func clamped_Strideable() {
    let indices = [0, 1].indices
    #expect((-3).clamped(to: indices) == 0)
    #expect(22.clamped(to: indices) == 1)
  }
}
