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
                public static var font: Font = .headline
            }
        }
    }
}
