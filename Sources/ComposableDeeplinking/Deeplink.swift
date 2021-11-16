import Foundation

/// First class representation of a deeplink based on URLs
public struct Deeplink: Hashable {
    public let components: [DeeplinkComponent]
}

extension Deeplink {
    /// Initialise a deeplink from a URL, matching the passed Scheme
    ///
    /// Typically used to parse deeplinks from URL scheme triggers
    ///
    /// # Example
    /// ```swift
    /// // scheme://name?flag&value=123
    /// let url = URL(string: "scheme://name?flag&value=123")!
    ///
    /// let deeplink = Deeplink(
    ///   url: url,
    ///   matching: "scheme"
    /// )
    ///
    /// deeplink.components == [
    ///   DeeplinkComponent(
    ///     name: "name",
    ///     arguments: [
    ///       "flag": .flag,
    ///       "value": "123"
    ///     ]
    ///   )
    /// ] // True
    /// ```
    public init? (url: URL, scheme: String) {
        guard url.scheme == scheme else { return nil }

        self.components = [DeeplinkComponent](url: url)
    }
    
    /// Initialise a deeplink from a URL, matching the passed domain
    ///
    /// Typically used to parse deeplinks from universal links.
    /// By default, HTTPS is required. To allow unsecure links, set `secure` to false.
    ///
    /// # Example
    /// ```swift
    /// // http(s)://example.com/name?flag&value=123
    /// let url = URL(string: "http(s)://example.com/name?flag&value=123")!
    ///
    /// let deeplink = Deeplink(
    ///   url: url,
    ///   domain: "example.com"
    /// )
    ///
    /// deeplink.components == [
    ///   DeeplinkComponent(
    ///     name: "name",
    ///     arguments: [
    ///       "flag": .flag,
    ///       "value": "123"
    ///     ]
    ///   )
    /// ] // True
    /// ```
    public init? (url: URL, domain: String, secure: Bool = true) {
        guard url.scheme == "https" else { return nil }
        guard url.host == domain else { return nil }
        // This url will lose its hash values (not sure if that should be kept or not)
        guard let deeplink = URL(string: "scheme://" + url.path + "?" + (url.query ?? "")) else { return nil }

        self.components = [DeeplinkComponent](url: deeplink)
    }
}
