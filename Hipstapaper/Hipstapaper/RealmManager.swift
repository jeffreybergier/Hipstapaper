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
        let results = realm.objects(URLItem.RealmObject.self)
        let ids = Set(results.map({ $0.id }))
        self.realmItemIDs = ids
        super.init()
        self.notificationToken = realm.addNotificationBlock() { (_, realm) in
            let results = realm.objects(URLItem.RealmObject.self)
            let ids = Set(results.map({ $0.id }))
            self.realmItemIDs = ids
        }
    }
}

