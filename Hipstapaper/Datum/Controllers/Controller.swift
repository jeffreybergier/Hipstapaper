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

// Read more about FetchedResults type
// https://developer.apple.com/documentation/swiftui/fetchedresults
// https://www.raywenderlich.com/9335365-core-data-with-swiftui-tutorial-getting-started

import Umbrella

public func ControllerNew() -> Result<Controller, Error> {
    return CD_Controller.new()
}

public protocol Controller {

    static var storeDirectoryURL: URL { get }
    static var storeExists: Bool { get }
    
    // MARK: Sync
    var syncMonitor: AnySyncMonitor { get }

    // MARK: Websites CRUD
    func createWebsite(_: AnyWebsite.Raw) -> Result<AnyElementObserver<AnyWebsite>, Error>
    func readWebsites(query: Query) -> Result<AnyListObserver<AnyList<AnyElementObserver<AnyWebsite>>>, Error>
    func update(_: Set<AnyElementObserver<AnyWebsite>>, _: AnyWebsite.Raw) -> Result<Void, Error>
    func delete(_: Set<AnyElementObserver<AnyWebsite>>) -> Result<Void, Error>

    // MARK: Tags CRUD
    func createTag(name: String?) -> Result<AnyElementObserver<AnyTag>, Error>
    func readTags() -> Result<AnyListObserver<AnyList<AnyElementObserver<AnyTag>>>, Error>
    func update(_: AnyElementObserver<AnyTag>, name: Optional<String?>) -> Result<Void, Error>
    func delete(_: AnyElementObserver<AnyTag>) -> Result<Void, Error>
    
    // MARK: Custom Functions
    func add(tag: AnyElementObserver<AnyTag>, to websites: Set<AnyElementObserver<AnyWebsite>>) -> Result<Void, Error>
    func remove(tag: AnyElementObserver<AnyTag>, from websites: Set<AnyElementObserver<AnyWebsite>>) -> Result<Void, Error>
    func tagStatus(for websites: Set<AnyElementObserver<AnyWebsite>>) -> Result<AnyList<(AnyElementObserver<AnyTag>, ToggleState)>, Error>
}
