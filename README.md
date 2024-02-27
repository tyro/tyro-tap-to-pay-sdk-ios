# Tyro Tap to Pay SDK (iOS)
iOS SDK for Tap To Pay on iPhone using Tyro Payments as the Payment Service Provider (PSP)

[![Swift Version][swift-image]][swift-url]
![Static Badge](https://img.shields.io/badge/iOS-16.4+-purple)
![Static Badge](https://img.shields.io/badge/Xcode-15.0+-green)
<!-- [![License][license-image]][license-url] -->

### Requirements

- [Xcode 15.0](https://xcodereleases.com/?scope=release) or above
- iPhone with `Tap to Pay on iPhone` hardware capability (iPhone XS or above)
- [iOS 16.4][min-ios-version] or above

## Installation

This project requires Xcode (or at least Xcode command line tools) for compilation etc.
You can see all the Xcode releases and version info at [Xcode Releases](https://xcodereleases.com/?scope=release)

Make sure, you have the latest version of the Xcode command line tools installed:
```shell
    xcode-select --install
```
### Submodule
The sample app included in this repository is a git submodules, before running it you can do one of the two things depending on how you cloned this repository.

- If you haven't yet cloned this repository, use the following line to include the submodule
  ```
  git clone --recursive <project url>
  ```
- If you have already cloned this repository and noticed the sample app folder is empty, try the following line
  ```
  git submodule update --init --recursive
  ```

## Entitlements
**Note:** you must request access to the `Tap to Pay on iPhone` entitlement from Apple directly, refer to [Apple's proximity reader documentation](https://developer.apple.com/documentation/proximityreader/setting-up-the-entitlement-for-tap-to-pay-on-iphone) for more information.

## Sample iOS App

#### Create necessary certificates and provisioning profiles

#### Configure the project
1. Setup [Code Signing and Provisioning Profiles](https://help.apple.com/xcode/mac/11.4/index.html?localePath=en.lproj#/dev3a05256b8) in your Xcode project;
2. Ensure the Bundle identifier matches the format that you will use for code signing;
3. Configure the team for each target within the project and ensure it is consistent with your Code Signing configuration.
4. Add the `Tap to Pay on iPhone` entitlement, note this will appear in the list of available options when code signing is correctly configured.

## Using the Swift Package in your iOS app
#### Note: the same process for code signing entitlements is required

#### 1. In Xcode, add the Swift Package to your iOS app 
Select `File` -> `Swift Packages` -> `Add Package Dependency` and enter `https://github.com/tyro/tyro-tap-to-pay-sdk-ios`.

#### 2. Import the SDK in your Swift code
```swift
import TyroTapToPaySDK
```

#### 3. Validate that the device supports Tap To Pay
```swift 
guard UIDevice.current.isProximityMonitoringEnabled == true else {
    // This device does not support Tap To Pay :(
    return
}
```

## Documentation 
### Developing a POS app for integrating with Tyro Tap to Pay SDK (iOS)
A preview of our API documentation can be found here:
- [Integrate SDK](https://preview.redoc.ly/tyro-connect/pla-5831/pos/tap-to-pay/iphone/integrate-sdk/)

### Marketing Guidelines
Refer to Apple's [Tap to Pay Marketing Guidelines]

## Need help?
Reach out to the `Connect Support Team` at [connect-support@tyro.com](mailto:connect-support@tyro.com)

## Meta
[Tyro Tap to Pay SDK (iOS)][repo-url]

## Disclaimer
Tap to Pay on iPhone requires the latest version of iOS. Update to the latest version by going to Settings > General > Software Update. Tap Download and Install. Some contactless cards may not be accepted. Transaction limits may apply. The Contactless Symbol is a trademark owned by and used with permission of EMVCo, LLC. Tap to Pay on iPhone is not available in all markets. [View Tap to Pay on iPhone countries and regions](https://developer.apple.com/tap-to-pay/regions/).

[swift-image]:https://img.shields.io/badge/swift-5.9-blue.svg (Swift 5.9 or newer)
[swift-url]:https://swift.org/ (Swift Programming Language)
[ios-image]:https://img.shields.io/badge/iOS-000000?style=for-the-badge&logo=ios&logoColor=white
[repo-url]:https://github.com/tyro/tyro-tap-to-pay-sdk-ios (Tyro Tap to Pay SDK iOS GitHub Repository)
[Tap to Pay Marketing Guidelines]:https://developer.apple.com/tap-to-pay/marketing-guidelines/ 
[min-ios-version]: https://developer.apple.com/documentation/ios-ipados-release-notes/ios-ipados-16_4-release-notes (iOS 16.4)
[min-ios-image]: https://img.shields.io/badge/iOS-16.4-purple (iOS 16.4)
