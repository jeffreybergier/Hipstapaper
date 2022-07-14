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
import V3Model

extension CD_Controller: ControllerProtocol {
    
    internal var ENVIRONMENTONLY_managedObjectContext: NSManagedObjectContext {
        self.container.viewContext
    }

    // MARK: Website CRUD

    internal func createWebsite() -> Result<Website.Identifier, Error> {
        assert(Thread.isMainThread)
        let context = self.container.viewContext
        let cd_website = CD_Website(context: context)
        return context.datum_save().map {
            Website.Identifier(cd_website.objectID)
        }
    }
    
    func delete(_ input: Website.Selection) -> Result<Void, Error> {
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
    
    internal func createTag() -> Result<Tag.Selection.Element, Error> {
        assert(Thread.isMainThread)
        let context = self.container.viewContext
        let tag = CD_Tag(context: context)
        return context.datum_save().map { Tag.Identifier(tag.objectID) }
    }
    
    internal func delete(_ input: Tag.Selection) -> Result<Void, Error> {
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
    
    internal func setArchive(_ newValue: Bool, on input: Website.Selection) -> Result<Void, Error> {
        assert(Thread.isMainThread)
        let context = self.container.viewContext
        let cd_websites = self.search(input, from: context)
        guard cd_websites.isEmpty == false else { return .success(()) }
        cd_websites.forEach {
            $0.cd_isArchived = newValue
        }
        return context.datum_save()
    }
    
    internal func addTag(_ cd_tag: CD_Tag, to input: Website.Selection) -> Result<Void, Error> {
        assert(Thread.isMainThread)
        let context = self.container.viewContext
        let websites = self.search(input, from: context)
        var changesMade = false
        for site in websites {
            guard site.cd_tags.contains(cd_tag) == false else { continue }
            changesMade = true
            let tags = site.mutableSetValue(forKey: #keyPath(CD_Website.cd_tags))
            tags.add(cd_tag)
        }
        return changesMade ? context.datum_save() : .success(())
    }
    
    internal func removeTag(_ cd_tag: CD_Tag, to input: Website.Selection) -> Result<Void, Error> {
        assert(Thread.isMainThread)
        let context = self.container.viewContext
        let websites = self.search(input, from: context)
        var changesMade = false
        for site in websites {
            guard site.cd_tags.contains(cd_tag) == true else { continue }
            changesMade = true
            let tags = site.mutableSetValue(forKey: #keyPath(CD_Website.cd_tags))
            tags.remove(cd_tag)
        }
        return changesMade ? context.datum_save() : .success(())
    }
    
    // MARK: Search
    
    internal func search(_ input: Set<Website.Identifier>, from context: NSManagedObjectContext? = nil) -> [CD_Website] {
        let context = context ?? self.container.viewContext
        let coordinator = self.container.persistentStoreCoordinator
        let cd_ids = input.compactMap {
            coordinator.managedObjectID(forURIRepresentation: URL(string: $0.id)!)
        }
        return cd_ids.compactMap {
            context.object(with: $0) as? CD_Website
        }
    }
    
    internal func search(_ input: Set<Tag.Identifier>, from context: NSManagedObjectContext? = nil) -> [CD_Tag] {
        let context = context ?? self.container.viewContext
        let coordinator = self.container.persistentStoreCoordinator
        let cd_ids = input.compactMap {
            coordinator.managedObjectID(forURIRepresentation: URL(string: $0.id)!)
        }
        return cd_ids.compactMap {
            context.object(with: $0) as? CD_Tag
        }
    }
    
    // MARK: Internal for Property Wrappers
    
    internal func writeOpt(_ cd: CD_Website?, with newValue: Website?) -> Result<Void, Error> {
        return self.write(cd!, with: newValue!)
    }
    
    internal func write(_ cd: CD_Website, with newValue: Website) -> Result<Void, Error> {
        cd.cd_title       = newValue.title
        cd.cd_isArchived  = newValue.isArchived
        cd.cd_resolvedURL = newValue.resolvedURL
        cd.cd_originalURL = newValue.originalURL
        cd.cd_thumbnail   = newValue.thumbnail
        return self.container.viewContext.datum_save()
    }
    
    internal func writeOpt(_ cd: CD_Tag?, with newValue: Tag?) -> Result<Void, Error> {
        return self.write(cd!, with: newValue!)
    }
    
    internal func write(_ cd: CD_Tag, with newValue: Tag) -> Result<Void, Error> {
        cd.cd_name = newValue.name
        return self.container.viewContext.datum_save()
    }
    
    /*
    internal func write(selection: Website.Selection, with newValue: TagApply) -> Result<Void, Error> {
        let result1 = self.write(cd, with: newValue.tag)
        switch newValue.status {
        case .all:
            return result1.reduce {
                self.addTag(cd, to: newValue.selection)
            }
        case .none:
            return result1.reduce {
                return self.removeTag(cd, to: newValue.selection)
            }
        case .some:
            NSLog("Invalid Change")
            return result1
        }
    }
     */
}

internal class CD_Controller {
    
    internal static let appGroupURL: URL = {
        let fm = FileManager.default
        #if os(macOS)
        let id = "V6ESYGU6CV.com.saturdayapps.Hipstapaper"
        #else
        let id = "group.com.saturdayapps.Hipstapaper"
        #endif
        return fm.containerURL(forSecurityApplicationGroupIdentifier: id)!
    }()

    static internal let storeDirectoryURL: URL = {
        return appGroupURL
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
    
    internal class func new() -> Result<ControllerProtocol, Error> {
        do {
            let controller = try CD_Controller()
            return .success(controller)
        } catch let error as Error {
            return .failure(error)
        } catch {
            NSLog("\(error)")
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
        if let error = error {
            NSLog(String(describing: error))
            throw Error.initialize
        }
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
        NSLog("CD_Controller: DEINIT")
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
            NSLog("Couldn't find MOM")
            fatalError()
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
        NSLog("\(url)")
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
            NSLog(String(describing: error))
            self.rollback()
            return .failure(.write)
        }
    }
}