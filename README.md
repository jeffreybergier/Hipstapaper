![Xcode: 9.3](https://img.shields.io/badge/Xcode-9.3-lightgrey.svg) ![Swift: 4.1](https://img.shields.io/badge/Swift-4.1-lightgrey.svg) ![iOS: 11.0](https://img.shields.io/badge/iOS-11.0-lightgrey.svg) ![macOS: 10.11](https://img.shields.io/badge/macOS-10.11-lightgrey.svg) ![devices: iPhone & iPad & Mac](https://img.shields.io/badge/devices-iPad%20%26%20iPhone%20%26%20Mac-lightgrey.svg)

[![Hipstapaper Screenshots](/readme-screenshot.png)](http://www.jeffburg.com/cocoaassets/hipstapaper-devices.png)

# Hipstapaper - iOS and Mac Reading List App
A native cross platform reading list app that I use for prototyping and learning.

## How to Get the App
Hipstapaper is not available on the App Store. Its not broadly usable in its current state because it requires the user to provide their own Realm Object Server to start syncing. I use a TestFlight build to use the app on my own iOS devices and I have a developer signed and self-hosted binary for macOS.
- iOS:
    - [Comment on this TestFlight Issue](/jeffreybergier/Hipstapaper/issues/1)
- macOS:
    - [Download](http://www.jeffburg.com/zzNotPortfolio/Hipstapaper/current/Hipstapaper.zip)

## Summary of Capabilities
- All features implemented separately in UIKit and AppKit.
- Add URL's into the application by using macOS and iOS system share sheet.
- Perform Bulk CRUD and Tagging operations in the application.
- Search, filter, and sort items in the application.
- Syncronize list between devices using Ream Object Server
    - Realm Object server is user provided currently.
- Restore application state

## Why Did I Write This?
- I wanted to learn how to make a Source-List / Splitview style app in both UIKit and AppKit.
- I wanted to learn how to make a CRUD style application.
- I wanted to learn how to provide search, filter, and sorting capabilities in an application.
- I wanted to learn how to use Mac specific features like drag and drop, menus, contextual menus, etc.
- I wanted to learn how to use Realm.
- I wanted to learn how to use the Realm Object Server.
- I wanted to learn how to make share extensions on macOS and iOS.

## Contribution Guidelines
I'm so happy you're interested in contributing. However, I am not accepting any contributions to this project right now. I plan on replacing this app with a replacement where I want to learn some new concepts for the data management. When I start on that new project, I'll add a link here.

## How to Clone and Run

### Requirements

- Xcode 9.3 or higher
- Cocoapods

### Instructions

1. Clone the Repo: 
    ```
    git clone 'https://github.com/jeffreybergier/Hipstapaper.git'
    ```
1. Install Cocoapods
    ```
    cd Hipstapaper/Hipstapaper/
    pod install
    ```
1. Change Team to your AppleID (needed to run on your physical device)
    1. Open `Hipstapaper.xcworkspace` in Xcode.
    1. Go through both macOS targets and both iOS targets and…
    1. Under Signing, change the team from its current setting to your AppleID.
1. Build and Run
    - Hipstapaper works in the simulator and on physical devices


