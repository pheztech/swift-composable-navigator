//
//  SplitNode.swift
//  
//
//  Created by Ken Pham on 2/27/22.
//

import SwiftUI

public struct SplitNode<ColumnBuilder: PathBuilder, DetailBuilder: PathBuilder>: View {
    @Environment(\.currentScreenID) private var screenID
    @EnvironmentObject private var dataSource: Navigator.Datasource
    @Environment(\.navigator) private var navigator
    
    let columnBuilder: ColumnBuilder
    let detailBuilder: DetailBuilder
    
    private var screen: SplitScreen? {
        guard case let .split(screen) = dataSource.navigationTree.component(for: screenID).current else {
            return nil
        }
        
        return screen
    }
    
    public var body: some View {
        NavigationView {
            if let path = screen?.path(for: .column).first, let content = columnBuilder.build(pathElement: path) {
                content
            }
            if let path = screen?.path(for: .detail).first, let content = detailBuilder.build(pathElement: path) {
                content
            }
        }.navigationViewStyle(.columns)
            .navigationBarTitle("") // hide the outer navigation bar on the wrapping TabView
            .navigationBarHidden(true)
            .navigationBarBackButtonHidden(true)
            .uiKitOnAppear {
                if let screen = screen {
                    if !screen.hasAppeared {
                        DispatchQueue.main.async {
                            navigator.didAppear(id: screenID)
                        }
                    }
                }
            }
    }
}

public struct SplitNodeItem<Builder: PathBuilder> {
    public let contentBuilder: Builder
    
    public init (@NavigationTreeBuilder contentBuilder: () -> Builder) {
        self.contentBuilder = contentBuilder()
    }
}

public extension NavigationTree {
    func Split<S: Screen, ColumnBuilder: PathBuilder, DetailBuilder: PathBuilder> (
        _ type: S.Type,
        @NavigationTreeBuilder column: @escaping () -> ColumnBuilder,
        @NavigationTreeBuilder detail: @escaping () -> DetailBuilder
    ) -> _PathBuilder<SplitNode<ColumnBuilder, DetailBuilder>> {
        _PathBuilder { pathElement in
            // - NOTE: this technically lets us to get away with passing the Screen object that called this Split node, but since the path element is a screen
//            guard case .screen(let screen) = pathElement, screen.content.is(S.self) else {
//                return nil
//            }
            guard case .split = pathElement else { return nil }
            
            return SplitNode<ColumnBuilder, DetailBuilder>(columnBuilder: column(), detailBuilder: detail())
        }
    }
}
