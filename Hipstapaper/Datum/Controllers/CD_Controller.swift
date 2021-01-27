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

    func createWebsite(_ raw: AnyWebsite.Raw) -> Result<AnyElement<AnyWebsite>, Error> {
        assert(Thread.isMainThread)

        let context = self.container.viewContext
        let token = self.willSave(context)
        defer { self.didSave(token) }

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
        return context.datum_save().map {
            AnyElement(CD_Element(website, { AnyWebsite($0) }))
        }
    }

    func readWebsites(query: Query) -> Result<AnyList<AnyElement<AnyWebsite>>, Error> {
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
                AnyList(
                    CD_List(controller, fallback: AnyWebsite.blank) {
                        AnyElement(CD_Element($0, { AnyWebsite($0) }))
                    }
                )
            )
        } catch {
            return .failure(.unknown)
        }
    }
    
    func update(_ inputs: Set<AnyElement<AnyWebsite>>, _ raw: AnyWebsite.Raw) -> Result<Void, Error> {
        assert(Thread.isMainThread)
        
        let context = self.container.viewContext
        let token = self.willSave(context)
        defer { self.didSave(token) }

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
        }
        
        return changesMade ? context.datum_save() : .success(())
    }
    
    func delete(_ inputs: Set<AnyElement<AnyWebsite>>) -> Result<Void, Error> {
        assert(Thread.isMainThread)

        let context = self.container.viewContext
        let token = self.willSave(context)
        defer { self.didSave(token) }

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

    func createTag(name: String?) -> Result<AnyElement<AnyTag>, Error> {
        assert(Thread.isMainThread)

        let context = self.container.viewContext
        let token = self.willSave(context)
        defer { self.didSave(token) }

        let tag = CD_Tag(context: context)
        tag.cd_name = name
        return context.datum_save().map {
            AnyElement(CD_Element(tag, { AnyTag($0) }))
        }
    }

    func readTags() -> Result<AnyList<AnyElement<AnyTag>>, Error> {
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
                AnyList(
                    CD_List(controller, fallback: AnyTag.blank) {
                        AnyElement(CD_Element($0, { AnyTag($0) }))
                    }
                )
            )
        } catch {
            return .failure(.unknown)
        }
    }

    func update(_ input: AnyElement<AnyTag>, name: Optional<String?>) -> Result<Void, Error> {
        assert(Thread.isMainThread)

        guard let tag = input.value.wrappedValue as? CD_Tag else {
            log.error("Wrong type: \(input.value.wrappedValue)")
            return .failure(.unknown)
        }
        let context = self.container.viewContext
        let token = self.willSave(context)
        defer { self.didSave(token) }

        var changesMade = false
        if let newName = name {
            changesMade = true
            tag.cd_name = newName
        }

        return changesMade ? context.datum_save() : .success(())
    }

    func delete(_ input: AnyElement<AnyTag>) -> Result<Void, Error> {
        assert(Thread.isMainThread)

        guard let tag = input.value.wrappedValue as? CD_Tag else {
            log.error("Wrong type: \(input.value.wrappedValue)")
            return .failure(.unknown)
        }
        let context = self.container.viewContext
        let token = self.willSave(context)
        defer { self.didSave(token) }

        context.delete(tag)
        return context.datum_save()
    }
    
    // MARK: Custom Functions
    
    func add(tag: AnyElement<AnyTag>, to _sites: Set<AnyElement<AnyWebsite>>) -> Result<Void, Error> {
        let sites = _sites.compactMap { $0.value.wrappedValue as? CD_Website }
        guard
            sites.count == _sites.count,
            let tag = tag.value.wrappedValue as? CD_Tag
        else { return .failure(.unknown) }
        
        let context = self.container.viewContext
        let token = self.willSave(context)
        defer { self.didSave(token) }
        
        var changesMade = false
        for site in sites {
            guard site.cd_tags.contains(tag) == false else { continue }
            changesMade = true
            let tags = site.mutableSetValue(forKey: #keyPath(CD_Website.cd_tags))
            tags.add(tag)
        }
        
        return changesMade ? context.datum_save() : .success(())
    }
    
    func remove(tag: AnyElement<AnyTag>, from _sites: Set<AnyElement<AnyWebsite>>) -> Result<Void, Error> {
        let sites = _sites.compactMap { $0.value.wrappedValue as? CD_Website }
        guard
            sites.count == _sites.count,
            let tag = tag.value.wrappedValue as? CD_Tag
        else { return .failure(.unknown) }
        
        let context = self.container.viewContext
        let token = self.willSave(context)
        defer { self.didSave(token) }
        
        var changesMade = false
        for site in sites {
            guard site.cd_tags.contains(tag) == true else { continue }
            changesMade = true
            let tags = site.mutableSetValue(forKey: #keyPath(CD_Website.cd_tags))
            tags.remove(tag)
        }
        
        return changesMade ? context.datum_save() : .success(())
    }
    
    func tagStatus(for _sites: Set<AnyElement<AnyWebsite>>)
                  -> Result<AnyList<(AnyElement<AnyTag>, ToggleState)>, Error>

    {
        let sites = _sites.compactMap { $0.value.wrappedValue as? CD_Website }
        guard sites.count == _sites.count else { return .failure(.unknown) }
        return self.readTags().map() { tags in
            return AnyList(
                MappedList(tags) { tag in
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
    }

    private func willSave(_ context: NSManagedObjectContext) -> Any {
        return NotificationCenter.default.addObserver(forName: .NSManagedObjectContextWillSave,
                                                      object: context,
                                                      queue: nil)
        { notification in
            guard let context = notification.object as? NSManagedObjectContext else { return }
            
            context.insertedObjects
                .union(context.updatedObjects)
                .forEach { obj in
                    let obj = obj as? CD_Base
                    obj?.datum_willSave()
                    obj?.objectWillChange.send()
                }
        }
    }

    private func didSave(_ token: Any) {
        NotificationCenter.default.removeObserver(token)
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
