# Safari Wallet

This is an experiment to see whether we can build a viable browser extension Ethereum wallet for Safari on macOS and especially iOS.

## Overview

A diagram might be useful, but basically the current plan/rundown is:

- The `window.ethereum` object (EIP-1193 JavaScript API) will be injected into each page. This way, the wallet will automatically work with all apps/dApps that support MetaMask.

- For the interface, the native Safari extension popover is used, in tandem with the [WebExtensions API](https://developer.mozilla.org/en-US/Add-ons/WebExtensions).

The bulk of the development is currently going on in the `Shared (App and Extension)` and `Shared (App)` folders.

It is important to read these files:

- `Shared (Extension)` > `Resources` > `README.md`

- `Shared (Extension)` > `Resources` > `ethereum` > `README.md`

- `test-dapp` > `README.md`

## Popover

### Setting up the popover

1. Open this repo as a project in Xcode

2. From the menu bar: `File` > `Packages` > `Update to Latest Package Versions`

3. In the leftmost top bar breadcrumb, which should be on "macOS" by default, switch it to "iOS"

4. Set the following breadcrumb to a mobile device, perhaps "iPhone 13 Pro"?

5. Click the play button to start the emulator

6. Once the emulator has loaded (it might take a few minutes), open the Settings app

7. Settings > Safari > Extensions > Wallet Extension

8. Switch to on

Then, to test the popover, navigate to https://safari-wallet-test-dapp.vercel.app in Safari (or http://localhost:3000/, if you're running the local dev server)

You can also set up the local dev server here (WIP): https://github.com/natclark/safari-wallet-test-dapp

## Development

Project uses [Tuist](https://tuist.io/). To start developing [install Tuist](https://docs.tuist.io/tutorial/get-started#install), Node.js, and run:

```sh
tuist dependencies fetch
tuist focus
```

---

To edit the Tuist configuration you can use `tuist edit` which will open Xcode.

### Dependencies

Swift dependencies are managed by Tuist and are specified in `Tuist/Dependencies.swift`.

## Keys

Use your own Alchemy or Infura keys by creating a file called `keys.swift` in the `Shared (App and Extension)` directory. The filename is added to .gitignore so won't be committed.

```swift
// Shared (App and Extension)/keys.swift
struct ApiKeys {
    static let alchemyMainnet = "<YOUR KEY HERE>"
    static let alchemyRopsten = "<YOUR KEY HERE>"
    static let infuraRopsten = "<YOUR KEY HERE>"
    static let infuraMainnet = "<YOUR KEY HERE>"
    static let covalent = "<YOUR KEY HERE>"
    static let unmarshal = "<YOUR KEY HERE>"
    static let etherscan = "<YOUR KEY HERE>"
}
```
