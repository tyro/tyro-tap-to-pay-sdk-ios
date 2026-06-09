// swift-tools-version: 5.9
import PackageDescription

let package = Package(
  name: "TyroTapToPaySDKPackage",
  platforms: [
    .iOS("18.6")
  ],
  products: [
    .library(
      name: "TyroTapToPaySDKPackage",
      targets: ["TyroTapToPaySDKPackage"])
  ],
  dependencies: [],
  targets: [
    .target(name: "TyroTapToPaySDKPackage",
            dependencies: [
              .target(name: "TyroTapToPaySDK"),
            ]
    ), 
    .binaryTarget(name: "TyroTapToPaySDK",
                url: "https://tap-to-pay.connect.tyro.com/tyro/0.20.0/TyroTapToPaySDK.xcframework.zip",
                checksum: "58eefd02c46e5d5568c7f7d97c4c1bb35a8f00f5eb47c9e2f1bef018c058537d"),
  ]
)
