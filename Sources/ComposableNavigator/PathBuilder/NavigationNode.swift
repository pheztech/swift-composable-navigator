import SwiftUI

/// Screen container view, taking care of push and sheet bindings.
public struct NavigationNode<Content: View, Successor: View>: View {
  private struct SuccessorView: Identifiable, View {
    let pathElement: NavigationPathElement
    let body: Successor

    var id: ScreenID { pathElement.id }
    var presentationStyle: ScreenPresentationStyle {
      pathElement.content.presentationStyle
    }

    init(successor: NavigationPathElement, content: Successor) {
      self.pathElement = successor
      self.body = content
    }
  }

  @Environment(\.currentScreenID) private var screenID
  @Environment(\.currentScreen) private var currentScreen
  @Environment(\.navigator) private var navigator
  @Environment(\.treatSheetDismissAsAppearInPresenter) private var treatSheetDismissAsAppearInPresenter
  @EnvironmentObject private var dataSource: Navigator.Datasource


  let content: Content
  let onAppear: (Bool) -> Void
  let buildSuccessor: (NavigationPathElement) -> Successor?

  public init(
    content: Content,
    onAppear: @escaping (Bool) -> Void,
    buildSuccessor: @escaping (NavigationPathElement) -> Successor?
  ) {
    self.content = content
    self.onAppear = onAppear
    self.buildSuccessor = buildSuccessor
  }

  public var body: some View {
    content
      .detentSheet(item: self.detentSheetBinding, style: self.detentSheetStyling, sheet: build(successor:))
      .sheet(
        item: sheetBinding,
        content: build(successor:)
      )
      .overlay(
        NavigationLink(
          destination: push.flatMap(build(successor:)),
          isActive: pushIsActive,
          label: { EmptyView() }
        )
      )
      .uiKitOnAppear {
        if let screen = self.screen {
          self.onAppear(!screen.hasAppeared)

          if !screen.hasAppeared {
            DispatchQueue.main.async {
              navigator.didAppear(id: screenID)
            }
          }
        }
      }
  }

  private var screen: NavigationPathElement? {
    dataSource.path.component(for: screenID).current
  }

  private var successorView: SuccessorView? {
    let successorUpdate = dataSource.path.successor(of: screenID)
    return successorUpdate.current.flatMap { successor in
      buildSuccessor(successor).flatMap { content in
        SuccessorView(successor: successor, content: content)
      }
    }
  }

  private var pushIsActive: Binding<Bool> {
    Binding(
      get: {
        guard case .push = successorView?.presentationStyle,
              screen?.hasAppeared ?? false
        else {
          return false
        }

        return true
      },
      set: { isActive in
        guard !isActive,
              let successor = successorView?.pathElement,
              successor.hasAppeared else {
          return
        }
        navigator.dismiss(id: successor.id)
      }
    )
  }

  private var push: SuccessorView? {
    guard case .push = successorView?.presentationStyle else {
      return nil
    }

    return successorView
  }
    
    private var detentSheetStyling: AnyDetentSheetStyle? {
        guard case .detentSheet(_, let style) = successorView?.presentationStyle else { return nil }
        return style
    }
    
    private var detentSheetBinding: Binding<SuccessorView?> {
        Binding {
            guard case .some(.detentSheet) = successorView?.presentationStyle, screen?.hasAppeared ?? false else { return nil }
            return successorView
        } set: { value in
            if let screen = self.screen, !screen.hasAppeared {
                DispatchQueue.main.async {
                    navigator.didAppear(id: self.screenID)
                }
            }
            
            guard value == nil, let successor = successorView?.pathElement, successor.hasAppeared else { return }
            
            if self.treatSheetDismissAsAppearInPresenter {
                self.onAppear(false)
            }
            navigator.dismiss(id: successor.id)
        }
    }

  private var sheetBinding: Binding<SuccessorView?> {
    Binding(
      get: { () -> SuccessorView? in
        guard case .some(.sheet) = successorView?.presentationStyle,
              screen?.hasAppeared ?? false
        else {
          return nil
        }

        return successorView
      },
      set: { value in
        if let screen = screen, !screen.hasAppeared {
          DispatchQueue.main.async {
            navigator.didAppear(id: screenID)
          }
        }

        guard value == nil,
              let successor = successorView?.pathElement,
              successor.hasAppeared else {
          return
        }

        if treatSheetDismissAsAppearInPresenter { onAppear(false) }
        navigator.dismiss(id: successor.id)
      }
    )
  }
  
    @ViewBuilder
    private func build(successor: SuccessorView) -> some View {
        let content = successor
            .environment(\.parentScreenID, screenID)
            .environment(\.parentScreen, currentScreen)
            .environment(\.currentScreenID, successor.pathElement.id)
            .environment(\.currentScreen, successor.pathElement.content)
            .environment(\.navigator, navigator)
            .environment(\.treatSheetDismissAsAppearInPresenter, treatSheetDismissAsAppearInPresenter)
            .environmentObject(dataSource)

        switch successor.pathElement.content.presentationStyle {
        case .push, .sheet(allowsPush: false), .detentSheet(allowsPush: false, _):
            content
        case .sheet(allowsPush: true), .detentSheet(allowsPush: true, _):
            NavigationView { content }
                .navigationViewStyle(StackNavigationViewStyle())
        }
    }
}
