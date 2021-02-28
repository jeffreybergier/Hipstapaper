//
//  Created by Jeffrey Bergier on 2020/12/13.
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

// TODO: Add Paddable protocol here

extension STZ {
    public enum PDG {
        public struct Modifier: ViewModifier {
            public let insets: EdgeInsets
            public let ignore: EdgeInsets.Sides
            public func body(content: Content) -> some View {
                content.padding(self.insets.removing(self.ignore))
            }
            public init(insets: EdgeInsets, ignore: EdgeInsets.Sides = []) {
                self.insets = insets
                self.ignore = ignore
            }
        }
        internal static func TB(ignore: EdgeInsets.Sides = []) -> Modifier {
            .init(insets: EdgeInsets(top: 12, leading: 12, bottom: 12, trailing: 12),
                  ignore: ignore)
        }
        internal static func Oval(ignore: EdgeInsets.Sides = []) -> Modifier {
            .init(insets: EdgeInsets(top: 3, leading: 8, bottom: 3, trailing: 8),
                  ignore: ignore)
        }
        public static func Default(ignore: EdgeInsets.Sides = []) -> Modifier {
            .init(insets: EdgeInsets(top: 4, leading: 12, bottom: 4, trailing: 12),
                  ignore: ignore)
        }
        public static func Equal(ignore: EdgeInsets.Sides = []) -> Modifier {
            .init(insets: EdgeInsets(top: 12, leading: 12, bottom: 12, trailing: 12),
                  ignore: ignore)
        }
    }
}

extension EdgeInsets {
    public typealias Side = WritableKeyPath<EdgeInsets, CGFloat>
    public typealias Sides = Set<Side>
    
    mutating internal func remove(_ sides: Sides) {
        for side in sides {
            self[keyPath: side] = 0
        }
    }
    internal func removing(_ sides: Sides) -> EdgeInsets {
        var copy = self
        copy.remove(sides)
        return copy
    }
}
