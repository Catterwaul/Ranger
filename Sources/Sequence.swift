public extension Sequence where Element: Equatable {
  /// The ranges of in-order elements.
  func ranges(for elements: some Sequence<Element>) -> [ClosedRange<Int>] {
    let (enumerated, getPrevious) = AnySequence.makeIterator(self.enumerated())
    return elements.compactMap { element in
      enumerated.first { $0.element == element }
      .map { start in
        start.offset...(
          enumerated.first { $0.element != element }
            .map { $0.offset - 1 }
          ?? getPrevious()!.offset
        )
      }
    }
  }
}
