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

/**
 Observes an NSManagedObject in  a way that is useful to SwiftUI. Also provides a transform that
 can be used so that NSManagedObject does not leak into your UI layer. Basic usage looks like:
 Note: This class is not tested because it relies on NSManagedObject
 ```
try controller.performFetch()
return .success(
    AnyListObserver(
        FetchedResultsControllerListObserver(
            FetchedResultsControllerList(controller) {
                AnyElementObserver(ManagedObjectElementObserver($0, { AnyTag($0) }))
            }
        )
    )
)
 ```
 */
public class ManagedObjectElementObserver<Output, Input: NSManagedObject>: ElementObserver {
    
    public let objectWillChange: ObservableObjectPublisher
    public var value: Output { transform(_value) }
    public var isDeleted: Bool { _value.isDeleted }
    public let canDelete: Bool = true

    private let _value: Input
    private let transform: (Input) -> Output

    public init(_ input: Input, _ transform: @escaping (Input) -> Output) {
        self._value = input
        self.transform = transform
        self.objectWillChange = input.objectWillChange
    }
    
    public static func == (lhs: ManagedObjectElementObserver<Output, Input>, rhs: ManagedObjectElementObserver<Output, Input>) -> Bool {
        return lhs._value == rhs._value
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(_value)
    }
    
    #if DEBUG
    deinit {
        log.verbose()
    }
    #endif
}
