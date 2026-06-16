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
                url: "https://tap-to-pay.connect.tyro.com/tyro/0.21.0/TyroTapToPaySDK.xcframework.zip",
                checksum: "57c93f9857752f120cd03372fd6ce7986fb35244d7a64b0ecd697e4c7c5fc689"),
  ]
)
