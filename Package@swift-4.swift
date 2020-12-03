// swift-tools-version:4.0

import PackageDescription

let package = Package(
  name: "SwiftAtomics",
  products: [
    .library(name: "CAtomics", type: .static, targets: ["CAtomics"]),
  ],
  targets: [
    .target(name: "CAtomics", dependencies: []),
    .testTarget(name: "CAtomicsTests", dependencies: ["CAtomics"]),
  ],
  swiftLanguageVersions: [3, 4, 5]
)
