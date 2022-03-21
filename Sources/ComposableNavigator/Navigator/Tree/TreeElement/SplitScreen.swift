//
//  SplitScreen.swift
//  
//
//  Created by Ken Pham on 2/26/22.
//

import Foundation

public struct SplitScreen: Hashable, Screen {
    public let id: ScreenID
    
    public let column: ActiveNavigationTree
    public let detail: ActiveNavigationTree
    
    public let presentationStyle: ScreenPresentationStyle
    public var hasAppeared: Bool
    
    public func ids () -> Set<ScreenID> {
        column.reduce(into: Set<ScreenID>(detail.ids().union([id])), { acc, path in
            acc.formUnion(path.ids())
        })
    }
    
    public func contents () -> Set<AnyScreen> {
        column.reduce(into: detail.contents(), { acc, path in
            acc.formUnion(path.contents())
        })
    }
    
    public func path (for content: Content) -> ActiveNavigationTree {
        switch content {
        case .column:
            return column
        case .detail:
            return detail
        }
    }
}

extension SplitScreen {
    public enum Content {
        case column, detail
    }
}
