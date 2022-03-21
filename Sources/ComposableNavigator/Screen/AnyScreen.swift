/// Type-erased representation of `Screen` objects
public struct AnyScreen: Hashable, Screen {
  let screen: AnyHashable
  public let presentationStyle: ScreenPresentationStyle

  public init<S: Screen>(_ route: S) {
    self.screen = route
    self.presentationStyle = route.presentationStyle
  }

  public func unwrap<S: Screen>() -> S? {
    screen as? S
  }

  public func `is`<S: Screen>(_ screenType: S.Type) -> Bool {
    (screen as? S) != nil
  }
}

public extension AnyScreen {
    /// - NOTE: this was added as a work around for screens not reloading when Screens store the ViewModel, it breaks navigation for tabbed views so its removed for now
    /// https://github.com/Bahn-X/swift-composable-navigator/issues/74
//    static func == (lhs: Self, rhs: Self) -> Bool {
//        lhs.screen == rhs.screen
//        lhs.hashValue == rhs.hashValue
//    }
}
