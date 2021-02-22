//
//  Created by Jeffrey Bergier on 2020/11/24.
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
 Takes `NSFetchedResultsController` and tranform closure. This list lazily converts values
 with the provided closure. This way it is possible to not let NSManagedObjects leak into your UI
 layer in an efficient way. You probably want to use the transform to wrap the NSManagedObject
 in `ManagedObjectElementObserver` so that it can be observed.
 This struct has no way to return errors so you must call `performFetch` on your own before using.
 To prevent core data from leaking into your UI layer, use `AnyList`.
 Note: this struct is not tested because it relies on NSFetchedResultsController
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
public struct FetchedResultsControllerList<Output, Input: NSManagedObject>: RandomAccessCollection {
    
    public typealias Index = Int
    public typealias Element = Output

    internal let frc: NSFetchedResultsController<Input>
    private let transform: (Input) -> Output

    /// Init with `NSFetchedResultsController`
    /// This class does not call `performFetch` on its own.
    /// Call `performFetch()` yourself before this is used.
    public init(_ frc: NSFetchedResultsController<Input>,
                _ transform: @escaping (Input) -> Output)
    {
        self.frc = frc
        self.transform = transform
    }

    // MARK: Swift.Collection Boilerplate
    public var startIndex: Index { self.frc.fetchedObjects!.startIndex }
    public var endIndex: Index { self.frc.fetchedObjects!.endIndex }
    public subscript(index: Index) -> Element { self.transform(self.frc.fetchedObjects![index]) }
}
