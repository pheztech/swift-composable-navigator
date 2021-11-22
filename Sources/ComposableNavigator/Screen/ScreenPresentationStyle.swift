/// Defines how a screen is presented
public enum ScreenPresentationStyle: Hashable {
    /// The screen is presented as a push, analogous to `UINavigationController.pushViewController(_ vc:)`
    case push

    /// The screen is presented as a sheet,  analogous to `UIViewController.present(vc:, animated:, completion:)`
    ///
    /// If `allowsPush:` is set to false, the sheet content is not embedded in a `NavigationView` and therefore pushes do not work.
    case sheet(allowsPush: Bool = true)
    
    case detentSheet(allowsPush: Bool = true, style: AnyDetentSheetStyle = AnyDetentSheetStyle(DefaultDetentSheetStyle()))
}

public extension ScreenPresentationStyle {
    static func detentSheetWithStyle<S: DetentSheetStyle> (allowsPush: Bool = true, style: S) -> Self {
        .detentSheet(allowsPush: allowsPush, style: AnyDetentSheetStyle(style))
    }
}
