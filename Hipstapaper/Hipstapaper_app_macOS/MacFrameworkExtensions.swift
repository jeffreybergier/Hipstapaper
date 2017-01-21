//
//  FrameworkExtensions.swift
//  Hipstapaper
//
//  Created by Jeffrey Bergier on 1/20/17.
//  Copyright © 2017 Jeffrey Bergier. All rights reserved.
//

import AppKit

class AppleInterfaceStyleWindowAppearanceSwitcher {
    
    enum Style: String {
        case light, dark
        static var system: Style {
            let styleString = UserDefaults.standard.string(forKey: "AppleInterfaceStyle") ?? "Light"
            let style = Style(rawValue: styleString.lowercased())
            return style ?? .light
        }
    }
    
    private let token: NSObjectProtocol
    
    init(window: NSWindow) {
        
        // create the closure to execute when the notification is fired
        // capture the window weakly so it can be release as normal
        let changeClosure: (Notification?) -> Void = { [weak window] notification in
            let style = Style.system
            switch style {
            case .light:
                window?.appearance = NSAppearance(named: NSAppearanceNameVibrantLight)
            case .dark:
                window?.appearance = NSAppearance(named: NSAppearanceNameVibrantDark)
            }
        }
        
        // store the token return by notificationcenter so we can stop observing later
        self.token = NotificationCenter.default.addObserver(forName: .NSApplicationDidChangeScreenParameters, object: .none, queue: .none, using: changeClosure)
        
        // execute the closure just once so our window is the correct style right now
        changeClosure(.none)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self.token)
    }
}
