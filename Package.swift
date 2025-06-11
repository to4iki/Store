// swift-tools-version: 6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "Store",
  defaultLocalization: "en",
  platforms: [
    .iOS(.v17),
    .macOS(.v14),
    .tvOS(.v17),
    .watchOS(.v10),
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
