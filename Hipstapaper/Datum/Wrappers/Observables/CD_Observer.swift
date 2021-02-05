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

internal class CD_Observer<Output, Input: NSManagedObject>: NSObject,
                                                            Observer,
                                                            NSFetchedResultsControllerDelegate
{

    internal var data: AnyList<Output>

    internal init(_ list: CD_List<Output, Input>)
    {
        self.data = AnyList(list)
        super.init()
        list.frc.delegate = self
    }

    // MARK: NSFetchedResultsControllerDelegate

    @objc(controllerWillChangeContent:)
    internal func controllerWillChangeContent(_ controller: AnyObject) {
        self.objectWillChange.send()
    }
    
    /// MARK: Testing Only
    internal var __objectDidChange = ObservableObjectPublisher()
    
    @objc(controllerDidChangeContent:)
    internal func controllerDidChangeContent(_ controller: AnyObject) {
        __objectDidChange.send()
    }
}
