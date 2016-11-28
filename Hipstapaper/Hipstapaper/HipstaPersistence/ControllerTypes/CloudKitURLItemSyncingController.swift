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
        
    func sync(quickResult: @escaping SuccessResult, fullResult: @escaping SuccessResult) {
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
                    quickResult(.success())
                    fullResult(.success())
                } else {
                    self.ids = []
                    self.objectMap = [:]
                    quickResult(.error(error!))
                    fullResult(.error(error!))
                }
            }
        }
    }
    
    func createItem(withID inputID: String?, quickResult: @escaping URLItemResult, fullResult: @escaping URLItemResult) {
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
                    quickResult(.success(newValue))
                    fullResult(.success(newValue))
                } else {
                    quickResult(.error(error!))
                    fullResult(.error(error!))
                }
            }
        }
    }
    
    func readItem(withID id: String, quickResult: @escaping URLItemResult, fullResult: @escaping URLItemResult) {
        DispatchQueue.global(qos: .userInteractive).async {
            if let existingObject = self.objectMap[id] {
                let value = URLItem.Value(cloudKitObject: existingObject)
                quickResult(.success(value))
                fullResult(.success(value))
            } else {
                quickResult(.error(NSError()))
                fullResult(.error(NSError()))
            }
        }
    }
    
    func update(item: URLItemType, quickResult: @escaping URLItemResult, fullResult: @escaping URLItemResult) {
        DispatchQueue.global(qos: .userInteractive).async {
            guard let existingObject = self.objectMap[item.cloudKitID]
                else { quickResult(.error(NSError())); fullResult(.error(NSError())); return; }
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
                    quickResult(.success(updatedValue))
                    fullResult(.success(updatedValue))
                } else {
                    quickResult(.error(error!))
                    fullResult(.error(error!))
                }
            }
        }
    }
    
    func delete(item: URLItemType, quickResult: @escaping SuccessResult, fullResult: @escaping SuccessResult) {
        DispatchQueue.global(qos: .userInteractive).async {
            let id = item.cloudKitID
            guard let existingObject = self.objectMap[id]
                else { quickResult(.error(NSError())); fullResult(.error(NSError())); return; }
            let recordID = existingObject.record.recordID
            self.ids.remove(id)
            self.objectMap[id] = .none
            self.privateDB.delete(withRecordID: recordID) { (recordID, error) in
                if let _ = recordID {
                    quickResult(.success())
                    fullResult(.success())
                } else {
                    quickResult(.error(error!))
                    fullResult(.error(error!))
                }
            }
        }
    }
}
