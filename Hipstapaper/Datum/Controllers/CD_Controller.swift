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
import CloudKit
import Umbrella

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
        return context.datum_save().map {
            AnyElementObserver(ManagedObjectElementObserver(website, { AnyWebsite($0) }))
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
                    FetchedResultsControllerListObserver(
                        FetchedResultsControllerList(controller) {
                            AnyElementObserver(ManagedObjectElementObserver($0, { AnyWebsite($0) }))
                        }
                    )
                )
            )
        } catch {
            return .failure(.read(error as NSError))
        }
    }
    
    func update(_ inputs: Set<AnyElementObserver<AnyWebsite>>, _ raw: AnyWebsite.Raw) -> Result<Void, Error> {
        let context = self.container.viewContext
        let check = inputs.firstIndex { !context.validate($0.value.wrappedValue,
                                                          as: CD_Website.classForCoder()) }
        guard check == nil else {
            let message = "Wrong Input Type"
            log.emergency(message)
            fatalError(message)
        }
        
        var inputs = inputs
        var changesMade = false
        
        while !inputs.isEmpty {
            let input = inputs.popFirst()!
            let website = input.value.wrappedValue as! CD_Website
            
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
    
    func delete(_ inputs: Set<AnyElementObserver<AnyWebsite>>) -> Result<Void, Error> {
        let context = self.container.viewContext
        let check = inputs.firstIndex { !context.validate($0.value.wrappedValue,
                                                          as: CD_Website.classForCoder()) }
        guard check == nil else {
            let message = "Wrong Input Type"
            log.emergency(message)
            fatalError(message)
        }
        
        var inputs = inputs
        var changesMade = false
        
        while !inputs.isEmpty {
            let input = inputs.popFirst()!
            let website = input.value.wrappedValue as! CD_Website
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
        return context.datum_save().map {
            AnyElementObserver(ManagedObjectElementObserver(tag, { AnyTag($0) }))
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
                    FetchedResultsControllerListObserver(
                        FetchedResultsControllerList(controller) {
                            AnyElementObserver(ManagedObjectElementObserver($0, { AnyTag($0) }))
                        }
                    )
                )
            )
        } catch {
            return .failure(.read(error as NSError))
        }
    }

    func update(_ input: AnyElementObserver<AnyTag>, name: Optional<String?>) -> Result<Void, Error> {
        let context = self.container.viewContext
        guard context.validate(input.value.wrappedValue, as: CD_Tag.classForCoder()) else {
            let message = "Wrong Input Type"
            log.emergency(message)
            fatalError(message)
        }

        let tag = input.value.wrappedValue as! CD_Tag
        var changesMade = false
        if let newName = name {
            changesMade = true
            tag.cd_name = newName
        }

        return changesMade ? context.datum_save() : .success(())
    }

    func delete(_ input: AnyElementObserver<AnyTag>) -> Result<Void, Error> {
        let context = self.container.viewContext
        guard context.validate(input.value.wrappedValue, as: CD_Tag.classForCoder()) else {
            let message = "Wrong Input Type"
            log.emergency(message)
            fatalError(message)
        }
        let tag = input.value.wrappedValue as! CD_Tag
        context.delete(tag)
        return context.datum_save()
    }
    
    // MARK: Custom Functions
    
    func add(tag: AnyElementObserver<AnyTag>, to sites: Set<AnyElementObserver<AnyWebsite>>) -> Result<Void, Error> {
        let context = self.container.viewContext
        let check = sites.firstIndex { !context.validate($0.value.wrappedValue,
                                                         as: CD_Website.classForCoder()) }
        guard check == nil, let tag = tag.value.wrappedValue as? CD_Tag else {
            let message = "Wrong Input Type"
            log.emergency(message)
            fatalError(message)
        }
        
        var changesMade = false
        for site in sites {
            let site = site.value.wrappedValue as! CD_Website
            guard site.cd_tags.contains(tag) == false else { continue }
            changesMade = true
            let tags = site.mutableSetValue(forKey: #keyPath(CD_Website.cd_tags))
            tags.add(tag)
        }
        
        return changesMade ? context.datum_save() : .success(())
    }
    
    func remove(tag: AnyElementObserver<AnyTag>, from sites: Set<AnyElementObserver<AnyWebsite>>) -> Result<Void, Error> {
        let context = self.container.viewContext
        let check = sites.firstIndex { !context.validate($0.value.wrappedValue,
                                                         as: CD_Website.classForCoder()) }
        guard check == nil, let tag = tag.value.wrappedValue as? CD_Tag else {
            let message = "Wrong Input Type"
            log.emergency(message)
            fatalError(message)
        }
        
        var changesMade = false
        for site in sites {
            let site = site.value.wrappedValue as! CD_Website
            guard site.cd_tags.contains(tag) == true else { continue }
            changesMade = true
            let tags = site.mutableSetValue(forKey: #keyPath(CD_Website.cd_tags))
            tags.remove(tag)
        }
        
        return changesMade ? context.datum_save() : .success(())
    }
    
    func tagStatus(for sites: Set<AnyElementObserver<AnyWebsite>>)
                  -> Result<AnyList<(AnyElementObserver<AnyTag>, ToggleState)>, Error>

    {
        let context = self.container.viewContext
        let check = sites.firstIndex { !context.validate($0.value.wrappedValue,
                                                         as: CD_Website.classForCoder()) }
        guard check == nil else {
            let message = "Wrong Input Type"
            log.emergency(message)
            fatalError(message)
        }
        return self.readTags().map() { tags in
            return AnyList(
                MappedList(tags.data) { tag in
                    let tag = tag.value.wrappedValue as! CD_Tag
                    return ToggleState(sites.map {
                        ($0.value.wrappedValue as! CD_Website).cd_tags.contains(tag)
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

    internal let syncProgress: AnyContinousProgress
    internal let container: NSPersistentContainer
    
    internal class func new() -> Result<Controller, Error> {
        do {
            let controller = try CD_Controller()
            return .success(controller)
        } catch let error as Error {
            return .failure(error)
        } catch {
            log.emergency(error)
            fatalError("Unexpected error ocurred: \(error)")
        }
    }
    
    fileprivate init() throws {
        // debug only sanity checks
        assert(Thread.isMainThread)

        let container = CD_Controller.container()
        let lock = DispatchSemaphore(value: 0)
        var error: Swift.Error?
        container.loadPersistentStores() { _, _error in
            error = _error
            lock.signal()
        }
        lock.wait()
        if let error = error { throw Error.initialize(error as NSError) }
        container.viewContext.automaticallyMergesChangesFromParent = true
        self.container = container
        
        #if DEBUG
        // initialize the CloudKit schema
        // only do this once per change to CD MOM
        let configureCKSchema = false
        if configureCKSchema {
            let container = container as! NSPersistentCloudKitContainer
            try! container.initializeCloudKitSchema(options: [.printSchema])
            fatalError("Cannot continue while using: initializeCloudKitSchema")
        }
        #endif
        
        self.syncProgress = AnyContinousProgress(CloudKitContainerContinuousProgress(container))
    }
    
    #if DEBUG
    deinit {
        log.verbose()
    }
    #endif
}

extension CD_Controller {

    // If the MOM is loaded more than once, it prints warnings to the console
    private static let mom: NSManagedObjectModel = {
        guard
            let url = Bundle(for: CD_Controller.self).url(forResource: "CD_MOM", withExtension: "momd"),
            let mom = NSManagedObjectModel(contentsOf: url)
        else {
            let message = "Couldn't find MOM"
            log.emergency(message)
            fatalError(message)
        }
        return mom
    }()

    private class func container() -> NSPersistentContainer {
        // debug only sanity checks
        assert(Thread.isMainThread)

        let mom = CD_Controller.mom
        // when not testing, return normal persistent container
        guard ISTESTING else {
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
    
    override init(name: String, managedObjectModel model: NSManagedObjectModel) {
        super.init(name: name, managedObjectModel: model)
        let description = self.persistentStoreDescriptions.first!
        let id = "iCloud.com.saturdayapps.Hipstapaper"
        let options = NSPersistentCloudKitContainerOptions(containerIdentifier: id)
        description.cloudKitContainerOptions = options
    }
}

extension NSManagedObjectContext {
    
    /// Returns true if the object can be modified by this context.
    fileprivate func validate(_ input: Any, as expected: AnyClass) -> Bool {
        // debug only sanity checks
        assert(Thread.isMainThread)
        
        let _input = input as AnyObject
        guard _input.isKind(of: expected) else { return false }
        guard let __input = _input as? NSManagedObject else { return false }
        return self === __input.managedObjectContext
    }
    
    fileprivate func datum_save() -> Result<Void, Error> {
        do {
            try self.save()
            return .success(())
        } catch {
            log.error(error)
            self.rollback()
            return .failure(.write(error as NSError))
        }
    }
}
