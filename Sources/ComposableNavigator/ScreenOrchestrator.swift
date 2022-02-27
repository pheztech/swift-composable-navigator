import SwiftUI
import Combine

public class ScreenOrchestrator: ObservableObject {
    var navigator = Navigator.stub
    
    /// The screen the view is embedded in
    ///
    /// ComposableNavigator makes sure that this value is always filled with the correct value, as long as you embed your content in a `Root` view.
    ///
    /// - SeeAlso: `Root.swift`
    var currentScreen: AnyScreen = {
        struct UnbuildableScreen: Screen {
            let presentationStyle: ScreenPresentationStyle = .push
        }
        return UnbuildableScreen().eraseToAnyScreen()
    }()
    
    /// The `ScreenID` of the screen the view is embedded in
    ///
    /// ComposableNavigator makes sure that this value is always filled with the correct value, as long as you embed your content in a `Root` view.
    ///
    /// - SeeAlso: `Root.swift`
    var currentScreenID: ScreenID = ScreenID()
    
    /// The `ScreenID` of the screen preceding the screen the view is embedded in
    ///
    /// ComposableNavigator makes sure that this value is always filled with the correct value, as long as you embed your content in a `Root` view.
    ///
    /// - SeeAlso: `Root.swift`
    var parentScreen: AnyScreen?
    
    /// The screen preceding the screen the view is embedded in
    ///
    /// ComposableNavigator makes sure that this value is always filled with the correct value, as long as you embed your content in a `Root` view.
    ///
    /// - SeeAlso: `Root.swift`
    var parentScreenID: ScreenID?
}

/// EnvironmentKey identifying the `ScreenOrchestrator` allowing navigation path mutations
private enum ScreenOrchestratorKey: EnvironmentKey {
    static let defaultValue = ScreenOrchestrator()
}

/// EnvironmentKey used to pass down treatSheetDismissAsAppearInPresenter down the view hierarchy
public enum TreatSheetDismissAsAppearInPresenterKey: EnvironmentKey {
  public static let defaultValue: Bool = false
}

public extension EnvironmentValues {
//    var orchestrator: ScreenOrchestrator {
//        get { self[ScreenOrchestratorKey.self] }
//        set { self[ScreenOrchestratorKey.self] = newValue }
//    }
    
  /// The `Navigator` allowing navigation path mutations
  ///
  ///  Can be used to directly navigate from a Vanilla SwiftUI.
  ///
  /// ```swift
  /// struct RootView: View {
  ///   @Environment(\.navigator) var navigator: Navigator
  ///   @Environment(\.currentScreenID) var screenID: ScreenID
  ///
  ///   var body: some View {
  ///    Button(
  ///      action: { navigator.go(to: DetailScreen(), on: screenID) },
  ///      label: Text("Go to DetailScreen")
  ///   }
  /// }
  /// ```
  var navigator: Navigator {
      get { self[ScreenOrchestratorKey.self].navigator }
      set { self[ScreenOrchestratorKey.self].navigator = newValue }
  }

  /// `viewAppeared(animated:)` is not called in SwiftUI and UIKit when a ViewController dismisses a sheet. This environment value allows you to override this behaviour.
  ///
  /// Use `.environment(\.treatSheetDismissAsAppearInPresenter, true)` on your Root view to get onAppear events for sheet dismissals.
  ///
  /// **Example**
  /// ```swift
  ///  Root(
  ///    dataSource: dataSource,
  ///    pathBuilder: pathBuilder
  ///  )
  ///  .environment(\.treatSheetDismissAsAppearInPresenter, true)
  ///  ```
  var treatSheetDismissAsAppearInPresenter: Bool {
    get { self[TreatSheetDismissAsAppearInPresenterKey.self] }
    set { self[TreatSheetDismissAsAppearInPresenterKey.self] = newValue }
  }
    
    /// The `ScreenID` of the screen preceding the screen the view is embedded in
    var parentScreenID: ScreenID? {
        get { self[ScreenOrchestratorKey.self].parentScreenID }
        set { self[ScreenOrchestratorKey.self].parentScreenID = newValue }
    }

    /// The `ScreenID` of the screen the view is embedded in
    var currentScreenID: ScreenID {
        get { self[ScreenOrchestratorKey.self].currentScreenID }
        set { self[ScreenOrchestratorKey.self].currentScreenID = newValue }
    }

    /// The `Screen` preceding the screen the view is embedded in
    var parentScreen: AnyScreen? {
        get { self[ScreenOrchestratorKey.self].parentScreen }
        set { self[ScreenOrchestratorKey.self].parentScreen = newValue }
    }

    /// The `Screen` the view is embedded in
    var currentScreen: AnyScreen {
        get { self[ScreenOrchestratorKey.self].currentScreen }
        set { self[ScreenOrchestratorKey.self].currentScreen = newValue }
    }
}

// MARK: - Navigator Extension

/*
 Helper methods to be able to navigate from within ObservableObjects.
 Since we don't really know what screen the app will be on when the method
 is called, the method will get it for us from the path. The currentScreen
 from the EnvironmentValue cannot be used since it can be out of date.
 But it can't be converted to a computed variable from the path since its
 needed to keep the screen from being dismissed when the app is moved to the
 foreground.
 */
public extension Navigator {
    private var currentScreenID: ScreenID? {
        navigationTree().current.last?.id
    }
   
    // - TODO: add auto dismiss for sheets that dont allow navigation?
    /// - returns: Indicates if the navigation was successful
    @discardableResult
    func go<S: Screen> (to screen: S) -> Bool {
        guard let currentScreenID = self.currentScreenID else { return false }
        self.go(to: screen, on: currentScreenID)
        return true
    }
    
    @discardableResult
    func go (to path: [AnyScreen]) -> Bool {
        guard let currentScreenID = self.currentScreenID else { return false }
        self.go(to: path.map { .screen($0.eraseToAnyScreen()) }, on: currentScreenID)
        return true
    }
    
    /// - returns: Indicates if the dismissal was successful
    @discardableResult
    func dismiss () -> Bool {
        guard let currentScreenID = self.currentScreenID else { return false }
        self.dismiss(id: currentScreenID)
        return true
    }
}
