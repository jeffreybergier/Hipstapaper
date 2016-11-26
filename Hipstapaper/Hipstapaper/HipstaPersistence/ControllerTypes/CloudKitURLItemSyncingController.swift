//
//  CloudKitURLItemSyncingController.swift
//  Hipstapaper
//
//  Created by Jeffrey Bergier on 11/26/16.
//  Copyright © 2016 Jeffrey Bergier. All rights reserved.
//

import CloudKit

class CloudKitURLItemSyncingController: SyncingPersistenceType {
    
    private let privateDB = CKContainer.default().privateCloudDatabase
    private let recordType = "URLItem"
    
    var ids: Set<String> = []
    private var objectMap: [String : URLItem.CloudKitObject] = [:]
    
    var isSyncing: Bool = false
    
    func sync(completionHandler: SyncingPersistenceType.SuccessResult) {
        guard self.isSyncing == false else { completionHandler?(.success()); return; }
        self.isSyncing = true
        
        let predicate = NSPredicate(value: true)
        let initialQuery = CKQuery(recordType: self.recordType, predicate: predicate)
        
        self.privateDB.perform(initialQuery, inZoneWith: .none) { records, error in
            self.isSyncing = false
            if let error = error {
                self.ids = []
                completionHandler?(.error(error))
            } else {
                let records = records ?? []
                var ids = [String]()
                var cloudObjects: [String : URLItem.CloudKitObject] = [:]
                for record in records {
                    let id = record.recordID.recordName
                    ids.append(id)
                    cloudObjects[id] = URLItem.CloudKitObject(record: record)
                }
                self.objectMap = cloudObjects
                self.ids = Set(ids)
                completionHandler?(.success())
            }
        }
    }
    
    func createItem() -> URLItemType {
        fatalError()
    }
    
    func read(itemWithID id: String) -> URLItemType {
        let existingObject = self.objectMap[id]!
        let value = URLItem.Value(cloudKitObject: existingObject)
        return value
    }
    
    func update(item: URLItemType) {
        
    }
    
    func delete(item: URLItemType) {
        
    }
}
