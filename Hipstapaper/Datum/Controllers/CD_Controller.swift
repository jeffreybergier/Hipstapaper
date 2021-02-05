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

    // MARK: Website CRUD

    func createWebsite(_ raw: AnyWebsite.Raw) -> Result<AnyElementObserver<AnyWebsite>, Error> {
        assert(Thread.isMainThread)

        let context = self.container.viewContext
        let website = CD_Website(context: context)
        if let title = raw.title {
            website.cd_title = title
        }
        if let originalURL = raw.originalURL {
            website.cd_originalURL = originalURL
        }
        if let resolvedURL = raw.resolvedURL {
            website.cd_resolvedURL = resolvedURL
        }
        if let isArchived = raw.isArchived {
            website.cd_isArchived = isArchived
        }
        if let thumbnail = raw.thumbnail {
            website.cd_thumbnail = thumbnail
        }
        website.datum_willSave()
        return context.datum_save().map {
            AnyElementObserver(CD_Element(website, { AnyWebsite($0) }))
        }
    }

    func readWebsites(query: Query) -> Result<AnyListObserver<AnyList<AnyElementObserver<AnyWebsite>>>, Error> {
        assert(Thread.isMainThread)

        let context = self.container.viewContext
        let request = CD_Website.request
        request.predicate = query.cd_predicate
        request.sortDescriptors = query.cd_sortDescriptors

        let controller = NSFetchedResultsController(fetchRequest: request,
                                                    managedObjectContext: context,
                                                    sectionNameKeyPath: nil,
                                                    cacheName: nil)
        do {
            try controller.performFetch()
            return .success(
                AnyListObserver(
                    CD_ListObserver(
                        CD_List(controller) {
                            AnyElementObserver(CD_Element($0, { AnyWebsite($0) }))
                        }
                    )
                )
            )
        } catch {
            return .failure(.unknown)
        }
    }
    
    func update(_ inputs: Set<AnyElementObserver<AnyWebsite>>, _ raw: AnyWebsite.Raw) -> Result<Void, Error> {
        assert(Thread.isMainThread)
        
        let context = self.container.viewContext
        var inputs = inputs
        var changesMade = false
        
        while !inputs.isEmpty {
            let input = inputs.popFirst()!
            guard let website = input.value.wrappedValue as? CD_Website else {
                log.error("Wrong type: \(input.value.wrappedValue)")
                return .failure(.unknown)
            }
            
            if let title = raw.title {
                changesMade = true
                website.cd_title = title
            }
            if let originalURL = raw.originalURL {
                changesMade = true
                website.cd_originalURL = originalURL
            }
            if let resolvedURL = raw.resolvedURL {
                changesMade = true
                website.cd_resolvedURL = resolvedURL
            }
            if let isArchived = raw.isArchived {
                changesMade = true
                website.cd_isArchived = isArchived
            }
            if let thumbnail = raw.thumbnail {
                changesMade = true
                website.cd_thumbnail = thumbnail
            }
            if changesMade {
                website.datum_willSave()
            }
        }
        return changesMade ? context.datum_save() : .success(())
    }
    
    func delete(_ inputs: Set<AnyElementObserver<AnyWebsite>>) -> Result<Void, Error> {
        assert(Thread.isMainThread)

        let context = self.container.viewContext

        var inputs = inputs
        var changesMade = false
        
        while !inputs.isEmpty {
            let input = inputs.popFirst()!
            guard let website = input.value.wrappedValue as? CD_Website else {
                log.error("Wrong type: \(input.value.wrappedValue)")
                return .failure(.unknown)
            }
            changesMade = true
            context.delete(website)
        }

        return changesMade ? context.datum_save() : .success(())
    }

    // MARK: Tag CRUD

    func createTag(name: String?) -> Result<AnyElementObserver<AnyTag>, Error> {
        assert(Thread.isMainThread)

        let context = self.container.viewContext

        let tag = CD_Tag(context: context)
        tag.cd_name = name
        tag.willSave()
        return context.datum_save().map {
            AnyElementObserver(CD_Element(tag, { AnyTag($0) }))
        }
    }

    func readTags() -> Result<AnyListObserver<AnyList<AnyElementObserver<AnyTag>>>, Error> {
        assert(Thread.isMainThread)

        let context = self.container.viewContext
        let request = CD_Tag.request
        request.sortDescriptors = [
            .init(key: #keyPath(CD_Tag.cd_name), ascending: true)
        ]
        let controller = NSFetchedResultsController(fetchRequest: request,
                                                    managedObjectContext: context,
                                                    sectionNameKeyPath: nil,
                                                    cacheName: nil)
        do {
            try controller.performFetch()
            return .success(
                AnyListObserver(
                    CD_ListObserver(
                        CD_List(controller) {
                            AnyElementObserver(CD_Element($0, { AnyTag($0) }))
                        }
                    )
                )
            )
        } catch {
            return .failure(.unknown)
        }
    }

    func update(_ input: AnyElementObserver<AnyTag>, name: Optional<String?>) -> Result<Void, Error> {
        assert(Thread.isMainThread)

        guard let tag = input.value.wrappedValue as? CD_Tag else {
            log.error("Wrong type: \(input.value.wrappedValue)")
            return .failure(.unknown)
        }
        let context = self.container.viewContext

        var changesMade = false
        if let newName = name {
            changesMade = true
            tag.cd_name = newName
            tag.datum_willSave()
        }

        return changesMade ? context.datum_save() : .success(())
    }

    func delete(_ input: AnyElementObserver<AnyTag>) -> Result<Void, Error> {
        assert(Thread.isMainThread)

        guard let tag = input.value.wrappedValue as? CD_Tag else {
            log.error("Wrong type: \(input.value.wrappedValue)")
            return .failure(.unknown)
        }
        let context = self.container.viewContext
        context.delete(tag)
        return context.datum_save()
    }
    
    // MARK: Custom Functions
    
    func add(tag: AnyElementObserver<AnyTag>, to _sites: Set<AnyElementObserver<AnyWebsite>>) -> Result<Void, Error> {
        let sites = _sites.compactMap { $0.value.wrappedValue as? CD_Website }
        guard
            sites.count == _sites.count,
            let tag = tag.value.wrappedValue as? CD_Tag
        else { return .failure(.unknown) }
        
        let context = self.container.viewContext
        
        var changesMade = false
        for site in sites {
            guard site.cd_tags.contains(tag) == false else { continue }
            changesMade = true
            let tags = site.mutableSetValue(forKey: #keyPath(CD_Website.cd_tags))
            tags.add(tag)
            site.datum_willSave()
        }
        
        if changesMade {
            tag.datum_willSave()
            return context.datum_save()
        } else {
            return .success(())
        }
    }
    
    func remove(tag: AnyElementObserver<AnyTag>, from _sites: Set<AnyElementObserver<AnyWebsite>>) -> Result<Void, Error> {
        let sites = _sites.compactMap { $0.value.wrappedValue as? CD_Website }
        guard
            sites.count == _sites.count,
            let tag = tag.value.wrappedValue as? CD_Tag
        else { return .failure(.unknown) }
        
        let context = self.container.viewContext
        
        var changesMade = false
        for site in sites {
            guard site.cd_tags.contains(tag) == true else { continue }
            changesMade = true
            let tags = site.mutableSetValue(forKey: #keyPath(CD_Website.cd_tags))
            tags.remove(tag)
            site.datum_willSave()
        }
        
        if changesMade {
            tag.datum_willSave()
            return context.datum_save()
        } else {
            return .success(())
        }
    }
    
    func tagStatus(for _sites: Set<AnyElementObserver<AnyWebsite>>)
                  -> Result<AnyList<(AnyElementObserver<AnyTag>, ToggleState)>, Error>

    {
        let sites = _sites.compactMap { $0.value.wrappedValue as? CD_Website }
        guard sites.count == _sites.count else { return .failure(.unknown) }
        return self.readTags().map() { tags in
            return AnyList(
                MappedList(tags.data) { tag in
                    let tag = tag.value.wrappedValue as! CD_Tag
                    return ToggleState(sites.map {
                        $0.cd_tags.contains(tag)
                    })
                }
            )
        }
    }
}

internal class CD_Controller {

    static internal let storeDirectoryURL: URL = {
        return FileManager
            .default
            .urls(for: .applicationSupportDirectory, in: .userDomainMask)
            .first!
            .appendingPathComponent("Hipstapaper", isDirectory: true)
            .appendingPathComponent("CoreData", isDirectory: true)
    }()

    static internal var storeExists: Bool {
        return FileManager.default.fileExists(
            atPath: self.storeDirectoryURL.appendingPathComponent("Store.sqlite").path
        )
    }

    internal let syncMonitor: AnySyncMonitor
    internal let container: NSPersistentContainer
    
    internal init(isTesting: Bool) throws {
        // debug only sanity checks
        assert(Thread.isMainThread)

        guard let container = CD_Controller.container(isTesting: isTesting)
            else { throw Error.critical }
        let lock = DispatchSemaphore(value: 0)
        var error: Swift.Error?
        container.loadPersistentStores() { _, _error in
            error = _error
            lock.signal()
        }
        lock.wait()
        if let error = error { throw error }
        container.viewContext.automaticallyMergesChangesFromParent = true
        self.container = container
        
        if #available(iOS 14.0, OSX 11.0, *) {
            self.syncMonitor = AnySyncMonitor(CD_SyncMonitor(container))
        } else {
            self.syncMonitor = AnySyncMonitor(NoSyncMonitor())
        }
    }
    
    deinit {
        // TODO: Remove later
        log.emergency()
    }
}

extension CD_Controller {

    // If the MOM is loaded more than once, it prints warnings to the console
    private static let mom: NSManagedObjectModel? = {
        guard let url = Bundle(for: CD_Controller.self).url(forResource: "CD_MOM",
                                                            withExtension: "momd")
        else { log.emergency("Couldn't find MOM"); return nil }
        return NSManagedObjectModel(contentsOf: url)
    }()

    private class func container(isTesting: Bool) -> NSPersistentContainer? {
        // debug only sanity checks
        assert(Thread.isMainThread)

        guard let mom = CD_Controller.mom else { log.emergency("Couldn't find MOM"); return nil }

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

private class Datum_PersistentContainer: NSPersistentCloudKitContainer {
    override class func defaultDirectoryURL() -> URL {
        let url = CD_Controller.storeDirectoryURL
        log.debug(url)
        return url
    }
}

extension NSManagedObjectContext {
    fileprivate func datum_save() -> Result<Void, Error> {
        do {
            try self.save()
            return .success(())
        } catch {
            log.error(error)
            self.rollback()
            return .failure(.unknown)
        }
    }
}
