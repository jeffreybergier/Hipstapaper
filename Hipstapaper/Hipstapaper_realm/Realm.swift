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
    static func configure(completionHandler: @escaping (() -> Void)) {
        SyncUser.logIn(with: SyncCredentials.usernamePassword(username: realmUsername, password: realmPassword, register: false), server: realmAuthServer) { user, error in
            DispatchQueue.main.async {
                guard let user = user else { fatalError("\(error!)") }
                let directory = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: RealmConfig.appGroupIdentifier)!
                let realmPath = directory.appendingPathComponent("db.realm")
                var config = Realm.Configuration(
                    syncConfiguration: SyncConfiguration(user: user, realmURL: URL(string: realmDataServer.absoluteString)!)
                )
                //var config = Realm.Configuration.
                //config.fileURL = realmPath
                config.objectTypes = [URLItem.self, TagItem.self]
                Realm.Configuration.defaultConfiguration = config
                completionHandler()
            }
        }
    }
}


