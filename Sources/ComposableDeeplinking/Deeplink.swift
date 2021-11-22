import Foundation

/// First class representation of a deeplink based on URLs
public struct Deeplink: Hashable {
    public let components: [DeeplinkComponent]
    public let activity: NSUserActivity?
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
        self.init(components: .init(url: url), activity: nil)
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
        guard let deeplink = url.deeplink(domain, secure: secure) else { return nil }
        self.init(components: .init(url: deeplink), activity: nil)
    }
    
    /// Initialise a deeplink from a User Activity, matching the passed domain.
    /// The UserActivity is also stored so that it can be used by the deeplinker to confirm a valid activity
    /// Example: Confirming a user's location in an App Clip (https://developer.apple.com/documentation/app_clips/confirming_the_user_s_physical_location)
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
    public init? (_ activity: NSUserActivity, domain: String, secure: Bool = true) {
        guard let url = activity.webpageURL?.deeplink(domain, secure: secure) else { return nil }
        self.init(url: url, activity: activity)
    }
    
    init (url: URL, activity: NSUserActivity?) {
        self.init(components: [DeeplinkComponent](url: url), activity: activity)
    }
}

fileprivate extension URL {
    func deeplink (_ domain: String, secure: Bool = true) -> URL? {
        guard self.scheme == "https" else { return nil }
        guard self.host == domain else { return nil }
        // This url will lose its hash values (not sure if that should be kept or not)
        return URL(string: "scheme://" + self.path + "?" + (self.query ?? ""))
    }
}
