// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "SleepSDK",
    platforms: [
        .iOS(.v14)
    ],
    products: [
        .library(
            name: "SleepSDK",
            targets: ["SleepSDK"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/SDWebImage/SDWebImage.git", from: "5.21.0"),
        .package(url: "https://github.com/SDWebImage/SDWebImageSwiftUI.git", from: "3.1.3")
    ],
    targets: [
        .target(
            name: "SleepSDK",
            dependencies: [
                .product(name: "SDWebImage", package: "SDWebImage"),
                .product(name: "SDWebImageSwiftUI", package: "SDWebImageSwiftUI")
            ],
            path: "Sources",
            resources: [
                           .process("Resources") 
                       ]
        ),
    ]
)

