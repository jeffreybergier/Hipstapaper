//
//  FrameworkExtensions.swift
//  Hipstapaper
//
//  Created by Jeffrey Bergier on 1/20/17.
//  Copyright © 2017 Jeffrey Bergier. All rights reserved.
//

import AppKit

extension NSWindow {
    var currentAppearance: NSAppearance {
        return self.appearance ?? .current
    }
}

extension NSAppearance {
    var isNormal: Bool {
        if #available(OSX 10.14, *) {
            guard let bestMatch = self.bestMatch(from: [.aqua, .darkAqua]) else { return true }
            return bestMatch != NSAppearance.Name.aqua
        } else {
            let styleString = UserDefaults.standard.string(forKey: "AppleInterfaceStyle") ?? "Light"
            return styleString.lowercased() != "dark"
        }
    }
}

// swiftlint:disable:next type_name
class AppleInterfaceStyleWindowAppearanceSwitcher {
    
    private let token: NSObjectProtocol

    @available(*, deprecated, message:"Only useful for macOS 10.10 to 10.13. Returns NIL on 10.14 and higher.")
    init?(window: NSWindow) {

        // return nil if running on a system that supports dark mode officially
        if #available(macOS 10.14, *) {
            return nil
        }
        
        // create the closure to execute when the notification is fired
        // capture the window weakly so it can be release as normal
        let changeClosure: (Notification?) -> Void = { [weak window] _ in
            let isLightMode = window?.currentAppearance.isNormal ?? true
            switch isLightMode {
            case true:
                window?.appearance = NSAppearance(named: .vibrantLight)
            case false:
                window?.appearance = NSAppearance(named: .vibrantDark)
            }
        }
        
        // store the token return by notificationcenter so we can stop observing later
        self.token = NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "HIMenuBarAppearanceDidChangeNotification"),
                                                            object: nil,
                                                            queue: nil,
                                                            using: changeClosure)
        
        // execute the closure just once so our window is the correct style right now
        changeClosure(nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self.token)
    }
}
