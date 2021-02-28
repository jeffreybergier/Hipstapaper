//
//  Created by Jeffrey Bergier on 2020/12/11.
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

public protocol Sizeable {
    static var size: CGFloat { get }
}

extension Sizeable {
    public static func apply() -> STZ.CRN.Modifier {
        .init(radius: self.size)
    }
}

extension STZ {
    public enum CRN {
        public struct Modifier: ViewModifier {
            public let radius: CGFloat
            public func body(content: Content) -> some View {
                content.cornerRadius(self.radius)
            }
            public init(radius: CGFloat) {
                self.radius = radius
            }
        }
        public enum Small: Sizeable {
            public static let size: CGFloat = 4
        }
        public enum Medium: Sizeable {
            public static let size: CGFloat = 8
        }
        public enum Large: Sizeable {
            public static let size: CGFloat = 16
        }
    }
}
