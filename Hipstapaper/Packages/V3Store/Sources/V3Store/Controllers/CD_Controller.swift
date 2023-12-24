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
    
    internal var context: NSManagedObjectContext {
        self.container.viewContext
    }

    // MARK: Website CRUD

    internal func createWebsite() -> Result<Website.Selection.Element, Error> {
        return self.createWebsite(originalURL: nil)
    }
    
    internal func createWebsite(originalURL: URL?) -> Result<Website.Selection.Element, Error> {
        assert(Thread.isMainThread)
        let context = self.container.viewContext
        let cd_website = CD_Website(context: context)
        cd_website.cd_originalURL = originalURL
        return context.datum_save().map {
            Website.Identifier(cd_website.objectID)
        }
    }
    
    internal func delete(_ input: Website.Selection) -> Result<Void, Error> {
        assert(Thread.isMainThread)
        let context = self.container.viewContext
        let coordinator = self.container.persistentStoreCoordinator
        let cd_ids = input.compactMap {
            coordinator.managedObjectID(forURIRepresentation: URL(string: $0.id.rawValue)!)
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
    
    // MARK: Search
    
    internal func search(_ input: Set<Website.Identifier>, from context: NSManagedObjectContext? = nil) -> [CD_Website] {
        let context = context ?? self.container.viewContext
        let coordinator = self.container.persistentStoreCoordinator
        let cd_ids = input.compactMap {
            coordinator.managedObjectID(forURIRepresentation: URL(string: $0.id.rawValue)!)
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
    
    // MARK: Reading - Internal
    
    internal func canArchiveYes(_ selection: Website.Selection) -> Bool {
        assert(Thread.isMainThread)
        guard selection.isEmpty == false else { return false }
        let sites = self.search(selection)
        let archive = Set(sites.map { $0.cd_isArchived })
        if archive.contains(true) && archive.contains(false) {
            return true
        } else if archive.contains(true) {
            return false
        } else {
            return true
        }
    }
    
    internal func canArchiveNo(_ selection: Website.Selection) -> Bool {
        assert(Thread.isMainThread)
        guard selection.isEmpty == false else { return false }
        let sites = self.search(selection)
        let archive = Set(sites.map { $0.cd_isArchived })
        if archive.contains(true) && archive.contains(false) {
            return true
        } else if archive.contains(false) {
            return false
        } else {
            return true
        }
    }
    
    internal func openURL(_ selection: Website.Selection) -> SingleMulti<URL>? {
        assert(Thread.isMainThread)
        guard selection.isEmpty == false else { return nil }
        let urls = self.search(selection).compactMap { $0.cd_resolvedURL ?? $0.cd_originalURL }
        switch urls.count {
        case 0:
            return nil
        case 1:
            return .single(urls.first!)
        default:
            return .multi(Set(urls))
        }
    }
    
    internal func openURL(_ selection: Website.Selection) -> SingleMulti<Website.Identifier>? {
        assert(Thread.isMainThread)
        guard selection.isEmpty == false else { return nil }
        let sites = self.search(selection).filter { ($0.cd_resolvedURL ?? $0.cd_originalURL) != nil }
        switch sites.count {
        case 0:
            return nil
        case 1:
            return .single(Website.Identifier(sites.first!.objectID))
        default:
            return .multi(Set(sites.map { Website.Identifier($0.objectID) }))
        }
    }
    
    internal func tagStatus(identifier: Tag.Identifier, selection: Website.Selection) -> MultiStatus {
        assert(Thread.isMainThread)
        guard selection.isEmpty == false else { return .none }
        guard let rawTag = self.search([identifier]).first else {
            NSLog("Tag Not Found: \(identifier)")
            assertionFailure("Tag Not Found: \(identifier)")
            return .none
        }
        let sites = self.search(selection)
        let filtered = sites.filter { $0.cd_tags?.contains(rawTag) ?? false }
        if filtered.count == sites.count {
            return .all
        } else if filtered.isEmpty {
            return .none
        } else {
            return .some
        }
    }
    
    // MARK: Writing - Internal
    
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
    
    internal func write(_ cd: CD_Website, with newValue: Website) -> Result<Void, Error> {
        assert(Thread.isMainThread)
        cd.cd_title       = newValue.title
        cd.cd_isArchived  = newValue.isArchived
        cd.cd_resolvedURL = newValue.resolvedURL
        cd.cd_originalURL = newValue.originalURL
        cd.cd_thumbnail   = newValue.thumbnail
        return self.container.viewContext.datum_save()
    }
    
    internal func write(_ cd: CD_Tag, with newValue: Tag) -> Result<Void, Error> {
        assert(Thread.isMainThread)
        cd.cd_name = newValue.name
        return self.container.viewContext.datum_save()
    }
    
    internal func write(tag: TagApply, selection: Website.Selection) -> Result<Void, Error> {
        assert(Thread.isMainThread)
        let context = self.container.viewContext
        let rawTag: CD_Tag = self.search([tag.id], from: context).first!
        let sites: [CD_Website] = self.search(selection, from: context)
        switch tag.status {
        case .all:
            sites.forEach {
                $0.addToCd_tags(rawTag)
            }
        case .none:
            sites.forEach {
                $0.removeFromCd_tags(rawTag)
            }
        case .some:
            NSLog("Invalid Change")
            return .success(())
        }
        return context.datum_save()
    }
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

    internal let syncProgressMonitor: CDCloudKitSyncMonitor?
    internal let syncProgress: ContinousProgress.Environment
    internal let container: NSPersistentContainer
    
    internal class func new() -> Result<ControllerProtocol, Error> {
        do {
            let controller = try CD_Controller()
            return .success(controller)
        } catch let error {
            return .failure(error)
        }
    }
    
    fileprivate init() throws {
        // debug only sanity checks
        assert(Thread.isMainThread)

        let container = CD_Controller.container()
        let lock = DispatchSemaphore(value: 0)
        var error: Error?
        container.loadPersistentStores() { _, _error in
            error = _error
            lock.signal()
        }
        lock.wait()
        if let error { throw error }
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
        
        let monitor = CDCloudKitSyncMonitor(container)
        self.syncProgressMonitor = monitor
        self.syncProgress = monitor.progressBox
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
        NSLog(String(describing: url))
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
            return .failure(error)
        }
    }
}
