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
    
    func sync() {
        let syncer = CloudKitSyncer()
        syncer.allCloudKitURLItems() { result in
            switch result {
            case .error(let error):
                NSLog("Error While Syncing from CloudKit: \(error)")
            case .success(let cloudObjects):
                let realm = try! Realm()
                let realmObjects = type(of: self).allRealmObjects(from: realm)
                let comparison = CloudKitRealmComparator(realm: realmObjects, cloud: cloudObjects)
                let realmItemsToAddToCloud = comparison.addToCloud.map({ object -> URLItem.Value in
                    let item = type(of: self).realmObject(withID: object)
                    return URLItem.Value(realmID: item.realmID, cloudKitID: item.cloudKitID, urlString: item.urlString, archived: item.archived, tags: Array(item.tagList), modificationDate: item.modificationDate)
                })
                self.addNewItemsToCloudKit(items: realmItemsToAddToCloud)
            }
        }
    }
    
    private func addNewItemsToCloudKit(items: [URLItemType]) {
        let adder = CloudKitSyncer()
        adder.saveNew(items: items) { dictionary in
            for (realmID, cloudKitResult) in dictionary {
                switch cloudKitResult {
                case .success(let cloudKitID):
                    type(of: self).updateRealmObject(withID: realmID) { object in
                        object.cloudKitID = cloudKitID
                    }
                case .error(let error):
                    NSLog("Error saving realmID: \(realmID) to CloudKit: \(error)")
                }
            }
        }
    }
    
    private class func allRealmObjects(from realm: Realm) -> Results<URLItemRealmObject> {
        return realm.objects(URLItemRealmObject.self)
    }
    
    private class func realmObjectIDs(from results: Results<URLItemRealmObject>) -> Set<String> {
        return Set(results.map({ $0.realmID }))
    }
    
    private class func allRealmObjectIDs(from realm: Realm) -> Set<String> {
        let results = self.allRealmObjects(from: realm)
        let ids = self.realmObjectIDs(from: results)
        return ids
    }
    
    private class func realmAndRealmObject(with id: String) -> (object: URLItemRealmObject, realm: Realm) {
        let realm = try! Realm()
        let realmObject = realm.object(ofType: URLItemRealmObject.self, forPrimaryKey: id)!
        return (realmObject, realm)
    }
    
    class func realmObject(withID id: String) -> URLItemRealmObject {
        return self.realmAndRealmObject(with: id).object
    }
    
    class func updateRealmObject(withID id: String, updates: (URLItemRealmObject) -> Void) {
        let (object, realm) = self.realmAndRealmObject(with: id)
        realm.beginWrite()
        updates(object)
        object.modificationDate = Date()
        try! realm.commitWrite()
    }
    
    class func idForNewRealmObject() -> String {
        let realm = try! Realm()
        let realmObject = URLItemRealmObject()
        realm.beginWrite()
        realm.add(realmObject)
        try! realm.commitWrite()
        return realmObject.realmID
    }
}

