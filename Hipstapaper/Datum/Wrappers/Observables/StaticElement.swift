//
//  Created by Jeffrey Bergier on 2020/12/05.
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

/// Element that does not properly observe its Value
public class StaticElement<T: Hashable>: Element {
    public var value: T
    public var isDeleted: Bool { fatalError("StaticElement does not know this") }
    public init(_ value: T) {
        self.value = value
    }
    
    public static func == (lhs: StaticElement<T>, rhs: StaticElement<T>) -> Bool {
        return lhs.value == rhs.value
    }
    
    public var hashValue: Int {
        return self.hashValue
    }
}
