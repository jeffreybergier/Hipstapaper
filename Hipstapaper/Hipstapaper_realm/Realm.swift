//
//  Realm.swift
//  Hipstapaper
//
//  Created by Jeffrey Bergier on 12/16/16.
//  Copyright © 2016 Jeffrey Bergier. All rights reserved.
//

import RealmSwift
import Foundation

class URLItem: Object {
    
    dynamic var uuid = UUID().uuidString
    dynamic var urlString = "http://www.url.com"
    dynamic var archived = false
    dynamic var modificationDate = Date()
    dynamic var creationDate = Date()
    
    var tags = List<TagItem>()
    
    override static func primaryKey() -> String {
        return "uuid"
    }
    
}

class TagItem: Object {
    
    dynamic var name = "Untitled"
    
    let items = LinkingObjects(fromType: URLItem.self, property: "tags")
    
    override static func primaryKey() -> String {
        return "name"
    }
}

struct RealmConfig {
    #if os(OSX)
    private static let appGroupIdentifier = "V6ESYGU6CV.hipstapaper.appgroup"
    #else
    private static let appGroupIdentifier = "group.com.saturdayapps.Hipstapaper"
    #endif
    
    // Void Singleton to configure the default realm for the app once
    // this enables realm to use the app group for storage
    // also opens up the possibility to setting an encryption key
    private static let configure: Void = {
        let directory = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: RealmConfig.appGroupIdentifier)!
        let realmPath = directory.appendingPathComponent("db.realm")
        var config = Realm.Configuration.defaultConfiguration
        config.deleteRealmIfMigrationNeeded = true // this can be true because the cloud is the source of truth
        config.fileURL = realmPath
        Realm.Configuration.defaultConfiguration = config
    }()
}


