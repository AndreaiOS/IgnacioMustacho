// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "IgnacioCore", products: [.library(name: "IgnacioCore", targets: ["IgnacioCore"])],
    targets: [
        .target(name: "IgnacioCore", path: "Sources/Domain"),
        .testTarget(name: "DomainTests", dependencies: ["IgnacioCore"], path: "Tests/DomainTests"),
    ])
