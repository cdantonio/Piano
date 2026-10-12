// swift-tools-version: 5.8

import PackageDescription
import AppleProductTypes

let package = Package(
    name: "Piano",
    platforms: [
        .iOS("16.0")
    ],
    products: [
        .iOSApplication(
            name: "Piano",
            targets: ["AppModule"],
            bundleIdentifier: "com.cdantonio.piano",
            displayVersion: "1.0",
            bundleVersion: "1",
            appIcon: .placeholder(icon: .note),
            accentColor: .presetColor(.teal),
            supportedDeviceFamilies: [
                .pad,
                .phone
            ],
            supportedInterfaceOrientations: [
                .portrait,
                .landscapeRight,
                .landscapeLeft,
                .portraitUpsideDown(.when(deviceFamilies: [.pad]))
            ],
            appCategory: .music
        )
    ],
    targets: [
        .executableTarget(
            name: "AppModule",
            path: "."
        )
    ]
)
