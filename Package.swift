// swift-tools-version: 5.9
import PackageDescription

let package = Package(
  name: "TyroTapToPaySDKPackage",
  platforms: [
    .iOS("16.4")
  ],
  products: [
    .library(
      name: "TyroTapToPaySDKPackage",
      targets: ["TyroTapToPaySDKPackage"])
  ],
  dependencies: [
    .package(url: "https://github.com/krzyzanowskim/OpenSSL.git", .upToNextMinor(from: "3.1.4000")),
    .package(url: "https://github.com/apple/swift-docc-plugin", from: "1.3.0")
  ],
  targets: [
    .target(name: "TyroTapToPaySDKPackage",
            dependencies: [
              .product(name: "OpenSSL", package: "OpenSSL"),
              .target(name: "TyroTapToPaySDK"),
              .target(name: "MobileMPOSSDK"),
              .target(name: "MobileConfiguration"),
              .target(name: "MobileHttp"),
              .target(name: "MobileMPOSCoreV2"),
              .target(name: "MobileMessageProcess"),
              .target(name: "MobilePOGEngine"),
              .target(name: "MobileProximityReaderSDK"),
              .target(name: "MobileReaderSPOC"),
              .target(name: "MobileSecurity"),
              .target(name: "MobileService"),
              .target(name: "MobileThirdPartyIntegration"),
              .target(name: "MobileUIKit"),
              .target(name: "MobileUtils"),
              .target(name: "Shared"),
              .target(name: "TrustKit"),
            ]
    ),
    .binaryTarget(name: "TyroTapToPaySDK",
                  path: "./TyroTapToPaySDK.xcframework.zip"),
    .binaryTarget(name: "MobileConfiguration",
                  url: "https://tap-to-pay.connect.tyro.com/ss/1.0.7.0/SSMobileConfiguration.xcframework.zip",
                  checksum: "8973d0340c668a3071330c6ae019a87ed044779cc6c4acb9c6571a1167e20ab2"),
    .binaryTarget(name: "MobileHttp",
                  url: "https://tap-to-pay.connect.tyro.com/SSMobileHttp.xcframework.zip",
                  checksum: "eff30449744696ee3f1604679e82e37da57a37f4a433368e7166e56c897602d1"),
    .binaryTarget(name: "MobileMPOSCoreV2",
                  url: "https://tap-to-pay.connect.tyro.com/SSMobileMPOSCoreV2.xcframework.zip",
                  checksum: "ded14f58f1e0bc21eff1f3e366483a51dca565f9d9e5ea4314ff9cca3de0c840"),
    .binaryTarget(name: "MobileMPOSSDK",
                  url: "https://tap-to-pay.connect.tyro.com/SSMobileMPOSSDK.xcframework.zip",
                  checksum: "75b42b3ed38634dca0f132413d2ad6072f3390289d55a2f0d295cb0615a7fd7d"),
    .binaryTarget(name: "MobileMessageProcess",
                  url: "https://tap-to-pay.connect.tyro.com/SSMobileMessageProcess.xcframework.zip",
                  checksum: "abe26a9f00eaf2ceccf0e8dd2e3958223e5cae9859f1f0f9f350546832d30f47"),
    .binaryTarget(name: "MobilePOGEngine",
                  url: "https://tap-to-pay.connect.tyro.com/SSMobilePOGEngine.xcframework.zip",
                  checksum: "9654e47152d7b30d4530af990b6d64709eef797b5a712ba7ce18de32120e8683"),
    .binaryTarget(name: "MobileProximityReaderSDK",
                  url: "https://tap-to-pay.connect.tyro.com/SSMobileProximityReaderSDK.xcframework.zip",
                  checksum: "14f928faebd2b165e2d28a85160b748dc679f5bea1cdda279a42653c1762a1d2"),
    .binaryTarget(name: "MobileReaderSPOC",
                  url: "https://tap-to-pay.connect.tyro.com/ss/1.0.7.0/SSMobileReaderSPOC.xcframework.zip",
                  checksum: "133f1fa4f9aec0288f517e75e7c50c6379c638d35de7664cd7fe9ab3e09bf9c9"),
    .binaryTarget(name: "MobileSecurity",
                  url: "https://tap-to-pay.connect.tyro.com/SSMobileSecurity.xcframework.zip",
                  checksum: "822eebe154538046f73a38b1b1198d3cd00128102274333b733dc895814ca40f"),
    .binaryTarget(name: "MobileService",
                  url: "https://tap-to-pay.connect.tyro.com/ss/1.0.7.0/SSMobileService.xcframework.zip",
                  checksum: "b22224b4f916226cac138852ebd3b978cc73f36d76225fc2438085c94bd97804"),
    .binaryTarget(name: "MobileThirdPartyIntegration",
                  url: "https://tap-to-pay.connect.tyro.com/ss/1.0.7.0/SSMobileThirdPartyIntegration.xcframework.zip",
                  checksum: "433ca84ece31a91992be3349c40996cd4fdd0cf26809694ca44f74bfb4649298"),
    .binaryTarget(name: "MobileUIKit",
                  url: "https://tap-to-pay.connect.tyro.com/ss/1.0.7.0/SSMobileUIKit.xcframework.zip",
                  checksum: "7e6f6519e9d36fc8525c16ca481a3f7d528bc8adf4c4303c176ff1e37ed0c0ae"),
    .binaryTarget(name: "MobileUtils",
                  url: "https://tap-to-pay.connect.tyro.com/ss/1.0.7.0/SSMobileUtils.xcframework.zip",
                  checksum: "ba4126c81c38ab9989754a8b0c35f50cdbae6f6a5aba7c469ec0d096b4c6018c"),
    .binaryTarget(name: "Shared",
                  url: "https://tap-to-pay.connect.tyro.com/Shared.xcframework.zip",
                  checksum: "494baeb7e01ba3400a63406ec62258493d62f9725edc27d4e0444b14b3516e28"),
    .binaryTarget(name: "TrustKit",
                  url: "https://tap-to-pay.connect.tyro.com/TrustKit.xcframework.zip",
                  checksum: "cb5b67bb83bdcefa28d622130da742186da82bc11dbc1f1e11df80286697d3f5"),
    
  ]
)
