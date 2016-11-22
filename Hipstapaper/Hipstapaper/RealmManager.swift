//
//  RealmManager.swift
//  Hipstapaper
//
//  Created by Jeffrey Bergier on 11/20/16.
//  Copyright © 2016 Jeffrey Bergier. All rights reserved.
//

import RealmSwift

class URLRealmItemStorer: NSObject {
    
    private(set) var realmItemIDs = Set<String>()
    private var notificationToken: NotificationToken?
    
    override init() {
        let realm = try! Realm()
        self.realmItemIDs = URLRealmItemStorer.allRealmObjectIDs(from: realm)
        super.init()
        self.notificationToken = realm.addNotificationBlock() { (_, realm) in
            let realm = try! Realm()
            self.realmItemIDs = URLRealmItemStorer.allRealmObjectIDs(from: realm)
        }
    }
    
    private class func allRealmObjects(from realm: Realm) -> Results<URLItem.RealmObject> {
        return realm.objects(URLItem.RealmObject.self)
    }
    
    private class func realmObjectIDs(from results: Results<URLItem.RealmObject>) -> Set<String> {
        return Set(results.map({ $0.realmID }))
    }
    
    private class func allRealmObjectIDs(from realm: Realm) -> Set<String> {
        let results = self.allRealmObjects(from: realm)
        let ids = self.realmObjectIDs(from: results)
        return ids
    }
}

