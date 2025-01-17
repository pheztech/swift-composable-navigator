public extension DeeplinkParser {
  /// Empty deeplink parses, not parsing any deeplink
  ///
  /// Can be used as a stub value
  static let empty = DeeplinkParser(
    parser: { _ in nil }
  )
}
