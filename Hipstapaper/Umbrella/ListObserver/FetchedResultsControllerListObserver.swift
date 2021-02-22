//
//  Created by Jeffrey Bergier on 2021/01/31.
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
 Takes an `FetchedResultsControllerList` and adapts it for use with SwiftUI.
 This class has no way to return errors so you must call performFetch on your own before
 The class is used.
 To prevent your data model (Core Data) from leaking into your UI layer use `AnyListObserver`:
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
public class FetchedResultsControllerListObserver<Output, Input: NSManagedObject>:
    NSObject, ListObserver, NSFetchedResultsControllerDelegate
{

    public var data: AnyList<Output>

    public init(_ list: FetchedResultsControllerList<Output, Input>) {
        self.data = AnyList(list)
        super.init()
        list.frc.delegate = self
    }

    // MARK: NSFetchedResultsControllerDelegate
    
    public func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.objectWillChange.send()
    }
    
    #if DEBUG
    // MARK: Testing Only
    
    /// for testing only
    internal init(__TESTING: Bool) where Input == NSManagedObject, Output == Never {
        self.data = AnyList([])
    }
    
    /// for testing only
    public var __objectDidChange = ObservableObjectPublisher()
    
    /// for testing only
    public func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        __objectDidChange.send()
    }
    
    deinit {
        log.verbose()
    }
    #endif
}
