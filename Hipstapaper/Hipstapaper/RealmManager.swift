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
                
                let realmItemsToAddToCloud = comparison.addToCloud?.map() { realmID -> URLItem.Value in
                    let item = type(of: self).realmObject(withID: realmID)
                    return URLItem.Value(realmID: item.realmID, cloudKitID: item.cloudKitID, urlString: item.urlString, archived: item.archived, tags: Array(item.tagList), modificationDate: item.modificationDate)
                }
                if let realmItemsToAddToCloud = realmItemsToAddToCloud {
                    NSLog("Syncing: New Realm Items to Create in CloudKit: \(realmItemsToAddToCloud.count)")
                    self.addNewItemsToCloudKit(items: realmItemsToAddToCloud)
                }
                
                let realmItemsToUpdateInCloud = comparison.updateInCloud?.map() { (realmID, cloudKitObject) -> (URLItem.Value, URLItem.CloudKitObject) in
                    let item = type(of: self).realmObject(withID: realmID)
                    let value = URLItem.Value(realmID: item.realmID, cloudKitID: item.cloudKitID, urlString: item.urlString, archived: item.archived, tags: Array(item.tagList), modificationDate: item.modificationDate)
                    return (value, cloudKitObject)
                }
                
                if let realmItemsToUpdateInCloud = realmItemsToUpdateInCloud {
                    NSLog("Syncing: Items Changed Locally to Upload: \(realmItemsToUpdateInCloud.count)")
                    self.updateItemsInCloudKit(items: realmItemsToUpdateInCloud)
                }
            }
        }
    }
    
    private func addNewItemsToCloudKit(items: [URLItemType]) {
        let adder = CloudKitSyncer()
        let newRecords = items.map({ ($0.realmID, URLItem.CloudKitObject(realmValue: $0).record) })
        adder.save(records: newRecords) { dictionary in
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
    
    private func updateItemsInCloudKit(items: [(URLItem.Value, URLItem.CloudKitObject)]) {
        for (realm, cloud) in items {
            cloud.archived = realm.archived
            cloud.urlString = realm.urlString
            cloud.tags = Set(realm.tags.map({ $0.name }))
        }
        let records = items.map({ ($0.0.realmID, $0.1.record) })
        let updater = CloudKitSyncer()
        updater.save(records: records) { dictionary in
            for (realmID, cloudKitResult) in dictionary {
                switch cloudKitResult {
                case .success:
                    break
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

