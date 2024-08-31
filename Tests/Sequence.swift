import Ranger
import Testing

struct SequenceTests {
  @Test func rangesOf() {
    #expect(
      [0, 1, .min, .min, 2, 2, .min, 3, 3, 3, .min, 4, 4, .min, 5]
        .ranges(for: [1, 2, 3, 4, 5])
      == [1...1, 4...5, 7...9, 11...12, 14...14]
    )
  }
}
