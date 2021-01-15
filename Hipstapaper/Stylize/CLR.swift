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

public protocol Colorable {
    static var color: Color { get }
    static var darkColor: Color { get }
}

extension Colorable {
    public static func foreground() -> STZ.CLR.Modifier { .init(self) }
}

extension STZ {
    public enum CLR {
        public struct Modifier: ViewModifier {
            @Environment(\.colorScheme) private var colorScheme
            @State private var isFallback = false // set by preference
            public let colorable: Colorable.Type
            public func body(content: Content) -> some View {
                return content
                    .onPreferenceChange(STZ.VIEW.isFallBackKey.self, perform: { self.isFallback = $0 })
                    .foregroundColor(self.colorScheme.isNormal
                                        ? Color.textTitle
                                        : Color.textTitle_Dark)
                    .opacity(self.isFallback
                                ? 0.4
                                : 1.0)
            }
            public init(_ colorable: Colorable.Type) {
                self.colorable = colorable
            }
        }
        public enum IndexRow {
            public enum Text: Colorable {
                public static var color: Color = Color.textTitle
                public static var darkColor: Color = Color.textTitle_Dark
            }
        }
    }
}
