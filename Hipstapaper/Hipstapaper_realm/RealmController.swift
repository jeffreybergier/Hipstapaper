//
//  RealmController.swift
//  Hipstapaper
//
//  Created by Jeffrey Bergier on 12/25/16.
//  Copyright © 2016 Jeffrey Bergier. All rights reserved.
//

import RealmSwift

public protocol RealmControllable: class {
    var realmController: RealmController? { get set }
}

public class RealmController {
    
    private let user: SyncUser
    private let realmURL: URL
    
    private var realm: Realm {
        let config = Realm.Configuration(syncConfiguration: SyncConfiguration(user: self.user, realmURL: self.realmURL))
        let realm = try! Realm(configuration: config)
        return realm
    }
    
    public static func realmURL(for user: SyncUser) -> URL {
        var components = URLComponents(url: user.authenticationServer!, resolvingAgainstBaseURL: false)!
        components.scheme = "realm"
        components.path = "/~/Hipstapaper"
        let url = components.url!
        return url
    }
    
    public init(user: SyncUser) {
        SyncManager.shared.logLevel = .error
        self.user = user
        self.realmURL = RealmController.realmURL(for: user)
    }
    
    public init?() {
        if let user = SyncUser.current {
            SyncManager.shared.logLevel = .error
            self.user = user
            self.realmURL = RealmController.realmURL(for: user)
        } else {
            return nil
        }
    }
    
    public func logOut() {
        self.user.logOut()
    }
    
    public var tags: Results<TagItem> {
        let realm = self.realm
        let tags = realm.objects(TagItem.self).sorted(byProperty: #keyPath(TagItem.name))
        return tags
    }
    
    public func add(item: Object) {
        let realm = self.realm
        realm.beginWrite()
        realm.add(item)
        try! realm.commitWrite()
    }
    
    public func delete(item: Object) {
        let realm = self.realm
        realm.beginWrite()
        realm.delete(item)
        try! realm.commitWrite()
    }
    
    public func delete(items: [Object]) {
        let realm = self.realm
        realm.beginWrite()
        for item in items {
            realm.delete(item)
        }
        try! realm.commitWrite()
    }
    
    public func urlItem(withUUIDString uuid: String) -> URLItem? {
        let realm = self.realm
        let item = realm.object(ofType: URLItem.self, forPrimaryKey: uuid)
        return item
    }
    
    public func deleteTag(with tagID: TagItem.UIIdentifier) {
        let realm = self.realm
        guard let tag = realm.object(ofType: TagItem.self, forPrimaryKey: tagID.idName) else { return }
        realm.beginWrite()
        realm.delete(tag)
        try! realm.commitWrite()
    }
    
    public func urlItems(for itemsToLoad: URLItem.ItemsToLoad, sortedBy sortOrder: URLItem.SortOrderA, filteredBy filter: URLItem.ArchiveFilter) -> Results<URLItem>? {
        switch itemsToLoad {
        case .all:
            switch filter {
            case .all:
                let results = sortOrder.sort(results: realm.objects(URLItem.self))
                return results
            case .unarchived:
                let results = sortOrder.sort(results: realm.objects(URLItem.self).filter("\(filter.keyPath) = NO"))
                return results
            }
        case .tag(let tagID):
            guard let tag = realm.object(ofType: TagItem.self, forPrimaryKey: tagID.idName) else { return nil }
            switch filter {
            case .all:
                let results = sortOrder.sort(results: tag.items)
                return results
            case .unarchived:
                let results = sortOrder.sort(results: tag.items.filter("\(filter.keyPath) = NO"))
                return results
            }
        }
    }
    
    public func urlItems(for selection: URLItem.Selection, sortOrder: URLItem.SortOrder) -> Results<URLItem>? {
        let realm = self.realm
        switch selection {
        case .unarchived:
            let archived = URLItem.SortOrder.archived(archivedFirst: true).keyPath
            let results = sortOrder.sort(results: realm.objects(URLItem.self).filter("\(archived) = NO"))
            return results
        case .all:
            let results = sortOrder.sort(results: realm.objects(URLItem.self))
            return results
        case .tag(let tagID):
            guard let tag = realm.object(ofType: TagItem.self, forPrimaryKey: tagID.idName) else { return nil }
            let results = sortOrder.sort(results: tag.items)
            return results
        }
    }
    
    public func atLeastOneItem(in items: [URLItem], canBeArchived: Bool) -> Bool {
        let filtered = items.filter({ $0.archived != canBeArchived })
        return !filtered.isEmpty
    }
    
    public func newOrExistingTag(proposedName: String) -> TagItem {
        let normalizedName = TagItem.normalize(proposedName)
        let realm = self.realm
        let existingItem = realm.object(ofType: TagItem.self, forPrimaryKey: normalizedName)
        if let existingItem = existingItem {
            return existingItem
        } else {
            realm.beginWrite()
            let newItem = TagItem()
            newItem.normalizedNameHash = normalizedName
            newItem.name = normalizedName == "untitledtag" ? "Untitled Tag" : proposedName
            realm.add(newItem)
            try! realm.commitWrite()
            return newItem
        }
    }
    
    public func state(of tagItem: TagItem, with items: [URLItem]) -> CheckboxState {
        guard items.isEmpty == false else { return .off }
        let matches = items.map({ $0.tags.index(of: tagItem) }).flatMap({ $0 })
        if matches.count == items.count {
            // this means all items have this tag
            return .on
        } else {
            if matches.isEmpty {
                // this means that none of the items have this tag
                return .off
            } else {
                // this means we're mixed. Some items have the tag and some don't
                return .mixed
            }
        }
    }
    
    public func apply(tag tagItem: TagItem, to items: [URLItem]) {
        let realm = self.realm
        realm.beginWrite()
        for urlItem in items {
            guard urlItem.tags.index(of: tagItem) == nil else { continue }
            urlItem.tags.append(tagItem)
            let tagItemName = tagItem.name
            tagItem.name = tagItemName // hack to trigger change notification on the TagItem so tables reload in the UI
        }
        try! realm.commitWrite()
    }
    
    public func remove(tag tagItem: TagItem, from items: [URLItem]) {
        let realm = self.realm
        realm.beginWrite()
        for urlItem in items {
            guard let index = urlItem.tags.index(of: tagItem) else { continue }
            urlItem.tags.remove(objectAtIndex: index)
            let tagItemName = tagItem.name
            tagItem.name = tagItemName // hack to trigger change notification on the TagItem so tables reload in the UI
        }
        try! realm.commitWrite()
    }
    
//    public func delete(items: [TagItem]) {
//        let realm = self.realm
//        realm.beginWrite()
//        for item in items {
//            realm.delete(item)
//        }
//        try! realm.commitWrite()
//    }
    
    public func updateArchived(to archived: Bool, on items: [URLItem]) {
        let realm = self.realm
        realm.beginWrite()
        for item in items {
            item.archived = archived
        }
        try! realm.commitWrite()
    }
    
}
