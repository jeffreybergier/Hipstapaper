//
//  Created by Jeffrey Bergier on 2020/12/10.
//
//  Copyright © 2020 Saturday Apps.
//
//  This file is part of Hipstapaper.
//
//  Hipstapaper is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  Hipstapaper is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with Hipstapaper.  If not, see <http://www.gnu.org/licenses/>.
//

import SwiftUI

extension ColorScheme {
    internal var isNormal: Bool {
        switch self {
        case .dark:
            return false
        case .light:
            fallthrough
        @unknown default:
            return true
        }
    }
}

extension Color {
    static internal let textTitle: Color  = .black
    static internal let textTitle_Dark: Color   = .white
    static internal let textTitleDisabled = Color(.sRGB, white: 0.6, opacity: 1.0)
    static internal let textTitleDisabled_Dark  = Color(.sRGB, white: 0.4, opacity: 1.0)
    static internal let thumbnailPlaceholder = Color(.sRGB, white: 0.95, opacity: 1.0)
    static internal let thumbnailPlaceholder_Dark = Color(.sRGB, white: 0.2, opacity: 1.0)
    static internal let numberCircleBackground = Color(.sRGB, white: 0.75, opacity: 1.0)
    static internal let numberCircleBackground_Dark = Color(.sRGB, white: 0.2, opacity: 1.0)
    #if canImport(AppKit)
    static internal var toolbarIcon: Color { Color(NSColor.controlAccentColor) }
    static internal var toolbarIcon_Dark: Color { Color(NSColor.controlAccentColor) }
    static public var background: Color { Color(NSColor.windowBackgroundColor) }
    #else
    static internal let toolbarIcon = Color(.sRGB, white: 0.33, opacity: 1.0)
    static internal let toolbarIcon_Dark = Color(.sRGB, white: 0.66, opacity: 1.0)
    static public var background: Color { Color(UIColor.systemBackground) }
    #endif
}
