//
//  Created by Jeffrey Bergier on 2021/02/18.
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

import Combine

/// Takes any value and wraps it in an identifiable box.
/// Identity means nothing here. But this is useful when using
/// View.sheet/.alert/.popover with an item that is not identifiable
public struct IdentBox<Value>: Identifiable {
    public var id = UUID()
    public var value: Value
    public init(_ value: Value) {
        self.value = value
    }
}
