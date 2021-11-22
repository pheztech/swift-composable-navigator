//
//  DetentSheet.swift
//  StarLardKit
//  https://gist.github.com/StarLard/5662feeb0b2762e6519e83fa6555fb0d
//
//  Created by Caleb Friden on 9/28/21.
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
    public var largestUndimmedDetentIdentifier: UISheetPresentationController.Detent.Identifier? = nil
    public var prefersScrollingExpandsWhenScrolledToEdge: Bool = true
    public var prefersGrabberVisible: Bool = false
    public var prefersEdgeAttachedInCompactHeight: Bool = false
    public var widthFollowsPreferredContentSizeWhenEdgeAttached: Bool = false
    public var preferredCornerRadius: CGFloat? = nil
    public var detents: [UISheetPresentationController.Detent] = [.medium(), .large()]
    public var allowsDismissalGesture: Bool = true
    
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
    init(selectedDetentIdentifier: Binding<UISheetPresentationController.Detent.Identifier?>?,
         isSheetPresented: Binding<Bool>,
         @ViewBuilder sheet: @escaping () -> Sheet) {
        self.selectedDetentIdentifier = selectedDetentIdentifier
        self._isSheetPresented = isSheetPresented
        self.sheet = sheet
    }
    
    func body(content: Content) -> some View {
        DetentSheetStack(isSheetPresented: $isSheetPresented,
                         selectedDetentIdentifier: selectedDetentIdentifier,
                         background: { content },
                         sheet: sheet)
        // keeps the background content from not taking up the whole screen
            .ignoresSafeArea()
    }
    
    @Binding var isSheetPresented: Bool
    var selectedDetentIdentifier: Binding<UISheetPresentationController.Detent.Identifier?>?
    let sheet: () -> Sheet
}

// MARK: Wrapping View

@available(iOS 15.0, *)
struct DetentSheetStack<Background: View, Sheet: View>: UIViewControllerRepresentable {
    typealias UIViewControllerType = UIViewController
    
    @Binding var isSheetPresented: Bool
    var selectedDetentIdentifier: Binding<UISheetPresentationController.Detent.Identifier?>?
    let background: Background
    let sheet: () -> Sheet
    
    init(isSheetPresented: Binding<Bool>,
         selectedDetentIdentifier: Binding<UISheetPresentationController.Detent.Identifier?>?,
         @ViewBuilder background: () -> Background,
         @ViewBuilder sheet: @escaping () -> Sheet) {
        self.selectedDetentIdentifier = selectedDetentIdentifier
        self._isSheetPresented = isSheetPresented
        self.background = background()
        self.sheet = sheet
    }
    
    func makeCoordinator() -> Coordinator<Background, Sheet> {
        Coordinator(self)
    }
    
    func makeUIViewController(context: Context) -> UIViewController {
        configureSheet(context: context)
        context.coordinator.sheetViewController.isModalInPresentation = !context.environment.detentSheetStyle.allowsDismissalGesture
        return context.coordinator.sheetPresentingViewController
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        configureSheet(context: context)
    }
    
    private func configureSheet(context: Context) {
        guard let sheetPresentationController = context.coordinator.sheetViewController.sheetPresentationController else { return }
        /// commented out code would require the end user to set the binding value in a `withAnimation` block
        let animated = /* context.transaction.animation != nil && */ !context.transaction.disablesAnimations
        let presentingViewController = context.coordinator.sheetPresentingViewController
        let configure = {
            sheetPresentationController.selectedDetentIdentifier = selectedDetentIdentifier?.wrappedValue
            sheetPresentationController.largestUndimmedDetentIdentifier = context.environment.detentSheetStyle.largestUndimmedDetentIdentifier
            sheetPresentationController.prefersScrollingExpandsWhenScrolledToEdge = context.environment.detentSheetStyle.prefersScrollingExpandsWhenScrolledToEdge
            sheetPresentationController.prefersGrabberVisible = context.environment.detentSheetStyle.prefersGrabberVisible
            sheetPresentationController.prefersEdgeAttachedInCompactHeight = context.environment.detentSheetStyle.prefersEdgeAttachedInCompactHeight
            sheetPresentationController.widthFollowsPreferredContentSizeWhenEdgeAttached = context.environment.detentSheetStyle.widthFollowsPreferredContentSizeWhenEdgeAttached
            sheetPresentationController.preferredCornerRadius = context.environment.detentSheetStyle.preferredCornerRadius
            sheetPresentationController.detents = context.environment.detentSheetStyle.detents
            sheetPresentationController.delegate = context.coordinator
        }
        if animated {
            sheetPresentationController.animateChanges {
                configure()
            }
        } else {
            configure()
        }
        presentingViewController.shouldSheetBeInitiallyPresented = isSheetPresented
        presentingViewController.setSheetPresented(isSheetPresented, animated: animated)
    }
    
    final class Coordinator<Background: View, Sheet: View>: NSObject, UISheetPresentationControllerDelegate, SheetViewControllerDelegate {
        var parent: DetentSheetStack<Background, Sheet>
        let sheetViewController: SheetViewController<Sheet>
        let sheetPresentingViewController: SheetPresentingViewController<Background>
        
        init(_ sheetPresenter: DetentSheetStack<Background, Sheet>) {
            self.parent = sheetPresenter
            let sheetHostingController = SheetViewController(parent.sheet)
            self.sheetViewController = sheetHostingController
            self.sheetPresentingViewController = SheetPresentingViewController(rootView: parent.background,
                                                                          shouldSheetBeInitiallyPresented: parent.isSheetPresented,
                                                                          sheetViewController: sheetHostingController)
            super.init()
        }
        
        func sheetPresentationControllerDidChangeSelectedDetentIdentifier(_ sheetPresentationController: UISheetPresentationController) {
            parent.selectedDetentIdentifier?.wrappedValue = sheetPresentationController.selectedDetentIdentifier
        }
        
        func sheetViewControllerDidDismiss<Content>(_ sheetViewController: SheetViewController<Content>) where Content : View {
            parent.isSheetPresented = false
        }
        
        func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
            parent.isSheetPresented = false
        }
    }
}

// MARK: Supporting UIKit Views

final class SheetPresentingViewController<Content: View>: UIHostingController<Content> {
    var sheetViewController: UIViewController
    var isSheetPresented: Bool { sheetViewController.presentingViewController != nil }
    
    var shouldSheetBeInitiallyPresented: Bool
    
    private var viewHasAppeared = false
    
    init(rootView: Content, shouldSheetBeInitiallyPresented: Bool, sheetViewController: UIViewController) {
        self.shouldSheetBeInitiallyPresented = shouldSheetBeInitiallyPresented
        self.sheetViewController = sheetViewController
        super.init(rootView: rootView)
    }
    
    @MainActor
    @objc required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        guard !self.viewHasAppeared else { return }
        self.viewHasAppeared = true
        self.setSheetPresented(shouldSheetBeInitiallyPresented, animated: animated)
    }
    
    func setSheetPresented(_ presentSheet: Bool, animated: Bool) {
        guard self.viewHasAppeared else { return }
        if presentSheet, !self.isSheetPresented {
            present(sheetViewController, animated: animated, completion: nil)
        } else if !presentSheet, self.isSheetPresented {
            sheetViewController.dismiss(animated: animated, completion: nil)
        }
    }
}

protocol SheetViewControllerDelegate: AnyObject {
    func sheetViewControllerDidDismiss<Content: View>(_ sheetViewController: SheetViewController<Content>)
}

final class SheetViewController<Content: View>: UIHostingController<Content> {
    weak var delegate: SheetViewControllerDelegate?

    var content: () -> Content
    
    init (_ content: @escaping () -> Content) {
        self.content = content
        super.init(rootView: content())
    }
    
    @MainActor
    @objc required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // redraw content before appearing
    override func viewWillAppear (_ animated: Bool) {
        super.viewWillAppear(animated)
        self.rootView = content()
    }
    
    override func dismiss(animated: Bool, completion: (() -> Void)? = nil) {
        super.dismiss(animated: animated, completion: completion)
        delegate?.sheetViewControllerDidDismiss(self)
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
