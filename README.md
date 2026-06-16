# Tyro Tap to Pay SDK (iOS)

iOS SDK for Tap To Pay on iPhone using Tyro Payments as the Payment Service Provider (PSP)

[![Swift](https://img.shields.io/badge/Swift-6-blue?style=flat-square)](https://swift.org)
![Static Badge](https://img.shields.io/badge/iOS-18.6+-purple)
![Static Badge](https://img.shields.io/badge/Xcode-26.0+-green)
[![License][license-image]][license-url]

## Requirements

- [Xcode 26.0](https://developer.apple.com/download/) or above
- Swift 6 (ships with Xcode 26)
- iPhone with `Tap to Pay on iPhone` hardware capability (iPhone XS or above)
- [iOS 18.6][min-ios-version] or above
- A Tyro merchant account with Embedded Payments enabled — see [Account Authorisation](https://docs.connect.tyro.com/pos/embedded-payments/account-authorisation)

### Before you begin

Complete Tyro's onboarding before integrating the SDK:

- [Account Authorisation](https://docs.connect.tyro.com/pos/embedded-payments/account-authorisation) — merchant authorisation, reader creation, and obtaining a `readerId`
- [Integrate SDK](https://docs.connect.tyro.com/pos/embedded-payments/iphone/integrate-sdk) — server connection endpoint and full integration flow

## Installation

This project requires Xcode.
You can see all the Xcode releases and version info at [Xcode Releases](https://developer.apple.com/download/)

Make sure you have the correct version of the Xcode command line tools installed:

```shell
xcode-select --install
```

### Add the SDK via Swift Package Manager

1. In Xcode, go to **File > Add Package Dependencies**.
2. Enter the repository URL: `https://github.com/tyro/tyro-tap-to-pay-sdk-ios`
3. Select your preferred dependency rule and add the **`TyroTapToPaySDKPackage`** library to your app target.
4. In your source code, `import TyroTapToPaySDK`.

See [GitHub Releases](https://github.com/tyro/tyro-tap-to-pay-sdk-ios/releases) for version history and release notes (current SDK version: 0.21.0).

## Sample iOS App

A working example app is available in the [SampleApp](SampleApp/) directory of this repository.

1. Open `SampleApp/Tyro Embedded Sample App.xcodeproj` in Xcode.
2. Update the `readerId` in [DemoConnectionProvider.swift](SampleApp/SampleApp/POS/DemoConnectionProvider.swift) with the value provided during Tyro onboarding.
3. Build and run on a compatible iPhone (iPhone Xs or later).

The Sample App demonstrates SDK connection, payments, refunds, and Tyro settings.

## Using the Swift Package in your iOS app

### Entitlements

You must request access to the `Tap to Pay on iPhone` entitlement from Apple directly, refer to [Apple's proximity reader documentation](https://developer.apple.com/documentation/proximityreader/setting-up-the-entitlement-for-tap-to-pay-on-iphone) for more information.

### Steps to get up and running with the SDK

Create necessary certificates and provisioning profiles.

#### Configure your iOS project

1. Setup [Code Signing and Provisioning Profiles](https://help.apple.com/xcode/mac/11.4/index.html?localePath=en.lproj#/dev3a05256b8) in your Xcode project;
2. Ensure the Bundle identifier matches the format that you will use for code signing.
3. Configure the team for each target within the project and ensure it is consistent with your Code Signing configuration.
4. Add the `Tap to Pay on iPhone` entitlement — this will appear in the list of available options when code signing is correctly configured.
5. Add the [`config_uat.env`](SampleApp/SampleApp/Supporting%20Files/config_uat.env) file (provided by Tyro during onboarding for the UAT/sandbox environment) to your project's `Supporting Files` sub-directory and wire the keys into your `Info.plist` — see the [Configuration File](https://docs.connect.tyro.com/pos/embedded-payments/iphone/integrate-sdk) section in the Integrate SDK documentation.
6. Import TyroTapToPaySDK in your source code
7. Create an instance of the `TyroTapToPay` class:
   - Pass in the `TyroEnvironment` and your own implementation of the [`ConnectionProvider`](https://docs.connect.tyro.com/pos/embedded-payments/iphone/sdk/connection-provider) protocol — see [DemoConnectionProvider.swift](SampleApp/SampleApp/POS/DemoConnectionProvider.swift) for a working example.
   - Call the `connect()` method of the `TyroTapToPay` instance — this calls your `ConnectionProvider` to fetch a `connectionSecret` from your server.

For more details, refer to the [Documentation](https://docs.connect.tyro.com/pos/embedded-payments/iphone/get-started/).

## Documentation

### Developing a POS app for integrating with Tyro Tap to Pay SDK (iOS)

A preview of our API documentation can be found here:

- [Integrate SDK](https://docs.connect.tyro.com/pos/embedded-payments/iphone/integrate-sdk/)
- [Account Authorisation](https://docs.connect.tyro.com/pos/embedded-payments/account-authorisation)
- [ConnectionProvider](https://docs.connect.tyro.com/pos/embedded-payments/iphone/sdk/connection-provider)

## Marketing Guidelines

Refer to Apple's [Tap to Pay Marketing Guidelines]

## Need help?

Reach out to the `Connect Support Team` at [connect-support@tyro.com](mailto:connect-support@tyro.com)

## Meta

[Tyro Tap to Pay SDK (iOS)][repo-url]

The SDK requires iOS 18.6 or later (see Requirements). The disclaimer below is mandated by Apple for Tap to Pay on iPhone.

## Disclaimer

Tap to Pay on iPhone requires the latest version of iOS. Update to the latest version by going to Settings > General > Software Update. Tap Download and Install. Some contactless cards may not be accepted. Transaction limits may apply. The Contactless Symbol is a trademark owned by and used with permission of EMVCo, LLC. Tap to Pay on iPhone is not available in all markets. [View Tap to Pay on iPhone countries and regions](https://developer.apple.com/tap-to-pay/regions/).

[repo-url]: https://github.com/tyro/tyro-tap-to-pay-sdk-ios (Tyro Tap to Pay SDK iOS GitHub Repository)
[Tap to Pay Marketing Guidelines]: https://developer.apple.com/tap-to-pay/marketing-guidelines/
[min-ios-version]: https://developer.apple.com/documentation/ios-ipados-release-notes/ios-ipados-18_6-release-notes (iOS 18.6)
[license-image]: https://img.shields.io/badge/License-Conditions%20of%20Use-blue?style=flat-square
[license-url]: ./LICENCE.md
