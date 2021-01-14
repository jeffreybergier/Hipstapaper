//
//  Created by Jeffrey Bergier on 2020/12/13.
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
