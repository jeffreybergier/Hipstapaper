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

public protocol Colorable {
    static var color: Color { get }
    static var darkColor: Color { get }
}

extension Colorable {
    public static func foreground() -> STZ.CLR.Foreground { .init(self) }
    public static func background() -> STZ.CLR.Background { .init(self) }
    public static func view() -> STZ.CLR.Dynamic { .init(self) }
}

extension STZ {
    public enum CLR {
        public struct Foreground: ViewModifier {
            @Environment(\.colorScheme) private var colorScheme
            @State private var isFallback = false // set by preference
            public let colorable: Colorable.Type
            public func body(content: Content) -> some View {
                return content
                    .onPreferenceChange(STZ.VIEW.isFallBackKey.self, perform: { self.isFallback = $0 })
                    .foregroundColor(self.colorScheme.isNormal
                                        ? self.colorable.color
                                        : self.colorable.darkColor)
                    .opacity(self.isFallback
                                ? 0.4
                                : 1.0)
            }
            public init(_ colorable: Colorable.Type) {
                self.colorable = colorable
            }
        }
        public struct Background: ViewModifier {
            @Environment(\.colorScheme) private var colorScheme
            public let colorable: Colorable.Type
            public func body(content: Content) -> some View {
                return content
                    .background(self.colorScheme.isNormal
                                    ? self.colorable.color
                                    : self.colorable.darkColor)
            }
            public init(_ colorable: Colorable.Type) {
                self.colorable = colorable
            }
        }
        public struct Dynamic: View {
            @Environment(\.colorScheme) private var colorScheme
            public let colorable: Colorable.Type
            public var body: Color {
                self.colorScheme.isNormal
                    ? self.colorable.color
                    : self.colorable.darkColor
            }
            public init(_ colorable: Colorable.Type) {
                self.colorable = colorable
            }
        }
        public enum IndexRow {
            public enum Text: Colorable {
                public static let color = Raw.textTitle
                public static let darkColor = Raw.textTitle_Dark
            }
        }
        public enum IndexSection {
            public enum Text: Colorable {
                public static let color = Raw.textTitle
                public static let darkColor = Raw.textTitle_Dark
            }
        }
        public enum DetailRow {
            public enum Text: Colorable {
                public static let color = Raw.textTitle
                public static let darkColor = Raw.textTitle_Dark
            }
        }
        internal enum Thumbnail {
            public enum Icon: Colorable {
                public static let color = Raw.textTitle
                public static let darkColor = Raw.textTitle_Dark
            }
            public enum Background: Colorable {
                public static let color = Raw.thumbnailPlaceholder
                public static let darkColor = Raw.thumbnailPlaceholder_Dark
            }
        }
        public enum Oval {
            public enum Text: Colorable {
                public static let color = Raw.textTitle
                public static let darkColor = Raw.textTitle_Dark
            }
            public enum Background: Colorable {
                public static let color = Raw.numberCircleBackground
                public static let darkColor = Raw.numberCircleBackground_Dark
            }
        }
        
        #if os(macOS)
        internal enum MDL {
            internal enum Title: Colorable {
                static let color = Raw.textTitle
                static let darkColor = Raw.textTitle
            }
        }
        internal enum ACTN {
            internal enum Body: Colorable {
                static let color = Raw.textTitle
                static let darkColor = Raw.textTitle
            }
        }
        internal enum TB {
            internal enum Tint: Colorable {
                static var color: Color { Color(NSColor.controlAccentColor) }
                static var darkColor: Color { Color(NSColor.controlAccentColor) }
            }
        }
        #endif
        
        fileprivate enum Raw {
            static fileprivate let textTitle: Color  = .black
            static fileprivate let textTitle_Dark: Color   = .white
            static fileprivate let thumbnailPlaceholder = Color(.sRGB, white: 0.95, opacity: 1.0)
            static fileprivate let thumbnailPlaceholder_Dark = Color(.sRGB, white: 0.2, opacity: 1.0)
            static fileprivate let numberCircleBackground = Color(.sRGB, white: 0.75, opacity: 1.0)
            static fileprivate let numberCircleBackground_Dark = Color(.sRGB, white: 0.2, opacity: 1.0)
        }
    }
}


extension ColorScheme {
    fileprivate var isNormal: Bool {
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
