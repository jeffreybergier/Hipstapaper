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
import SwiftUI

extension CD_Controller: Controller {

    func createWebsite(title: String?, originalURL: URL?, resolvedURL: URL?, thumbnailData: Data?) -> Result<Void, Error> {
        return .failure(.unknown)
    }

    func createTag(name: String?) -> Result<Void, Error> {
        assert(Thread.isMainThread)
        let context = self.container.viewContext
        let tag = CD_Tag(context: context)
        tag.name = name
        return context.datum_save()
    }

    func readWebsites() -> Result<Void, Error> {
        return .failure(.unknown)
    }

    func readTags() -> Result<AnyCollection<AnyElement<Tag>>, Error> {
        assert(Thread.isMainThread)
        let context = self.container.viewContext
        let request = CD_Tag.request
        request.sortDescriptors = [
            .init(key: #keyPath(CD_Tag.name), ascending: true)
        ]
        let controller = NSFetchedResultsController(fetchRequest: request,
                                                    managedObjectContext: context,
                                                    sectionNameKeyPath: nil,
                                                    cacheName: nil)
        do {
            try controller.performFetch()
            return .success(AnyCollection(CD_Collection(controller, { AnyElement(CD_Element($0, { $0 as Tag })) })))
        } catch {
            return .failure(.unknown)
        }
    }
}

internal class CD_Controller {

    static let storeDirectoryURL: URL = {
        return FileManager
            .default
            .urls(for: .applicationSupportDirectory, in: .userDomainMask)
            .first!
            .appendingPathComponent("Hipstapaper", isDirectory: true)
            .appendingPathComponent("CoreData", isDirectory: true)
    }()

    static var storeExists: Bool {
        return FileManager.default.fileExists(
            atPath: self.storeDirectoryURL.appendingPathComponent("Store.sqlite").path
        )
    }

    let container: NSPersistentContainer

    init(isTesting: Bool) throws {
        // debug only sanity checks
        assert(Thread.isMainThread)

        guard let container = CD_Controller.container(isTesting: isTesting)
            else { throw Error.unknown }
        let lock = DispatchSemaphore(value: 0)
        var error: Swift.Error?
        container.loadPersistentStores() { _, _error in
            error = _error
            lock.signal()
        }
        lock.wait()
        guard error == nil else { throw error! }
        container.viewContext.automaticallyMergesChangesFromParent = true
        self.container = container
    }
}

extension CD_Controller {

    private class func container(isTesting: Bool) -> NSPersistentContainer? {
        // debug only sanity checks
        assert(Thread.isMainThread)

        guard
            let url = Bundle(for: CD_Controller.self)
                            .url(forResource: "CD_MOM", withExtension: "momd"),
            let mom = NSManagedObjectModel(contentsOf: url)
        else { return nil }

        // when not testing, return normal persistent container
        guard isTesting else {
            return Datum_PersistentContainer(name: "Store", managedObjectModel: mom)
        }

        // when testing make in-memory container
        let randomName = String(Int.random(in: 100_000...1_000_000))
        let container = Datum_PersistentContainer(name: randomName, managedObjectModel: mom)
        let description = NSPersistentStoreDescription()
        description.type = NSInMemoryStoreType
        container.persistentStoreDescriptions = [description]
        return container
    }
}

private class Datum_PersistentContainer: NSPersistentContainer {
    override class func defaultDirectoryURL() -> URL {
        return CD_Controller.storeDirectoryURL
    }
}

extension NSManagedObjectContext {
    fileprivate func datum_save() -> Result<Void, Error> {
        do {
            try self.save()
            return .success(())
        } catch {
            self.rollback()
            return .failure(.unknown)
        }
    }
}
