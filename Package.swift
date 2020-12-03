// swift-tools-version:4.2

import PackageDescription

#if swift(>=4.0)

let package = Package(
  name: "CAtomics",
  products: [
    .library(name: "CAtomics", targets: ["CAtomics"]),
  ],
  targets: [
    .target(name: "CAtomics", dependencies: []),
    .testTarget(name: "CAtomicsTests", dependencies: ["CAtomics"]),
  ],
  swiftLanguageVersions: [.v3, .v4, .v4_2, .version("5")]
)

#else

let package = Package(
  name: "CAtomics",
  targets: [
    Target(name: "CAtomics", dependencies: []),
  ]
)

#endif
