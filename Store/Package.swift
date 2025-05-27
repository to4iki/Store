// swift-tools-version: 6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "Store",
  defaultLocalization: "en",
  platforms: [
    .iOS(.v16),
    .macOS(.v13),
    .tvOS(.v16),
    .watchOS(.v9),
  ],
  products: [
    .library(
      name: "Store",
      targets: ["Store"]
    )
  ],
  targets: [
    .target(
      name: "Store"
    ),
    .testTarget(
      name: "StoreTests",
      dependencies: ["Store"]
    ),
  ]
)
