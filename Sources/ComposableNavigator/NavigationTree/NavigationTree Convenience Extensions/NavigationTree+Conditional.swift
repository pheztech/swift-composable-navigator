import SwiftUI

extension NavigationTree {
    public func If<S: Screen, IfBuilder: PathBuilder, Else: PathBuilder>(
        _ screen: S.Type,
        _ condition: @escaping () -> Bool,
        @NavigationTreeBuilder screen pathBuilder: () -> IfBuilder,
        @NavigationTreeBuilder else: () -> Else
    ) -> _PathBuilder<EitherAB<IfBuilder.Content, Else.Content>> {
        PathBuilders.if(condition, then: pathBuilder(), else: `else`())
    }
    
    
  public func If<S: Screen, IfBuilder: PathBuilder, Else: PathBuilder>(
    @NavigationTreeBuilder screen pathBuilder: @escaping (S) -> IfBuilder,
    @NavigationTreeBuilder else: () -> Else
  ) -> _PathBuilder<EitherAB<IfBuilder.Content, Else.Content>> {
    PathBuilders.if(screen: pathBuilder, else: `else`())
  }

  public func If<S: Screen, IfBuilder: PathBuilder>(
    @NavigationTreeBuilder screen pathBuilder: @escaping (S) -> IfBuilder
  ) -> _PathBuilder<EitherAB<IfBuilder.Content, Never>> {
    If(screen: pathBuilder, else: { PathBuilders.empty })
  }
}
