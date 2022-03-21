extension ActiveNavigationTree {
  func replaceContent(of id: ScreenID, with newContent: AnyScreen) -> ActiveNavigationTree {
    map { element in
      element.replaceContent(of: id, with: newContent)
    }
  }
}

extension ActiveNavigationTreeElement {
  func replaceContent(of id: ScreenID, with newContent: AnyScreen) -> ActiveNavigationTreeElement {
    switch self {
    case .screen(let screen) where id == screen.id:
      return .screen(
        IdentifiedScreen(
          id: screen.id,
          content: newContent,
          hasAppeared: screen.hasAppeared
        )
      )
    case .screen(let screen):
      return .screen(screen)
    case .tabbed(let screen) where id == screen.id:
      return .screen(
        IdentifiedScreen(
          id: screen.id,
          content: newContent,
          hasAppeared: screen.hasAppeared
        )
      )
    case .tabbed(let screen):
      return .tabbed(screen.replaceContent(of: id, with: newContent))
    case .split(let screen) where id == screen.id:
        return .screen(.init(id: screen.id, content: newContent, hasAppeared: screen.hasAppeared))
    case .split(let screen):
        return .split(screen.replaceContent(of: id, with: newContent))
    }
  }
}

extension TabScreen {
  func replaceContent(of id: ScreenID, with newContent: AnyScreen) -> TabScreen {
    return TabScreen(
      id: self.id,
      activeTab: Tab(
        id: activeTab.id,
        path: activeTab.path.replaceContent(of: id, with: newContent)
      ),
      inactiveTabs: Set(
        inactiveTabs.map { inactiveTab in
          Tab(
            id: inactiveTab.id,
            path: inactiveTab.path.replaceContent(of: id, with: newContent)
          )
        }
      ),
      presentationStyle: presentationStyle,
      hasAppeared: hasAppeared
    )
  }
}

extension SplitScreen {
    func replaceContent (of id: ScreenID, with newContent: AnyScreen) -> SplitScreen {
        return SplitScreen(id: self.id, column: column.replaceContent(of: id, with: newContent), detail: detail.replaceContent(of: id, with: newContent), presentationStyle: presentationStyle, hasAppeared: hasAppeared)
    }
}
