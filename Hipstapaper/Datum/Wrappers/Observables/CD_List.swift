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

internal class CD_List<
    Output,
    Input: NSManagedObject
>: NSObject, ListProtocol, NSFetchedResultsControllerDelegate
{

    public typealias Index = Int
    public typealias Element = Output

    private let frc: NSFetchedResultsController<Input>
    private let transform: (Input) -> Output
    // TODO: Remove these hacks once SwiftUI doesn't crash so easily with the FRC
    private let fallback: Output

    /// Init with `NSFetchedResultsController`
    /// This class does not call `performFetch` on its own.
    /// Call `performFetch()` yourself before this is used.
    internal init(_ frc: NSFetchedResultsController<Input>,
                  fallback: Output,
                  _ transform: @escaping (Input) -> Output)
    {
        self.frc = frc
        self.transform = transform
        self.fallback = fallback
        super.init()
        frc.delegate = self
    }

    // MARK: Swift.Collection Boilerplate
    public var startIndex: Index { 0 }
    public var endIndex: Index { self.frc.fetchedObjects!.count }
    public subscript(index: Index) -> Iterator.Element {
        let objects = self.frc.fetchedObjects!
        guard index < objects.count else {
            return self.fallback
        }
        return transform(objects[index])
    }

    // MARK: NSFetchedResultsControllerDelegate

    // TODO: Changing to this works in iOS
    // But it crashes in macOS
    //    @objc(controllerWillChangeContent:)
    //    internal func controllerWillChangeContent(_ controller: AnyObject) {
    //        self.objectWillChange.send()
    //    }
    
    //    @objc(controller:didChangeContentWithSnapshot:)
    //    internal func controller(_: AnyObject, didChangeContentWith _: AnyObject) {
    //        self.objectWillChange.send()
    //    }
    
    // Using this one makes the tests work as expected
    // And all 3 of these options appear to have the same crashes in app
    @objc(controllerDidChangeContent:)
    internal func controllerDidChangeContent(_ controller: AnyObject) {
        self.objectWillChange.send()
    }
}
