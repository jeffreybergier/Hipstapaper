//
//  Created by Jeffrey Bergier on 2020/11/26.
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

import CoreData
import Combine

internal class CD_Element<Output, Input: NSManagedObject>: Element {

    internal let objectWillChange: ObservableObjectPublisher
    internal var value: Output { transform(_value) }
    internal var isDeleted: Bool { _value.isDeleted }

    private let _value: Input
    private let transform: (Input) -> Output

    internal init(_ input: Input, _ transform: @escaping (Input) -> Output) {
        self._value = input
        self.transform = transform
        self.objectWillChange = input.objectWillChange
    }

}
