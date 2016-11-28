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
    
    private(set) var ids: Set<String> = []
    private var objectMap: [String : URLItem.CloudKitObject] = [:]
        
    func sync(quickSyncResult: @escaping SyncingPersistenceType.SuccessResult,
              fullSyncResult: @escaping SyncingPersistenceType.SuccessResult)
    {
        DispatchQueue.global(qos: .userInteractive).async {
            let predicate = NSPredicate(value: true)
            let initialQuery = CKQuery(recordType: self.recordType, predicate: predicate)
            self.privateDB.perform(initialQuery, inZoneWith: .none) { records, error in
                if let records = records {
                    var ids = [String]()
                    var cloudObjects: [String : URLItem.CloudKitObject] = [:]
                    for record in records {
                        let object = URLItem.CloudKitObject(record: record)
                        let id = object.cloudKitID
                        ids.append(id)
                        cloudObjects[id] = object
                    }
                    self.objectMap = cloudObjects
                    self.ids = Set(ids)
                    quickSyncResult(.success())
                    fullSyncResult(.success())
                } else {
                    self.ids = []
                    self.objectMap = [:]
                    quickSyncResult(.error(error!))
                    fullSyncResult(.error(error!))
                }
            }
        }
    }
    
    func createItem(withID inputID: String?, result: @escaping SyncingPersistenceType.URLItemResult) {
        DispatchQueue.global(qos: .userInteractive).async {
            let emptyObject = URLItem.CloudKitObject()
            self.privateDB.save(emptyObject.record) { (record, error) in
                if let record = record {
                    let newObject = URLItem.CloudKitObject(record: record)
                    if let inputID = inputID {
                        newObject.cloudKitID = inputID
                    }
                    let id = newObject.cloudKitID
                    self.objectMap[id] = newObject
                    self.ids.insert(id)
                    let newValue = URLItem.Value(cloudKitObject: newObject)
                    result(.success(newValue))
                } else {
                    result(.error(error!))
                }
            }
        }
    }
    
    func readItem(withID id: String, result: @escaping SyncingPersistenceType.URLItemResult) {
        DispatchQueue.global(qos: .userInteractive).async {
            if let existingObject = self.objectMap[id] {
                let value = URLItem.Value(cloudKitObject: existingObject)
                result(.success(value))
            } else {
                result(.error(NSError()))
            }
        }
    }
    
    func update(item: URLItemType, result: @escaping SyncingPersistenceType.URLItemResult) {
        DispatchQueue.global(qos: .userInteractive).async {
            guard let existingObject = self.objectMap[item.cloudKitID]
                else { result(.error(NSError())); return; }
            existingObject.urlString = item.urlString
            existingObject.archived = item.archived
            existingObject.tags = item.tags
            existingObject.modificationDate = item.modificationDate
            self.privateDB.save(existingObject.record) { (record, error) in
                if let record = record {
                    let updatedObject = URLItem.CloudKitObject(record: record)
                    let id = updatedObject.cloudKitID
                    self.objectMap[id] = updatedObject
                    self.ids.insert(id)
                    let updatedValue = URLItem.Value(cloudKitObject: updatedObject)
                    result(.success(updatedValue))
                } else {
                    result(.error(error!))
                }
            }
        }
    }
    
    func delete(item: URLItemType, result: @escaping SyncingPersistenceType.SuccessResult) {
        DispatchQueue.global(qos: .userInteractive).async {
            let id = item.cloudKitID
            guard let existingObject = self.objectMap[id]
                else { result(.error(NSError())); return; }
            let recordID = existingObject.record.recordID
            self.ids.remove(id)
            self.objectMap[id] = .none
            self.privateDB.delete(withRecordID: recordID) { (recordID, error) in
                if let _ = recordID {
                    result(.success(()))
                } else {
                    result(.error(error!))
                }
            }
        }
    }
}
