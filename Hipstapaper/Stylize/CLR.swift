//
//  Created by Jeffrey Bergier on 2021/01/15.
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
#if canImport(AppKit)
import AppKit
#else
import UIKit
#endif

extension STZ.CLR {
    public enum IndexRow {
        public enum Text: Fallbackable {
            public static let color = Raw.textTitle
            public static var fallbackColor = Raw.textTitle_fallback
        }
    }
    public enum IndexSection {
        public enum Text: Colorable {
            public static let color = Raw.textTitle
        }
    }
    public enum DetailRow {
        public enum Text: Selectable {
            public static let color = Raw.textTitle
            public static var fallbackColor = Raw.textTitle_fallback
            public static var selectedColor = Raw.textTitle_selected
            public static var fallbackSelectedColor = Raw.textTitle_fallback_selected
        }
    }
    internal enum Thumbnail {
        public enum Icon: Colorable {
            public static let color = Raw.textTitle
        }
        public enum Background: Colorable {
            public static let color = Raw.thumbnailPlaceholder
        }
    }
    public enum Oval {
        public enum Text: Colorable {
            public static let color = Raw.textTitle
        }
        public enum Background: Colorable {
            public static let color = Raw.numberCircleBackground
        }
    }
    public enum Progress {
        public enum Foreground: Colorable {
            public static let color = Raw.progressForeground
        }
        public enum Background: Colorable {
            public static let color = Raw.progressBackground
        }
    }
    
    #if os(macOS)
    internal enum MDL {
        internal enum Title: Colorable {
            static let color = Raw.textTitle
        }
    }
    internal enum ACTN {
        internal enum Body: Colorable {
            static let color = Raw.textTitle
        }
        internal enum Button: Colorable {
            static let color = Raw.textTitle
        }
    }
    internal enum TB {
        internal enum Tint: Colorable {
            static var color: Color { Color(NSColor.controlAccentColor) }
        }
    }
    #endif
    
    fileprivate enum Raw {
        static fileprivate let textTitle                   = STZ.LST.CFG.deselectedForeground
        static fileprivate let textTitle_fallback          = STZ.LST.CFG.deselectedForeground.opacity(0.5)
        static fileprivate let textTitle_selected          = STZ.LST.CFG.selectedForeground
        static fileprivate let textTitle_fallback_selected = STZ.LST.CFG.selectedForeground.opacity(0.5)
        static fileprivate let progressForeground          = Color.accentColor
        #if canImport(AppKit)
        static fileprivate let thumbnailPlaceholder   = Color(NSColor.windowBackgroundColor)
        static fileprivate let numberCircleBackground = Color(NSColor.underPageBackgroundColor)
        static fileprivate let progressBackground     = Color(NSColor.windowBackgroundColor)
        #else
        static fileprivate let thumbnailPlaceholder   = Color(UIColor.tertiarySystemFill)
        static fileprivate let numberCircleBackground = Color(UIColor.systemFill)
        static fileprivate let progressBackground     = Color(UIColor.systemFill)
        #endif
    }
}
