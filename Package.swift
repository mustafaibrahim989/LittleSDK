// swift-tools-version:5.2
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
        .package(url: "https://github.com/SwiftKickMobile/SwiftMessages", from: "9.0.0"),
        .package(url: "https://github.com/ninjaprox/NVActivityIndicatorView.git", from: "5.0.0"),
        .package(url: "https://github.com/omerfarukozturk/UIView-Shimmer.git", from: "1.0.0"),
        .package(url: "https://github.com/Minitour/EasyNotificationBadge.git", from: "1.0.0"),
        .package(url: "https://github.com/firebase/firebase-ios-sdk.git", from: "8.0.0"),
        .package(url: "https://github.com/MessageKit/MessageKit", from: "3.0.0"),
        .package(url: "https://github.com/YAtechnologies/GoogleMaps-SP.git", from: "6.0.0"),
        .package(url: "https://github.com/Alamofire/Alamofire.git", from: "5.0.0"),
        .package(url: "https://github.com/SDWebImage/SDWebImage.git", from: "5.0.0"),
        .package(url: "https://github.com/hackiftekhar/IQKeyboardManager", from: "6.0.5"),
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
