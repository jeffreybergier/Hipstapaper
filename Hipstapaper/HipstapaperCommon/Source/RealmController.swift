//
//  RealmController.swift
//  Hipstapaper
//
//  Created by Jeffrey Bergier on 12/25/16.
//  Copyright © 2016 Jeffrey Bergier. All rights reserved.
//

import RealmSwift

// MARK: Initialization

public class RealmController {
    
    private let user: SyncUser
    private let realmURL: URL
    
    fileprivate var realm: Realm {
        let config = Realm.Configuration(syncConfiguration: SyncConfiguration(user: self.user, realmURL: self.realmURL))
        let realm = try! Realm(configuration: config)
        return realm
    }
    
    public var session: SyncSession {
        let session = self.user.session(for: self.realmURL)!
        return session
    }
    
    
    private static func realmURL(for user: SyncUser) -> URL {
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
    
}

// MARK: Object Agnostic Helper Methods

extension RealmController {

    public func add(_ item: Object) {
        let realm = self.realm
        realm.beginWrite()
        realm.add(item)
        try! realm.commitWrite()
    }
    
    public func delete(_ item: Object) {
        let realm = self.realm
        realm.beginWrite()
        if let urlItem = item as? URLItem, let extras = urlItem.extras {
            realm.delete(extras) // add check to perform cascade delete
        }
        realm.delete(item)
        try! realm.commitWrite()
    }
    
    public func delete(_ items: [Object]) {
        let realm = self.realm
        realm.beginWrite()
        for item in items {
            if let urlItem = item as? URLItem, let extras = urlItem.extras {
                realm.delete(extras) // add check to perform cascade delete
            }
            realm.delete(item)
        }
        try! realm.commitWrite()
    }
    
}

// MARK: Tag Helper Methods

extension RealmController {
    
    // MARK: Create / Load / Delete Tags
    
    public func tag_loadAll() -> Results<TagItem> {
        let realm = self.realm
        let tags = realm.objects(TagItem.self).sorted(byKeyPath: #keyPath(TagItem.name))
        return tags
    }
    
    public func tag_deleteTag(with tagID: TagItem.UIIdentifier) {
        let realm = self.realm
        guard let tag = realm.object(ofType: TagItem.self, forPrimaryKey: tagID.idName) else { return }
        realm.beginWrite()
        realm.delete(tag)
        try! realm.commitWrite()
    }
    
    public func tag_uniqueTag(named proposedName: String) -> TagItem {
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
    
    // MARK: Query / Apply / Remove Tags from URLItems
    
    public func tag_applicationState(of tagItem: TagItem, on itemIDs: [URLItem.UIIdentifier]) -> CheckboxState {
        let items = self.url_existingItems(itemIDs: itemIDs)
        guard items.isEmpty == false else { return .off }
        let matches = items.flatMap({ $0.tags.index(of: tagItem) })
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
    
    public func tag_apply(tag tagItem: TagItem, to itemIDs: [URLItem.UIIdentifier]) {
        let items = self.url_existingItems(itemIDs: itemIDs)
        guard items.isEmpty == false else { return }
        let realm = self.realm
        realm.beginWrite()
        let newDate = Date()
        for urlItem in items {
            guard urlItem.tags.index(of: tagItem) == nil else { continue }
            urlItem.tags.append(tagItem)
            urlItem.modificationDate = newDate
            let tagItemName = tagItem.name
            tagItem.name = tagItemName // hack to trigger change notification on the TagItem so tables reload in the UI
        }
        try! realm.commitWrite()
    }
    
    public func tag_remove(tag tagItem: TagItem, from itemIDs: [URLItem.UIIdentifier]) {
        let items = self.url_existingItems(itemIDs: itemIDs)
        guard items.isEmpty == false else { return }
        let realm = self.realm
        realm.beginWrite()
        let newDate = Date()
        for urlItem in items {
            guard let index = urlItem.tags.index(of: tagItem) else { continue }
            urlItem.tags.remove(objectAtIndex: index)
            urlItem.modificationDate = newDate
            let tagItemName = tagItem.name
            tagItem.name = tagItemName // hack to trigger change notification on the TagItem so tables reload in the UI
        }
        try! realm.commitWrite()
    }
}

// MARK: URLItem Helper Methods

extension RealmController {

    public func url_existingItem(itemID: URLItem.UIIdentifier) -> URLItem? {
        let realm = self.realm
        let item = realm.object(ofType: URLItem.self, forPrimaryKey: itemID.uuid)
        return item
    }
    
    public func url_existingItems(itemIDs: [URLItem.UIIdentifier]) -> [URLItem] {
        let realm = self.realm
        let items = itemIDs.flatMap({ realm.object(ofType: URLItem.self, forPrimaryKey: $0.uuid) })
        return items
    }
    
    public func url_loadAll(for itemsToLoad: URLItem.ItemsToLoad, sortedBy sortOrder: URLItem.SortOrder, filteredBy filter: URLItem.ArchiveFilter, searchFilter: String? = nil) -> Results<URLItem>? {
        let results: Results<URLItem>?
        switch itemsToLoad {
        case .all:
            switch filter {
            case .all:
                if let searchFilter = searchFilter {
                    results = sortOrder.sort(results: realm.objects(URLItem.self)).filter(URLItem.searchPredicate(for: searchFilter))
                } else {
                    results = sortOrder.sort(results: realm.objects(URLItem.self))
                }
            case .unarchived:
                if let searchFilter = searchFilter {
                    results = sortOrder.sort(results: realm.objects(URLItem.self).filter("\(filter.keyPath) = NO").filter(URLItem.searchPredicate(for: searchFilter)))
                } else {
                    results = sortOrder.sort(results: realm.objects(URLItem.self).filter("\(filter.keyPath) = NO"))
                }
            }
        case .tag(let tagID):
            guard let tag = realm.object(ofType: TagItem.self, forPrimaryKey: tagID.idName) else { return nil }
            switch filter {
            case .all:
                if let searchFilter = searchFilter {
                    results = sortOrder.sort(results: tag.items).filter(URLItem.searchPredicate(for: searchFilter))
                } else {
                    results = sortOrder.sort(results: tag.items)
                }
            case .unarchived:
                if let searchFilter = searchFilter {
                    results = sortOrder.sort(results: tag.items.filter("\(filter.keyPath) = NO")).filter(URLItem.searchPredicate(for: searchFilter))
                } else {
                    results = sortOrder.sort(results: tag.items.filter("\(filter.keyPath) = NO"))
                }
            }
        }
        return results
    }
    
    public func url_setArchived(to archived: Bool, on items: [URLItem]) {
        let realm = self.realm
        realm.beginWrite()
        let newDate = Date()
        for item in items {
            item.archived = archived
            item.modificationDate = newDate
        }
        try! realm.commitWrite()
    }
    
}
