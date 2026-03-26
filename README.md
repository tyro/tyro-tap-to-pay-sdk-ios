# Tyro Tap to Pay SDK (iOS)

iOS SDK for Tap To Pay on iPhone using Tyro Payments as the Payment Service Provider (PSP)

[![Swift](https://img.shields.io/badge/Swift-5.10-blue?style=flat-squre)](https://swift.org)
![Static Badge](https://img.shields.io/badge/iOS-17.0+-purple)
![Static Badge](https://img.shields.io/badge/Xcode-15.3+-green)
<!-- [![License][license-image]][license-url] -->

## Requirements

- [Xcode](https://xcodereleases.com/?scope=release) or above
- iPhone with `Tap to Pay on iPhone` hardware capability (iPhone XS or above)
- [iOS 17.0][min-ios-version] or above

## Installation

This project requires Xcode.
You can see all the Xcode releases and version info at [Xcode Releases](https://xcodereleases.com/?scope=release)

Make sure, you have the correct version of the Xcode command line tools installed:

```shell
    xcode-select --install
```

## Sample iOS App

Refer to The SampleApp source code for a working example iOS app integrating with Tyro's SDK for `Tap to Pay on iPhone`.

## Using the Swift Package in your iOS app

### Entitlements

You must request access to the `Tap to Pay on iPhone` entitlement from Apple directly, refer to [Apple's proximity reader documentation](https://developer.apple.com/documentation/proximityreader/setting-up-the-entitlement-for-tap-to-pay-on-iphone) for more information.

### Steps to get up and running with the SDK

Create necessary certificates and provisioning profiles

#### Configure your iOS project

1. Setup [Code Signing and Provisioning Profiles](https://help.apple.com/xcode/mac/11.4/index.html?localePath=en.lproj#/dev3a05256b8) in your Xcode project;
2. Ensure the Bundle identifier matches the format that you will use for code signing;
3. Configure the team for each target within the project and ensure it is consistent with your Code Signing configuration.
4. Add the `Tap to Pay on iPhone` entitlement, note this will appear in the list of available options when code signing is correctly configured.
5. Add the `tyro-tap-to-pay-ios` Swift Package to your project;
6. Add the (Tyro provided) environment config (.env) file to your project's `Supporting Files` sub-directory and add keys to the project info plist (detailed in the documentation);
7. Import TyroTapToPaySDK in your source code
8. Create an instance of the TyroTapToPay class:
   - Inject the TyroEnvironment and your ConnectionProvider implementation
   - Call the `connect()` method of the TyroTapToPay instance.

For more details, refer to the [Documentation](https://docs.connect.tyro.com/pos/embedded-payments/iphone/get-started/).

## Documentation

### Developing a POS app for integrating with Tyro Tap to Pay SDK (iOS)

A preview of our API documentation can be found here:

- [Integrate SDK](https://docs.connect.tyro.com/pos/embedded-payments/iphone/integrate-sdk/)

### Error Handling

The SDK surfaces errors through `TapToPaySDKError`. Your app should catch and handle each case in the `do/catch` block around `connect()` and payment calls. The table below describes each error case, its cause, and how the Sample App handles it.

#### Errors thrown by `connect()`

| Error Case | Cause | Sample App Behaviour |
|---|---|---|
| `sessionInitialisationError(String)` | The SDK failed to initialise a reader session. | Displays `"sessionInitialisationError: <message>"`. |
| `retryLimitExhausted(Error)` | The SDK exhausted all retries while attempting to obtain the connection secret via `ConnectionProvider.createConnection()`. | Displays `"retryLimitExhausted (connectionSecret): <error>"`. |
| `unableToConnectReader(String)` | The SDK could not establish a connection to the proximity reader hardware. | Displays `"unableToConnectReader: <message>"`. |
| `discoverReadersError` | Reader discovery failed. | Displays `"discoverReadersError"`. |
| `sdkUpgradeRequiredError(String)` | The installed SDK version is too old and must be upgraded. | Displays `"sdkUpgradeRequiredError: <message>"`. |
| `fetchSessionCredentialsError(Error)` | The SDK failed to fetch the session credentials needed to activate the reader. This is thrown when your `ConnectionProvider.createConnection()` implementation throws an error (e.g. a network failure or an unexpected server response when retrieving the connection secret). The underlying error from `createConnection()` is wrapped and surfaced here. | Catches the error and displays `"fetchSessionCredentialsError: <error.localizedDescription>"` in the UI. |
| `fetchSdkDataError(String)` | The SDK failed to download required data during initialisation. | Displays `"fetchSdkDataError: <message>"`. |
| `noProximityReaderFound` | No compatible Tap to Pay hardware was found on the device. Requires iPhone XS or above. | Displays `"noProximityReaderFound"` with a device-capability hint. |

#### Errors thrown by `startPayment()` / `refundPayment()`

| Error Case | Cause | Sample App Behaviour |
|---|---|---|
| `failedToVerifyConnection(String)` | The SDK could not verify the reader connection before processing the transaction. | Displays `"failedToVerifyConnection: <error>"`. |
| `transactionError(String)` | A general transaction-level error occurred. | Displays `"transactionError: <message>"`. |
| `unableToConnectReader(String)` | The reader disconnected before or during the transaction. | Displays `"unableToConnectReader: <message>"`. |
| `invalidParameter(String)` | One or more transaction parameters (e.g. `amount`) are invalid. | Displays `"invalidParameter: <message>"`. |

> **Note:** Always include a generic `catch` clause after all specific `TapToPaySDKError` cases to handle any unexpected errors.

## Marketing Guidelines

Refer to Apple's [Tap to Pay Marketing Guidelines]

## Need help?

Reach out to the `Connect Support Team` at [connect-support@tyro.com](mailto:connect-support@tyro.com)

## Meta

[Tyro Tap to Pay SDK (iOS)][repo-url]

## Disclaimer

Tap to Pay on iPhone requires the latest version of iOS. Update to the latest version by going to Settings > General > Software Update. Tap Download and Install. Some contactless cards may not be accepted. Transaction limits may apply. The Contactless Symbol is a trademark owned by and used with permission of EMVCo, LLC. Tap to Pay on iPhone is not available in all markets. [View Tap to Pay on iPhone countries and regions](https://developer.apple.com/tap-to-pay/regions/).

[repo-url]:https://github.com/tyro/tyro-tap-to-pay-sdk-ios (Tyro Tap to Pay SDK iOS GitHub Repository)
[Tap to Pay Marketing Guidelines]:https://developer.apple.com/tap-to-pay/marketing-guidelines/
[min-ios-version]: https://developer.apple.com/documentation/ios-ipados-release-notes/ios-ipados-17-release-notes (iOS 17.0)
