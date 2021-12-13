// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let snapshotFolders = [
  "PathBuilder/__Snapshots__",
  "NavigationTree/__Snapshots__",
  "Screen/__Snapshots__",
]

let testGybFiles = [
  "NavigationTree/NavigationTreeBuilder+AnyOf.swift.gyb"
]

let package = Package(
  name: "swift-composable-navigator",
  platforms: [
    .iOS(.v15),
    .macOS(.v12),
    .tvOS(.v15),
    .watchOS(.v8),
  ],
  products: [
    .library(
      name: "ComposableNavigator",
      targets: ["ComposableNavigator"]
    ),
    .library(
      name: "ComposableDeeplinking",
      targets: ["ComposableDeeplinking"]
    ),
  ],
  dependencies: [
    .package(url: "https://github.com/shibapm/Rocket", from: "1.1.0"), // dev
    .package(name: "SnapshotTesting", url: "https://github.com/pointfreeco/swift-snapshot-testing.git", from: "1.8.2"), // dev
  ],
  targets: [
    .target(
      name: "ComposableNavigator",
      dependencies: [],
      exclude: [
        "NavigationTree/NavigationTreeBuilder+AnyOf.swift.gyb",
        "NavigationTree/NavigationTreeBuilder+Tabbed.swift.gyb",
        "PathBuilder/PathBuilders/PathBuilder+AnyOf.swift.gyb",
        "PathBuilder/Nodes/Tabbed/TabbedNode.swift.gyb"
      ]
    ),
    .target(
      name: "ComposableDeeplinking",
      dependencies: [
        .target(name: "ComposableNavigator"),
      ]
    ),
    .testTarget(name: "ComposableNavigatorTests", dependencies: ["ComposableNavigator", "SnapshotTesting"], exclude: testGybFiles + snapshotFolders), // dev
    .testTarget(name: "ComposableDeeplinkingTests", dependencies: ["ComposableDeeplinking"]), // dev
  ]
)

#if canImport(PackageConfig)
import PackageConfig

let config = PackageConfiguration(
  [
    "rocket": [
      "pre_release_checks": [
        "clean_git"
      ],
      "before": [
        // "make test",
        // "make cleanup",
      ]
    ]
  ]
)
.write()
#endif
