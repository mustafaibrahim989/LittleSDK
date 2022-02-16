// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "LittleSDK",
    platforms: [
        // Only add support for iOS 11 and up.
        .iOS(.v11)
    ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "LittleSDK",
            targets: ["LittleSDK"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        .package(url: "https://github.com/SwiftKickMobile/SwiftMessages", .upToNextMajor(from: "9.0.0")),
        .package(url: "https://github.com/ninjaprox/NVActivityIndicatorView.git", .upToNextMajor(from: "5.0.0")),
        .package(url: "https://github.com/omerfarukozturk/UIView-Shimmer.git", .upToNextMajor(from: "1.0.0")),
        .package(url: "https://github.com/Minitour/EasyNotificationBadge.git", .upToNextMajor(from: "1.0.0")),
        .package(url: "https://github.com/firebase/firebase-ios-sdk.git", .upToNextMajor(from: "8.0.0")),
        .package(url: "https://github.com/MessageKit/MessageKit", .upToNextMajor(from: "3.0.0")),
        .package(url: "https://github.com/YAtechnologies/GoogleMaps-SP.git", .upToNextMajor(from: "6.0.0")),
        .package(url: "https://github.com/Alamofire/Alamofire.git", .upToNextMajor(from: "5.0.0")),
        .package(url: "https://github.com/SDWebImage/SDWebImage.git", .upToNextMajor(from: "5.0.0")),
        .package(url: "https://github.com/hackiftekhar/IQKeyboardManager", .upToNextMajor(from: "6.0.5")),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "LittleSDK",
            dependencies: [],
            path: "Sources/LittleSDK"),
        .testTarget(
            name: "LittleSDKTests",
            dependencies: ["LittleSDK"],
            path: "Tests/LittleSDKTests"),
    ]
)
