//
//  Created by Jeffrey Bergier on 2021/02/10.
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
                content
                    .onPreferenceChange(STZ.isFallbackKey.self, perform: { self.isFallback = $0 })
                    .foregroundColor(selectable.apply(self.isFallback, self.isSelected))
            } else if let fallbackable = self.colorable as? Fallbackable.Type {
                content
                    .onPreferenceChange(STZ.isFallbackKey.self, perform: { self.isFallback = $0 })
                    .foregroundColor(fallbackable.apply(self.isFallback))
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
                content
                    .onPreferenceChange(STZ.isFallbackKey.self, perform: { self.isFallback = $0 })
                    .background(selectable.apply(self.isFallback, self.isSelected))
            } else if let fallbackable = self.colorable as? Fallbackable.Type {
                content
                    .onPreferenceChange(STZ.isFallbackKey.self, perform: { self.isFallback = $0 })
                    .background(fallbackable.apply(self.isFallback))
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
                selectable
                    .apply(self.isFallback, self.isSelected)
                    .onPreferenceChange(STZ.isFallbackKey.self, perform: { self.isFallback = $0 })
            } else if let fallbackable = self.colorable as? Fallbackable.Type {
                fallbackable
                    .apply(self.isFallback)
                    .onPreferenceChange(STZ.isFallbackKey.self, perform: { self.isFallback = $0 })
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
