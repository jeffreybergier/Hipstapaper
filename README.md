![Xcode: 12.4](https://img.shields.io/badge/Xcode-12.4-lightgrey.svg) ![Swift: 5.3](https://img.shields.io/badge/Swift-5.3-lightgrey.svg) ![iOS: 14](https://img.shields.io/badge/iOS-14-lightgrey.svg) ![macOS: 11](https://img.shields.io/badge/macOS-11-lightgrey.svg) ![devices: iPhone & iPad & Mac](https://img.shields.io/badge/devices-iPad%20%26%20iPhone%20%26%20Mac-lightgrey.svg) ![UI: SwiftUI](https://img.shields.io/badge/UI-SwiftUI-lightgrey.svg) ![Data: CoreData](https://img.shields.io/badge/Data-CoreData-lightgrey.svg) ![Sync: iCloud](https://img.shields.io/badge/Sync-iCloud-lightgrey.svg)

[![Hipstapaper Screenshots](/readme-screenshot.png)](http://www.jeffburg.com/cocoaassets/hipstapaper-devices.png)

TODO: Screenshot outdated

# Hipstapaper - iOS and Mac Reading List App

A macOS, iOS, and iPadOS app written 100% in SwiftUI. Hipstapaper is an app that takes a URL shared from another app via the share extension, loads the page to get the title, and a screenshot, and then saves the resulting bookmark via Core Data. Hipstapaper uses iCloud Core Data syncing via `NSPersistentCloudKitContainer` to sync all data between devices. Hipstapaper supports basic tagging and archiving for saved bookmarks.

## How to Get the App

Hipstapaper is not available on the App Store. Its not broadly usable in its current state because SwiftUI has many performance issues and bugs that I do not want to work around. I'm hoping Apple resolved many of them at WWDC 2021. Also, I mostly created this app to learn and to use myself and it is not meant to be a commercial product. That said, you are welcome to use it if you think its interesting.
- iOS:
    - TODO: Figure out testflight for iOS
- macOS:
    - [Download](http://www.jeffburg.com/zzNotPortfolio/Hipstapaper/current/Hipstapaper.zip)

## Summary of Capabilities

- All features implemented in a crossplatform way using SwiftUI
   - Except toolbars. The "Unified Toolbar API" introduced in iOS14/macOS11 is pretty challenging to use well. So I ended up making different toolbars for macOS and iOS AND iPadOS. Hoping this is improved by Apple next round.
- Add Bookmark into the application by using macOS and iOS system share sheet.
   - Can also add via + toolbar icon in the application.
- Basic tagging functionality.
- Search, filter, and sort items in the application.
- Data sync via iCloud

## Why Did I Write This?

- I wanted to learn how to use SwiftUI.
- I wanted to learn how to use Core Data Sync.
- I wanted to learn how to isolate my data layer from my UI layer.
   - Core Data could easily be swapped for Realm or SQLite or anything else with the way its abstracted.

## Known Issues

- Crashes when deleting a tag (iOS)
   - There is an issue with List in SwiftUI that is causing this crash.
   - For the WebsiteList, I [wrote a workaround](https://github.com/jeffreybergier/XPList) but for sidebar lists there is too much detail to rewrite.
- Can't rename tags
- Performance is bad for large lists.
   - Once the list exceeds 1000 items or so, the performance really slows down
   - This is mostly due to how SwiftUI implements List and LazyVStack. They are lazy but not fully lazy. SwiftUI still tends to read all the items in the list, especially as you scroll down.
- Toolbar for macOS browser doesn't work properly in SwiftUI yet
- Window size is forgotten when closing the window on macOS. Interestingly it is preserved if quitting the app.

## Contribution Guidelines

I am happy to accept contributions. Please note that I always intend to be build safe and inclusive communities. I have a 0 tolerance policy towards harassment, meanness, sarcastic-ness toward any other member. Read the [code of conduct](CODE_OF_CONDUCT.md) for full details.

Please refer to an existing issue or create a new issue before beginning to work on a contribution.

## Top Issues

- [investigation: see if NavigationLink can be used to open new windows](https://github.com/jeffreybergier/Hipstapaper/issues/22)
- [enhancement: use real List instead of XPList](https://github.com/jeffreybergier/Hipstapaper/issues/21)
- [~~enhancement: tag rename~~](https://github.com/jeffreybergier/Hipstapaper/issues/20)
- [enhancement: figure out why window loses size after its closed](https://github.com/jeffreybergier/Hipstapaper/issues/23)
- [~~enhancement: figure out crash on tag delete~~](https://github.com/jeffreybergier/Hipstapaper/issues/24)
- [enhancement: figure out how to make SwiftUI toolbar work in Browser Window](https://github.com/jeffreybergier/Hipstapaper/issues/25)

## How to Clone and Run

### Requirements

- Xcode 12.4 or higher

### Instructions

This project runs entirely in Xcode with any external dependencies handled by Swift Package Manager. Note that there may be issues running on physical devices because this project relies on iCloud entitlements.

1. Clone the Repo
1. Open in Xcode
1. Build and Run


