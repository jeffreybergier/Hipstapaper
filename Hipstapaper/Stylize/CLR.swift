//
//  Created by Jeffrey Bergier on 2021/01/15.
//
//  MIT License
//
//  Copyright (c) 2021 jeffreybergier
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//

import SwiftUI
#if canImport(AppKit)
import AppKit
#else
import UIKit
#endif

extension STZ.CLR {
    public enum Window: Colorable {
        public static var color = Raw.window
    }
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
    public enum TB {
        public enum Tint: Colorable {
            public static var color: Color = Raw.toolbarTint
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
    #endif
    
    fileprivate enum Raw {
        static fileprivate let textTitle                   = STZ.LST.CFG.deselectedForeground
        static fileprivate let textTitle_fallback          = STZ.LST.CFG.deselectedForeground.opacity(0.5)
        static fileprivate let textTitle_selected          = STZ.LST.CFG.selectedForeground
        static fileprivate let textTitle_fallback_selected = STZ.LST.CFG.selectedForeground.opacity(0.5)
        static fileprivate let toolbarTint                 = Color.accentColor
        static fileprivate let progressForeground          = Color.accentColor
        #if canImport(AppKit)
        static fileprivate let thumbnailPlaceholder   = Color(NSColor.windowBackgroundColor)
        static fileprivate let numberCircleBackground = Color(NSColor.windowBackgroundColor)
        static fileprivate let progressBackground     = Color(NSColor.windowBackgroundColor)
        static fileprivate let window                 = Color(NSColor.windowBackgroundColor)
        #else
        static fileprivate let thumbnailPlaceholder   = Color(UIColor.tertiarySystemFill)
        static fileprivate let numberCircleBackground = Color(UIColor.systemFill)
        static fileprivate let progressBackground     = Color(UIColor.systemFill)
        static fileprivate let window                 = Color(UIColor.systemBackground)
        #endif
    }
}
