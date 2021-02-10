//
//  Created by Jeffrey Bergier on 2021/02/10.
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
import XPList

extension STZ {
    public enum CLR { }
}

public protocol Colorable {
    static var color: Color { get }
}

public protocol Fallbackable: Colorable {
    static var fallbackColor: Color { get }
}

public protocol Selectable: Fallbackable {
    static var selectedColor: Color { get }
    static var fallbackSelectedColor: Color { get }
}

extension Colorable {
    public static func foreground() -> STZ.CLR.Foreground { .init(self) }
    public static func background() -> STZ.CLR.Background { .init(self) }
    public static func view() -> STZ.CLR.AsView { .init(self) }
}

extension STZ.CLR {
    public struct Foreground: ViewModifier {
        @State private var isFallback = false // set by preference
        @Environment(\.XPL_isSelected) private var isSelected
        public let colorable: Colorable.Type
        public init(_ colorable: Colorable.Type) {
            self.colorable = colorable
        }
        @ViewBuilder public func body(content: Content) -> some View {
            if let selectable = self.colorable as? Selectable.Type {
                content.foregroundColor(selectable.apply(self.isFallback, self.isSelected))
            } else if let fallbackable = self.colorable as? Fallbackable.Type {
                content.foregroundColor(fallbackable.apply(self.isFallback))
            } else {
                content.foregroundColor(self.colorable.color)
            }
        }
    }
    public struct Background: ViewModifier {
        @State private var isFallback = false // set by preference
        @Environment(\.XPL_isSelected) private var isSelected
        public let colorable: Colorable.Type
        public init(_ colorable: Colorable.Type) {
            self.colorable = colorable
        }
        @ViewBuilder public func body(content: Content) -> some View {
            if let selectable = self.colorable as? Selectable.Type {
                content.background(selectable.apply(self.isFallback, self.isSelected))
            } else if let fallbackable = self.colorable as? Fallbackable.Type {
                content.background(fallbackable.apply(self.isFallback))
            } else {
                content.background(self.colorable.color)
            }
        }
    }
    public struct AsView: View {
        @State private var isFallback = false // set by preference
        @Environment(\.XPL_isSelected) private var isSelected
        public let colorable: Colorable.Type
        public init(_ colorable: Colorable.Type) {
            self.colorable = colorable
        }
        @ViewBuilder public var body: some View {
            if let selectable = self.colorable as? Selectable.Type {
                selectable.apply(self.isFallback, self.isSelected)
            } else if let fallbackable = self.colorable as? Fallbackable.Type {
                fallbackable.apply(self.isFallback)
            } else {
                self.colorable.color
            }
        }
    }
}

extension Fallbackable {
    fileprivate static func apply(_ isFallback: Bool) -> Color {
        return isFallback ? self.fallbackColor : self.color
    }
}
extension Selectable {
    fileprivate static func apply(_ isFallback: Bool, _ isSelected: Bool) -> Color {
        switch (isSelected, isFallback) {
        case (true, true):
            return self.fallbackSelectedColor
        case (true, false):
            return self.selectedColor
        case (false, true):
            return self.fallbackColor
        case (false, false):
            return self.color
        }
    }
}
