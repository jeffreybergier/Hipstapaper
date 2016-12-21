//
//  Realm.swift
//  Hipstapaper
//
//  Created by Jeffrey Bergier on 12/16/16.
//  Copyright © 2016 Jeffrey Bergier. All rights reserved.
//

import RealmSwift
import Foundation

final public class TagItem: Object {
    
    class func normalize(nameString: String) -> String? {
        let lowerCase = nameString.lowercased()
        let characterSet = CharacterSet.alphanumerics.inverted
        let trimmed = lowerCase.components(separatedBy: characterSet).joined(separator: "")
        if trimmed == "" { return .none } else { return trimmed }
    }
    
    static let normalizedName: NSObject? = nil // for keyPath selection
    private dynamic var normalizedName = "untitled"
    
    var name: String {
        get {
            return self.normalizedName
        }
        set {
            let adjusted = type(of: self).normalize(nameString: newValue) ?? "untitled"
            self.normalizedName = adjusted
        }
    }
    
    let items = LinkingObjects(fromType: URLItem.self, property: "tags")
    
    override public class func ignoredProperties() -> [String] {
        return ["name"]
    }
    
}

struct RealmConfig {
    
    static var tags: Results<TagItem> {
        let realm = try! Realm()
        let tags = realm.objects(TagItem.self).sorted(byProperty: #keyPath(TagItem.normalizedName))
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
            fatalError("finish testing sortorder")
            let testSortorder = URLItem.SortOrder.pageTitle(aFirst: true)
            results = testSortorder.sort(results: realm.objects(URLItem.self))
        case .tag(let tagItem):
            results = sortOrder.sort(results: tagItem.items)
        }
        return results
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
                let config = Realm.Configuration(syncConfiguration: SyncConfiguration(user: user, realmURL: URL(string: realmDataServer.absoluteString)!))
                Realm.Configuration.defaultConfiguration = config
                completionHandler()
            }
        }
    }
}


