//
//  FrameworkExtensions.swift
//  Hipstapaper
//
//  Created by Jeffrey Bergier on 1/20/17.
//  Copyright © 2017 Jeffrey Bergier. All rights reserved.
//

import AppKit

enum AppleInterfaceStyle: String {
    
    case light, dark

    static var system: AppleInterfaceStyle {
        let styleString = UserDefaults.standard.string(forKey: "AppleInterfaceStyle") ?? "Light"
        let style = AppleInterfaceStyle(rawValue: styleString.lowercased())
        return style ?? .light
    }
}
