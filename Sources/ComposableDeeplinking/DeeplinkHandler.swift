import Foundation
import ComposableNavigator

/// Handles deeplinks by building the navigation path based on a deeplink and replacing the current navigation path
public struct DeeplinkHandler {
    private let navigator: Navigator
    private let parser: DeeplinkParser
    
    public init(navigator: Navigator, parser: DeeplinkParser) {
        self.navigator = navigator
        self.parser = parser
    }
    
    @MainActor
    public func handle (deeplink: Deeplink) async {
        if let path = await parser.parse(deeplink) {
            navigator.replace(path: path)
        }
    }
}
