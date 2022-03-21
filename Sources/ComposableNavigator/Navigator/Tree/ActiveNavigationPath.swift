public typealias ActiveNavigationPath = [ActiveNavigationPathElement]

public extension ActiveNavigationPath {
  func toNavigationTree(screenID: () -> ScreenID) -> ActiveNavigationTree {
      self.map { $0.toNavigationTreeElement(screenID: screenID) }
  }
}

public indirect enum ActiveNavigationPathElement: Hashable {
  case screen(AnyScreen)
  case tabbed(ActiveTab)
    case split(SplitPath)

  public static func tabbed<A: Activatable, S: Screen>(active: A, content: S) -> Self {
    .tabbed(
      .init(
        active: active,
        path: [.screen(content.eraseToAnyScreen())]
      )
    )
  }
   
    public static func split (column: ActiveNavigationPath, detail: ActiveNavigationPath) -> Self {
        .split(SplitPath(column: column, detail: detail))
    }
    
    public static func split<Column: Screen, Detail: Screen> (column: Column, detail: Detail) -> Self {
        .split(column: [ .screen(column.eraseToAnyScreen()) ], detail: [ .screen(detail.eraseToAnyScreen()) ])
    }

  var presentationStyle: ScreenPresentationStyle {
    switch self {
    case let .screen(screen):
      return screen.presentationStyle
    case let .tabbed(screen):
      return screen.path.first?.presentationStyle ?? .push
    case .split:
        return .push
    }
  }

  func toNavigationTreeElement(screenID: () -> ScreenID) -> ActiveNavigationTreeElement {
    switch self {
    case let .screen(screen):
      return .screen(
        IdentifiedScreen(
          id: screenID(),
          content: screen,
          hasAppeared: false
        )
      )
    case let .tabbed(screen):
      return .tabbed(
        TabScreen(
          id: screenID(),
          activeTab: TabScreen.Tab(
            id: screen.id,
            path: screen.path.toNavigationTree(screenID: screenID)
          ),
          inactiveTabs: [],
          presentationStyle: screen.path.first?.presentationStyle ?? .push,
          hasAppeared: false
        )
      )
    case let .split(screen):
        return .split(
            .init(id: screenID(), column: screen.columnPath.toNavigationTree(screenID: screenID), detail: screen.detailPath.toNavigationTree(screenID: screenID), presentationStyle: .push, hasAppeared: false)
        )
    }
  }
}

// MARK: - Tabbed
public extension ActiveNavigationPathElement {
  struct ActiveTab: Hashable {
    let id: AnyActivatable
    let path: ActiveNavigationPath

    public init<A: Activatable>(active: A, path: ActiveNavigationPath) {
      self.id = active.eraseToAnyActivatable()
      self.path = path
    }
  }
    
    struct SplitPath: Hashable {
        let columnPath: ActiveNavigationPath
        let detailPath: ActiveNavigationPath
        
        public init (column: ActiveNavigationPath, detail: ActiveNavigationPath) {
            self.columnPath = column
            self.detailPath = detail
        }
    }
}
