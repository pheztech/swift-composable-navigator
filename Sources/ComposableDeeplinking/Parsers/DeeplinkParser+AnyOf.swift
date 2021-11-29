public extension DeeplinkParser {
  /// Any of the listed deeplink parsers might take care of parsing the deeplink
  static func anyOf(
    _ parsers: [DeeplinkParser]
  ) -> DeeplinkParser {
    DeeplinkParser(
      parser: { deeplink in
        for parser in parsers {
          if let path = await parser.parse(deeplink) {
            return path
          }
        }
        return nil
      }
    )
  }

  /// Any of the listed deeplink parsers might take care of parsing the deeplink
  static func anyOf(
    _ parsers: DeeplinkParser...
  ) -> DeeplinkParser {
    Self.anyOf(parsers)
  }
}
