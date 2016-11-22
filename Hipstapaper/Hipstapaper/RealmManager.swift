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
    
    private class func realmAndRealmObject(with id: String) -> (object: URLItem.RealmObject, realm: Realm) {
        let realm = try! Realm()
        let realmObject = realm.object(ofType: URLItem.RealmObject.self, forPrimaryKey: id)!
        return (realmObject, realm)
    }
    
    class func realmObject(with id: String) -> URLItem.RealmObject {
        return self.realmAndRealmObject(with: id).object
    }
    
    class func updateRealmObject(with id: String, updates: (URLItem.RealmObject) -> Void) {
        let (object, realm) = self.realmAndRealmObject(with: id)
        realm.beginWrite()
        updates(object)
        object.modificationDate = Date()
        try! realm.commitWrite()
    }
    
    class func idForNewRealmObject() -> String {
        let realm = try! Realm()
        let realmObject = URLItem.RealmObject()
        realm.beginWrite()
        realm.add(realmObject)
        try! realm.commitWrite()
        return realmObject.realmID
    }
}

