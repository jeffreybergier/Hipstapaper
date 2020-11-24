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

internal class CD_ObservableCollection<Item: NSManagedObject>: NSObject,
                                                             ObservableObject,
                                                             NSFetchedResultsControllerDelegate
{

    internal let objectWillChange = ObservableObjectPublisher()
    private let fetchedResultsController: NSFetchedResultsController<Item>

    /// Init with `NSFetchedResultsController`
    /// This class does not call `performFetch` on its own.
    /// Call `performFetch()` yourself before this is used.
    internal init(fetchedResultsController: NSFetchedResultsController<Item>) {
        self.fetchedResultsController = fetchedResultsController
        super.init()
        fetchedResultsController.delegate = self
    }

    internal var collection: [CD_ObjectWrapper<Item>] {
        let original = self.fetchedResultsController.fetchedObjects ?? []
        return original.lazy.map { CD_ObjectWrapper<Item>($0) }
    }

    internal func controller(_ controller: AnyObject, didChangeContentWith snapshot: AnyObject) {
        self.objectWillChange.send()
    }
}
