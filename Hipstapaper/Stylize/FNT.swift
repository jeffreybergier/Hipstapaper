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

public protocol Fontable {
    static var font: Font { get }
}

extension Fontable {
    public static func apply() -> STZ.FNT.Modifier { .init(self) }
}

extension STZ {
    public enum FNT {
        public struct Modifier: ViewModifier {
            public let fontable: Fontable.Type
            public func body(content: Content) -> some View {
                content.font(self.fontable.font)
            }
            public init(_ fontable: Fontable.Type) {
                self.fontable = fontable
            }
        }
        public enum IndexRow {
            public enum Title: Fontable {
                public static var font: Font = Font.body.weight(.medium)
            }
        }
        public enum IndexSection {
            public enum Title: Fontable {
                public static var font: Font = .caption
            }
        }
        public enum OvalIndicator: Fontable {
            public static var font: Font = Font.title
        }
        public enum Oval: Fontable {
            public static var font: Font = Font.callout.monospacedDigit()
        }
        public enum Sort: Fontable {
            public static var font: Font = .body
        }
        public enum DetailRow {
            public enum Title: Fontable {
                public static var font: Font = .body
            }
            public enum Subtitle: Fontable {
                public static var font: Font = .caption
            }
        }
        public enum Button {
            public enum Done: Fontable {
                public static var font: Font = .headline
            }
            public enum Default: Fontable {
                public static var font: Font = .body
            }
        }
        
        #if os(macOS)
        internal enum MDL {
            internal enum Title: Fontable {
                internal static var font: Font = .title3
            }
        }
        internal enum ACTN {
            internal enum Body: Fontable {
                internal static var font: Font = .body
            }
        }
        #endif
    }
}
