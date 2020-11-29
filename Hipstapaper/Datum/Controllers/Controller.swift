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

public func ControllerNew(isTesting: Bool = false) throws -> Controller {
    return try CD_Controller(isTesting: isTesting)
}

public protocol Controller {

    static var storeDirectoryURL: URL { get }
    static var storeExists: Bool { get }

    // MARK: Websites CRUD
    func createWebsite(title: String?,
                       originalURL: URL?,
                       resolvedURL: URL?,
                       isArchived: Bool,
                       thumbnail: Data?)
                       -> Result<AnyElement<AnyWebsite>, Error>
    func readWebsites(query: Query,
                      sort: Sort)
                      -> Result<AnyCollection<AnyElement<AnyWebsite>>, Error>

    // MARK: Tags CRUD
    func createTag(name: String?) -> Result<AnyElement<AnyTag>, Error>
    func readTags() -> Result<AnyCollection<AnyElement<AnyTag>>, Error>
    func update(tag: AnyElement<AnyTag>, name: Optional<String?>) -> Result<Void, Error>
    func delete(tag: AnyElement<AnyTag>) -> Result<Void, Error>

}
