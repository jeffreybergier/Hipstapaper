//
//  Created by Jeffrey Bergier on 2020/12/11.
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
        public static func small() -> Modifier {
            .init(radius: 4)
        }
        public static func medium() -> Modifier {
            .init(radius: 8)
        }
        public static func large() -> Modifier {
            .init(radius: 16)
        }
    }
}
