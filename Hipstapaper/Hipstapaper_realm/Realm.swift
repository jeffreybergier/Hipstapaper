//
//  Realm.swift
//  Hipstapaper
//
//  Created by Jeffrey Bergier on 12/16/16.
//  Copyright © 2016 Jeffrey Bergier. All rights reserved.
//

import RealmSwift
import Foundation

struct RealmConfig {
    
    static var tags: Results<TagItem> {
        let realm = try! Realm()
        let tags = realm.objects(TagItem.self).sorted(byProperty: #keyPath(TagItem.name))
        return tags
    }
    
    static func urlItems(for selection: URLItem.Selection, sortOrder: URLItem.SortOrder) -> Results<URLItem> {
        let realm = try! Realm()
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
    
    static func atLeastOneItem(in items: [URLItem], canBeArchived: Bool) -> Bool {
        let filtered = items.filter({ $0.archived != canBeArchived })
        return !filtered.isEmpty
    }
    
    static func newOrExistingTag(proposedName: String) -> TagItem {
        let normalizedName = TagItem.normalize(nameString: proposedName)
        let realm = try! Realm()
        let existingItem = realm.objects(TagItem.self).filter({ TagItem.normalize(nameString: $0.name) == normalizedName }).first
        if let existingItem = existingItem {
            return existingItem
        } else {
            realm.beginWrite()
            let newItem = TagItem()
            newItem.name = proposedName
            realm.add(newItem)
            try! realm.commitWrite()
            return newItem
        }
    }
    
    static func state(of tagItem: TagItem, with items: [URLItem]) -> CheckboxState {
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
    
    static func apply(tag tagItem: TagItem, to items: [URLItem]) {
        let realm = try! Realm()
        realm.beginWrite()
        for urlItem in items {
            guard urlItem.tags.index(of: tagItem) == nil else { continue }
            urlItem.tags.append(tagItem)
            let tagItemName = tagItem.name
            tagItem.name = tagItemName // hack to trigger change notification on the TagItem so tables reload in the UI
        }
        try! realm.commitWrite()
    }
    
    static func remove(tag tagItem: TagItem, from items: [URLItem]) {
        let realm = try! Realm()
        realm.beginWrite()
        for urlItem in items {
            guard let index = urlItem.tags.index(of: tagItem) else { continue }
            urlItem.tags.remove(objectAtIndex: index)
            let tagItemName = tagItem.name
            tagItem.name = tagItemName // hack to trigger change notification on the TagItem so tables reload in the UI
        }
        try! realm.commitWrite()
    }
    
    static func delete(items: [TagItem]) {
        let realm = try! Realm()
        realm.beginWrite()
        for item in items {
            realm.delete(item)
        }
        try! realm.commitWrite()
    }
    
    static func updateArchived(to archived: Bool, on items: [URLItem]) {
        let realm = try! Realm()
        realm.beginWrite()
        for item in items {
            item.archived = archived
        }
        try! realm.commitWrite()
    }
    
    
//    #if os(OSX)
//    private static let appGroupIdentifier = "V6ESYGU6CV.hipstapaper.appgroup"
//    #else
//    private static let appGroupIdentifier = "group.com.saturdayapps.Hipstapaper"
//    #endif
//    let directory = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: RealmConfig.appGroupIdentifier)!
//    let realmPath = directory.appendingPathComponent("db.realm")
//    var config = Realm.Configuration.defaultConfiguration
//    config.fileURL = realmPath
    
    static func configure(completionHandler: @escaping (() -> Void)) {
        SyncUser.logIn(with: SyncCredentials.usernamePassword(username: realmUsername, password: realmPassword, register: false), server: realmAuthServer) { user, error in
            DispatchQueue.main.async {
                guard let user = user else { fatalError("\(error!)") }
                var config = Realm.Configuration(syncConfiguration: SyncConfiguration(user: user, realmURL: URL(string: realmDataServer.absoluteString)!))
                config.deleteRealmIfMigrationNeeded = true
                Realm.Configuration.defaultConfiguration = config
                completionHandler()
            }
        }
    }
}


