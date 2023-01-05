![Xcode: 14.2](https://img.shields.io/badge/Xcode-14.2-lightgrey.svg) ![Swift: 5.7](https://img.shields.io/badge/Swift-5.7-lightgrey.svg) ![iOS: 16](https://img.shields.io/badge/iOS-16-lightgrey.svg) ![macOS: 13](https://img.shields.io/badge/macOS-13-lightgrey.svg) ![devices: iPhone & iPad & Mac](https://img.shields.io/badge/devices-iPad%20%26%20iPhone%20%26%20Mac-lightgrey.svg) ![UI: SwiftUI](https://img.shields.io/badge/UI-SwiftUI-lightgrey.svg) ![Data: CoreData](https://img.shields.io/badge/Data-CoreData-lightgrey.svg) ![Sync: iCloud](https://img.shields.io/badge/Sync-iCloud-lightgrey.svg)

![Hipstapaper Screenshots](/readme-screenshot.png)

# Hipstapaper - iOS and Mac Reading List App

A macOS, iOS, and iPadOS app written 100% in SwiftUI. Hipstapaper is an app that takes a URL shared from another app via the share extension, loads the page to get the title, and a screenshot, and then saves the resulting bookmark via Core Data. Hipstapaper uses iCloud Core Data syncing via `NSPersistentCloudKitContainer` to sync all data between devices. Hipstapaper supports basic tagging and archiving for saved bookmarks.

## How to Get the App

Hipstapaper is tech demo and learning experience, not a fully complete application experience. If you would like to try the app, please use the links below.
- iOS:
    - [Testflight Link](https://testflight.apple.com/join/V1f2j5Jd)
- macOS:
    - [Download Notarized Build](http://www.jeffburg.com/zzNotPortfolio/Hipstapaper/current/Hipstapaper.zip)

## Summary of Capabilities

- Basic CRUD management of websites
- Tagging, Filtering, Sorting
- Bulk editing
- State restoration
- iPadOS and macOS Menus
- iPadOS and macOS "Scenes" for multiple window support
- Share extension for adding content
- iCloud Sync

## Why Did I Write This?

Hipstapaper is my tech demo application that I use to experiment with the newest Apple technologies. This latest version tries to accomplish the following:

- Separation of concerns with heavy use of Swift Package Manager
- Light wrapper around Core Data without performance hit.
    - No NSManagedObjects or any Core Data classes are public outside of the `Store` package.
    - Lists of 3000+ items load and scroll in iOS at 120Hz without issue.
- 100% Cross-platform SwiftUI
    - No Catalyst
    - No trap-doors to UIKit/AppKit (as few as possible 😛).
    - Avoid platform specific code.
    - Avoid hacks because SwiftUI is broken.
- Support latest SwiftUI & OS Features
    - Navigation
    - Menus
    - Customizable Toolbars
    - Scenes
    - more

## Known Issues

- Toolbars in Sheets and Popovers on macOS is ugly.
    - This is because SwiftUI still does not render toolbars in sheets and popovers like iOS does.
- Window size is forgotten when closing browser windows on macOS.

## Contribution Guidelines

I am happy to accept contributions. Please note that I always intend to be build safe and inclusive communities. I have a 0 tolerance policy towards harassment, meanness, sarcastic-ness toward any other member. Read the [code of conduct](CODE_OF_CONDUCT.md) for full details.

Please refer to an existing issue or create a new issue before beginning to work on a contribution.

## How to Clone and Run

### Requirements

- Xcode 14.2 or higher

### Instructions

This project runs entirely in Xcode with any external dependencies handled by Swift Package Manager. Note that there may be issues running on physical devices because this project relies on iCloud entitlements.

1. Clone the Repo
1. Open in Xcode
1. Build and Run
