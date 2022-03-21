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
    // This breaks tabbed view since it doesnt check to see if the tabs match (i.e. 0 inactiveTabs == 1 inactiveTabs)
    // - TODO: theres definitely a better way to handle this but for now its gonna be jank
//    static func == (lhs: Self, rhs: Self) -> Bool {
//        if (type(of: lhs) == TabScreen.self && type(of: rhs) == TabScreen.self) ||
//            (type(of: lhs) == SplitScreen.self && type(of: rhs) == SplitScreen.self) {
//            return lhs.hashValue == rhs.hashValue
//        } else {
//            return lhs.presentationStyle == rhs.presentationStyle && type(of: lhs) == type(of: rhs)
//            return lhs.hashValue == rhs.hashValue
//        }
//    }
}
