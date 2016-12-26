//
//  RealmController.swift
//  Hipstapaper
//
//  Created by Jeffrey Bergier on 12/25/16.
//  Copyright © 2016 Jeffrey Bergier. All rights reserved.
//

import RealmSwift

class RealmController {
    
    private let user: SyncUser
    private let realmURL: URL
    
    private var realm: Realm {
        let config = Realm.Configuration(syncConfiguration: SyncConfiguration(user: self.user, realmURL: self.realmURL))
        let realm = try! Realm(configuration: config)
        return realm
    }
    
    static func realmURL(for user: SyncUser) -> URL {
        var components = URLComponents(url: user.authenticationServer!, resolvingAgainstBaseURL: false)!
        components.scheme = "realm"
        components.path = "/~/Hipstapaper"
        let url = components.url!
        return url
    }
    
    init(user: SyncUser) {
        self.user = user
        self.realmURL = RealmController.realmURL(for: user)
    }
    
    init?() {
        if let user = SyncUser.current {
            self.user = user
            self.realmURL = RealmController.realmURL(for: user)
        } else {
            return nil
        }
    }
    
    func logOut() {
        self.user.logOut()
    }
    
    var tags: Results<TagItem> {
        let realm = self.realm
        let tags = realm.objects(TagItem.self).sorted(byProperty: #keyPath(TagItem.name))
        return tags
    }
    
    func add(item: Object) {
        let realm = self.realm
        realm.beginWrite()
        realm.add(item)
        try! realm.commitWrite()
    }
    
    func delete(item: Object) {
        let realm = self.realm
        realm.beginWrite()
        realm.delete(item)
        try! realm.commitWrite()
    }
    
    func urlItems(for selection: URLItem.Selection, sortOrder: URLItem.SortOrder) -> Results<URLItem> {
        let realm = self.realm
        let results: Results<URLItem>
        switch selection {
        case .unarchived:
            let archived = URLItem.SortOrder.archived(archivedFirst: true).keyPath
            results = sortOrder.sort(results: realm.objects(URLItem.self).filter("\(archived) = NO"))
        case .all:
            results = sortOrder.sort(results: realm.objects(URLItem.self))
        case .tag(let tagItem):
            results = sortOrder.sort(results: tagItem.items)
        }
        return results
    }
    
    func atLeastOneItem(in items: [URLItem], canBeArchived: Bool) -> Bool {
        let filtered = items.filter({ $0.archived != canBeArchived })
        return !filtered.isEmpty
    }
    
    func newOrExistingTag(proposedName: String) -> TagItem {
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
    
    func state(of tagItem: TagItem, with items: [URLItem]) -> CheckboxState {
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
    
    func apply(tag tagItem: TagItem, to items: [URLItem]) {
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
    
    func remove(tag tagItem: TagItem, from items: [URLItem]) {
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
    
    func delete(items: [TagItem]) {
        let realm = self.realm
        realm.beginWrite()
        for item in items {
            realm.delete(item)
        }
        try! realm.commitWrite()
    }
    
    func updateArchived(to archived: Bool, on items: [URLItem]) {
        let realm = self.realm
        realm.beginWrite()
        for item in items {
            item.archived = archived
        }
        try! realm.commitWrite()
    }
    
}
