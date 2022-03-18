//
//  Created by Jeffrey Bergier on 2022/03/12.
//
//  MIT License
//
//  Copyright (c) 2021 Jeffrey Bergier
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//

import CoreData
import CloudKit
import Umbrella

extension CD_Controller: Controller {
    
    internal var ENVIRONMENTONLY_managedObjectContext: NSManagedObjectContext {
        self.container.viewContext
    }

    // MARK: Website CRUD

    internal func createWebsite(_ input: Website?) -> Result<Website.Ident, Error> {
        assert(Thread.isMainThread)
        let context = self.container.viewContext
        let cd_website = CD_Website(context: context)
        if let input = input {
            cd_website.cd_title       = input.title
            cd_website.cd_originalURL = input.originalURL
            cd_website.cd_resolvedURL = input.resolvedURL
            cd_website.cd_thumbnail   = input.thumbnail
            cd_website.cd_dateCreated = input.dateCreated
        }
        return context.datum_save().map {
            Website.Ident(cd_website.objectID)
        }
    }
    
    func delete(_ input: Set<Website.Ident>) -> Result<Void, Error> {
        let context = self.container.viewContext
        let coordinator = self.container.persistentStoreCoordinator
        let cd_ids = input.compactMap {
            coordinator.managedObjectID(forURIRepresentation: URL(string: $0.id)!)
        }
        let cd_tags = cd_ids.compactMap {
            context.object(with: $0) as? CD_Website
        }
        guard cd_tags.isEmpty == false else { return .success(()) }
        cd_tags.forEach {
            context.delete($0)
        }
        return context.datum_save()
    }

    // MARK: Tag CRUD
    
    internal func createTag() -> Result<Tag.Ident, Error> {
        assert(Thread.isMainThread)
        let context = self.container.viewContext
        let tag = CD_Tag(context: context)
        return context.datum_save().map { Tag.Ident(tag.objectID) }
    }
    
    internal func delete(_ input: Set<Tag.Ident>) -> Result<Void, Error> {
        assert(Thread.isMainThread)
        let context = self.container.viewContext
        let cd_tags = self.search(input, from: context)
        guard cd_tags.isEmpty == false else { return .success(()) }
        cd_tags.forEach {
            context.delete($0)
        }
        return context.datum_save()
    }
    
    // MARK: Custom Functions
    
    internal func setArchive(_ newValue: Bool, on input: Set<Website.Ident>) -> Result<Void, Error> {
        assert(Thread.isMainThread)
        let context = self.container.viewContext
        let cd_websites = self.search(input, from: context)
        guard cd_websites.isEmpty == false else { return .success(()) }
        cd_websites.forEach {
            $0.cd_isArchived = newValue
        }
        return context.datum_save()
    }
    
    /*
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
                  -> Result<AnyRandomAccessCollection<(AnyElementObserver<AnyTag>, ToggleState)>, Error>

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
            return tags.data.lazy.map { tag in
                let rawTag = tag.value.wrappedValue as! CD_Tag
                let websiteToggleStates = sites.map { website -> Bool in
                    let rawWebsite = website.value.wrappedValue as! CD_Website
                    return rawWebsite.cd_tags.contains(rawTag)
                }
                let websiteToggleState = ToggleState(websiteToggleStates)
                return (tag, websiteToggleState)
            }
            .eraseToAnyRandomAccessCollection()
        }
    }
    */
    
    // MARK: Search
    
    private func search(_ input: Set<Website.Ident>, from context: NSManagedObjectContext) -> [CD_Website] {
        let coordinator = self.container.persistentStoreCoordinator
        let cd_ids = input.compactMap {
            coordinator.managedObjectID(forURIRepresentation: URL(string: $0.id)!)
        }
        return cd_ids.compactMap {
            context.object(with: $0) as? CD_Website
        }
    }
    
    private func search(_ input: Set<Tag.Ident>, from context: NSManagedObjectContext) -> [CD_Tag] {
        let coordinator = self.container.persistentStoreCoordinator
        let cd_ids = input.compactMap {
            coordinator.managedObjectID(forURIRepresentation: URL(string: $0.id)!)
        }
        return cd_ids.compactMap {
            context.object(with: $0) as? CD_Tag
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
            let url = Bundle.module.url(forResource: "CD_MOM", withExtension: "momd"),
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
        let dataStoreEnvironment = ProcessInfo.processInfo.environment["DATA_STORE"] ?? "-1"
        guard ISTESTING || dataStoreEnvironment == "IN_MEMORY" else {
            return Datum_PersistentContainer(name: "Store", managedObjectModel: mom)
        }

        // when testing make in-memory container
        let randomName = String(Int.random(in: 100_000...1_000_000))
        let container = NSPersistentContainer(name: randomName, managedObjectModel: mom)
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
    
    internal func datum_save() -> Result<Void, Error> {
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
