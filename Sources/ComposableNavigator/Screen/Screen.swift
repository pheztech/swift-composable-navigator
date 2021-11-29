/// The Screen protocol is the underlying protocol for navigation path elements. Each navigation path element defines how it is presented.
public protocol Screen: Hashable {
  var presentationStyle: ScreenPresentationStyle { get }
}

public extension Screen {
  /// Erase an instance of a concrete Screen type to AnyScreen
  func eraseToAnyScreen() -> AnyScreen {
    // If the screen was already type-erased, return the type-erased instance instead of wrapping it
    if let anyScreen = self as? AnyScreen {
        return anyScreen
    } else {
        return AnyScreen(self)
    }
  }
    
    // Workaround for: https://github.com/Bahn-X/swift-composable-navigator/issues/74
    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.presentationStyle == rhs.presentationStyle && type(of: lhs) == type(of: rhs)
    }
}
