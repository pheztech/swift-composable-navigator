//
//  DetentSheet.swift
//
//  Created by Caleb Friden on 9/28/21.
//  https://gist.github.com/StarLard/5662feeb0b2762e6519e83fa6555fb0d
//  Created by Heath Hwang on 5/16/20.
//  https://gist.github.com/fullc0de/3d68b6b871f20630b981c7b4d51c8373
//  Modified by Ken Pham on 11/20/21.
//

import SwiftUI

// MARK: - Public

@available(iOS 15, *)
public protocol DetentSheetStyle: Hashable {
    var largestUndimmedDetentIdentifier: UISheetPresentationController.Detent.Identifier? { get set }
    var prefersScrollingExpandsWhenScrolledToEdge: Bool { get set }
    var prefersGrabberVisible: Bool { get set }
    var prefersEdgeAttachedInCompactHeight: Bool { get set }
    var widthFollowsPreferredContentSizeWhenEdgeAttached: Bool { get set }
    var preferredCornerRadius: CGFloat? { get set }
    var detents: [UISheetPresentationController.Detent] { get set }
    var allowsDismissalGesture: Bool { get set }
}

@available(iOS 15, *)
public struct DefaultDetentSheetStyle: DetentSheetStyle {
    public var largestUndimmedDetentIdentifier: UISheetPresentationController.Detent.Identifier?
    public var prefersScrollingExpandsWhenScrolledToEdge: Bool
    public var prefersGrabberVisible: Bool
    public var prefersEdgeAttachedInCompactHeight: Bool
    public var widthFollowsPreferredContentSizeWhenEdgeAttached: Bool
    public var preferredCornerRadius: CGFloat?
    public var detents: [UISheetPresentationController.Detent]
    public var allowsDismissalGesture: Bool
    
    public init (largestUndimmedDetentIdentifier: UISheetPresentationController.Detent.Identifier? = nil,
                  prefersScrollingExpandsWhenScrolledToEdge: Bool = true,
                  prefersGrabberVisible: Bool = false,
                  prefersEdgeAttachedInCompactHeight: Bool = false,
                  widthFollowsPreferredContentSizeWhenEdgeAttached: Bool = false,
                  preferredCornerRadius: CGFloat? = nil,
                  detents: [UISheetPresentationController.Detent] = [.medium(), .large()],
                  allowsDismissalGesture: Bool = true
    ) {
        self.largestUndimmedDetentIdentifier = largestUndimmedDetentIdentifier
        self.prefersScrollingExpandsWhenScrolledToEdge = prefersScrollingExpandsWhenScrolledToEdge
        self.prefersGrabberVisible = prefersGrabberVisible
        self.prefersEdgeAttachedInCompactHeight = prefersEdgeAttachedInCompactHeight
        self.widthFollowsPreferredContentSizeWhenEdgeAttached = widthFollowsPreferredContentSizeWhenEdgeAttached
        self.preferredCornerRadius = preferredCornerRadius
        self.detents = detents
        self.allowsDismissalGesture = allowsDismissalGesture
    }
}

@available(iOS 15, *)
public struct AnyDetentSheetStyle: DetentSheetStyle {
    public var largestUndimmedDetentIdentifier: UISheetPresentationController.Detent.Identifier?
    public var prefersScrollingExpandsWhenScrolledToEdge: Bool
    public var prefersGrabberVisible: Bool
    public var prefersEdgeAttachedInCompactHeight: Bool
    public var widthFollowsPreferredContentSizeWhenEdgeAttached: Bool
    public var preferredCornerRadius: CGFloat?
    public var detents: [UISheetPresentationController.Detent]
    public var allowsDismissalGesture: Bool
    
    public init <S: DetentSheetStyle> (_ style: S) {
        self.largestUndimmedDetentIdentifier = style.largestUndimmedDetentIdentifier
        self.prefersScrollingExpandsWhenScrolledToEdge = style.prefersScrollingExpandsWhenScrolledToEdge
        self.prefersGrabberVisible = style.prefersGrabberVisible
        self.prefersEdgeAttachedInCompactHeight = style.prefersEdgeAttachedInCompactHeight
        self.widthFollowsPreferredContentSizeWhenEdgeAttached = style.widthFollowsPreferredContentSizeWhenEdgeAttached
        self.preferredCornerRadius = style.preferredCornerRadius
        self.detents = style.detents
        self.allowsDismissalGesture = style.allowsDismissalGesture
    }
}

@available(iOS 15.0, *)
public extension View {
    /// Adds a sheet which respects `UISheetPresentationController` detents.
    ///
    /// Example:
    /// ```
    /// struct ContentView: View {
    ///     @State
    ///     var selectedDetentIdentifier: UISheetPresentationController.Detent.Identifier? = .medium
    ///     var body: some View {
    ///         Button("Toggle Sheet") {
    ///             withAnimation {
    ///                 isSheetPresented.toggle()
    ///             }
    ///         }.detentSheet(isPresented: $isSheetPresented) {
    ///             Text("Sheet View")
    ///         }.detentSheetStyle(DefaultDetentSheetStyle(largestUndimmedDetentIdentifier: .medium, allowsDismissalGesture: true))
    ///     }
    /// }
    /// ```
    /// - Parameters:
    ///   - isPresented: Whether or not the sheet is presented.
    ///   - selectedDetentIdentifier: The identifier of the most recently selected detent.
    ///   - sheet: The view that is presented as a sheet.
    /// - Returns: A new view with that wraps the receiver and given sheet.
    func detentSheet<Sheet: View>(isPresented: Binding<Bool>,
                                  selectedDetentIdentifier: Binding<UISheetPresentationController.Detent.Identifier?>? = nil,
                                  style: AnyDetentSheetStyle? = nil,
                                  @ViewBuilder sheet: @escaping () -> Sheet) -> some View {
        self.modifier(DetentSheetPresenter(selectedDetentIdentifier: selectedDetentIdentifier,
                                           isSheetPresented: isPresented,
                                           sheet: sheet))
        // - TODO: figure out a better way to set this so that it doesn't override a global default (if any)
            .detentSheetStyle(style ?? AnyDetentSheetStyle(DefaultDetentSheetStyle()))
    }
    
    func detentSheet<Item: Identifiable, Sheet: View> (item: Binding<Item?>,
                                         selectedDetentIdentifier: Binding<UISheetPresentationController.Detent.Identifier?>? = nil,
                                         style: AnyDetentSheetStyle? = nil,
                                         @ViewBuilder sheet: @escaping (Item) -> Sheet) -> some View {
        self.detentSheet(isPresented: .init(get: {
            item.wrappedValue != nil
        }, set: { newValue, transaction in
            guard !newValue else { return }
            item.wrappedValue = nil
        }), selectedDetentIdentifier: selectedDetentIdentifier, style: style, sheet: {
            item.wrappedValue.flatMap(sheet)
        })
    }
    
    func detentSheetStyle<S: DetentSheetStyle> (_ style: S) -> some View {
        self.environment(\.detentSheetStyle, AnyDetentSheetStyle(style))
    }
}


// MARK: - Internal

@available(iOS 15, *)
struct DetentSheetStyleKey: EnvironmentKey {
    static var defaultValue: AnyDetentSheetStyle = AnyDetentSheetStyle(DefaultDetentSheetStyle())
}

extension EnvironmentValues {
    @available(iOS 15, *)
    var detentSheetStyle: AnyDetentSheetStyle {
        get {
            self[DetentSheetStyleKey.self]
        }
        set {
            self[DetentSheetStyleKey.self] = newValue
        }
    }
}

@available(iOS 15.0, *)
struct DetentSheetPresenter<Sheet: View>: ViewModifier {
    @Environment(\.detentSheetStyle) var style
    
    @Binding var isSheetPresented: Bool
    // - TODO: this most likely needs to be reimplemented (also use .constant(nil) if it isn't set)
    var selectedDetentIdentifier: Binding<UISheetPresentationController.Detent.Identifier?>?
    let sheet: () -> Sheet
    
    init (selectedDetentIdentifier: Binding<UISheetPresentationController.Detent.Identifier?>?,
         isSheetPresented: Binding<Bool>,
         @ViewBuilder sheet: @escaping () -> Sheet) {
        self.selectedDetentIdentifier = selectedDetentIdentifier
        self._isSheetPresented = isSheetPresented
        self.sheet = sheet
    }
    
    func body (content: Content) -> some View {
        content.onChange(of: isSheetPresented) { isPresented in
            if isPresented {
                // - TODO: see if this can be done without delay
                DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(100)) {
                    let currentViewController = UIViewController.currentViewController
                    let viewController = SheetViewController(onDismiss: handleDismiss, content: sheet)
                    
                    // - TODO: stlying isnt working
                    viewController.sheetPresentationController?.selectedDetentIdentifier = selectedDetentIdentifier?.wrappedValue
                    viewController.sheetPresentationController?.largestUndimmedDetentIdentifier = style.largestUndimmedDetentIdentifier
                    viewController.sheetPresentationController?.prefersScrollingExpandsWhenScrolledToEdge = style.prefersScrollingExpandsWhenScrolledToEdge
                    viewController.sheetPresentationController?.prefersGrabberVisible = style.prefersGrabberVisible
                    viewController.sheetPresentationController?.prefersEdgeAttachedInCompactHeight = style.prefersEdgeAttachedInCompactHeight
                    viewController.sheetPresentationController?.widthFollowsPreferredContentSizeWhenEdgeAttached = style.widthFollowsPreferredContentSizeWhenEdgeAttached
                    viewController.sheetPresentationController?.preferredCornerRadius = style.preferredCornerRadius
                    viewController.sheetPresentationController?.detents = style.detents
                    
                    currentViewController?.present(viewController, animated: true, completion: nil)
                }
            }
        }
    }
    
    func handleDismiss () {
        self.isSheetPresented = false
    }
}

// MARK: Supporting UIKit Views

final class SheetViewController<Content: View>: UIHostingController<Content> {
    let onDismiss: () -> ()
    
    init (onDismiss: @escaping () -> (), content: @escaping () -> Content) {
        self.onDismiss = onDismiss
        super.init(rootView: content())
    }
    
    @MainActor
    @objc required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillDisappear (_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.onDismiss()
    }
}

// MARK: Preview

#if DEBUG
@available(iOS 15.0, *)
private struct DetentSheetPreviewView: View {
    @State var isSheetPresented = true
    
    @State var selectedDetentID: UISheetPresentationController.Detent.Identifier? = .medium
    
    var body: some View {
        VStack {
            Spacer()
            Button("Toggle Sheet") {
                withAnimation {
                    isSheetPresented.toggle()
                }
            }
            Spacer()
            Text("Background View")
            Spacer()
        }.detentSheet(isPresented: $isSheetPresented,
                      selectedDetentIdentifier: $selectedDetentID) {
            VStack {
                Spacer()
                Button("Toggle Detent") {
                    withAnimation {
                        selectedDetentID = selectedDetentID == .medium ? .large : .medium
                    }
                }
                Spacer()
                Text("Sheet View")
                Spacer()
            }
        }.detentSheetStyle(DefaultDetentSheetStyle(largestUndimmedDetentIdentifier: .medium,
                                                   allowsDismissalGesture: true))
    }
}

@available(iOS 15.0, *)
struct DetentSheet_Previews: PreviewProvider {
    static var previews: some View {
        DetentSheetPreviewView()
    }
}
#endif

extension UIViewController {
    // https://stackoverflow.com/questions/68387187/how-to-use-uiwindowscene-windows-on-ios-15
    static var currentViewController: UIViewController? {
        let window = UIApplication.shared.connectedScenes.filter { $0.activationState == .foregroundActive }.first { $0 is UIWindowScene }.flatMap { $0 as? UIWindowScene }?.windows.first(where: \.isKeyWindow)
        var topController = window?.rootViewController
        // while presented controller exists, set it to the top controller until presentedViewController = nil
        while let presentedViewController = topController?.presentedViewController {
            topController = presentedViewController
        }
        return topController
    }
}
