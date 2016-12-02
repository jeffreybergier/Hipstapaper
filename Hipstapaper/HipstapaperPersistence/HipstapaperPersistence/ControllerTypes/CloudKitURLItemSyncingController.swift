//
//  CloudKitURLItemSyncingController.swift
//  Hipstapaper
//
//  Created by Jeffrey Bergier on 11/26/16.
//  Copyright © 2016 Jeffrey Bergier. All rights reserved.
//

import CloudKit

open class CloudKitURLItemSyncingController: SingleSourcePersistenceType {
    
    private let privateDB = CKContainer(identifier: "iCloud.com.saturdayapps.Hipstapaper").privateCloudDatabase
    private let recordType = "URLItem"
    
    private let serialQueue = DispatchQueue(label: "CloudKitURLItemSyncingController", qos: .userInitiated)
    
    public private(set) var ids: Set<String> = []
    private var objectMap: [String : URLItem.CloudKitObject] = [:]
    
    public init() {}
        
    public func reloadData(result: SuccessResult?) {
        self.serialQueue.async {
            let predicate = NSPredicate(value: true)
            let initialQuery = CKQuery(recordType: self.recordType, predicate: predicate)
            self.privateDB.perform(initialQuery, inZoneWith: .none) { records, error in
                self.serialQueue.async {
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
                        result?(.success())
                    } else {
                        self.ids = []
                        self.objectMap = [:]
                        result?(.error([error!]))
                    }
                }
            }
        }
    }
    
    public func createItem(withID inputID: String?, result: URLItemResult?) {
        self.serialQueue.async {
            let emptyObject = URLItem.CloudKitObject()
            self.privateDB.save(emptyObject.record) { (record, error) in
                self.serialQueue.async {
                    if let record = record {
                        let newObject = URLItem.CloudKitObject(record: record)
                        if let inputID = inputID {
                            newObject.cloudKitID = inputID
                        }
                        let id = newObject.cloudKitID
                        self.objectMap[id] = newObject
                        self.ids.insert(id)
                        let newValue = URLItem.Value(cloudKitObject: newObject)
                        result?(.success(newValue))
                    } else {
                        result?(.error([error!]))
                    }
                }
            }
        }
    }
    
    public func readItem(withID id: String, result: URLItemResult?) {
        self.serialQueue.async {
            if let existingObject = self.objectMap[id] {
                let value = URLItem.Value(cloudKitObject: existingObject)
                result?(.success(value))
            } else {
                result?(.error([NSError()]))
            }
        }
    }
    
    public func update(item: URLItemType, result: URLItemResult?) {
        self.serialQueue.async {
            guard let existingObject = self.objectMap[item.cloudKitID]
                else { result?(.error([NSError()])); return; }
            existingObject.urlString = item.urlString
            existingObject.archived = item.archived
            existingObject.tags = item.tags
            existingObject.modificationDate = item.modificationDate
            self.privateDB.save(existingObject.record) { (record, error) in
                self.serialQueue.async {
                    if let record = record {
                        let updatedObject = URLItem.CloudKitObject(record: record)
                        let id = updatedObject.cloudKitID
                        self.objectMap[id] = updatedObject
                        self.ids.insert(id)
                        let updatedValue = URLItem.Value(cloudKitObject: updatedObject)
                        result?(.success(updatedValue))
                    } else {
                        result?(.error([error!]))
                    }
                }
            }
        }
    }
    
    public func delete(item: URLItemType, result: SuccessResult?) {
        self.serialQueue.async {
            let id = item.cloudKitID
            guard let existingObject = self.objectMap[id]
                else { result?(.error([NSError()])); return; }
            let recordID = existingObject.record.recordID
            self.ids.remove(id)
            self.objectMap[id] = .none
            self.privateDB.delete(withRecordID: recordID) { (recordID, error) in
                self.serialQueue.async {
                    if let _ = recordID {
                        result?(.success())
                    } else {
                        result?(.error([error!]))
                    }
                }
            }
        }
    }
}

extension CloudKitURLItemSyncingController: DoubleSourcePersistenceType {
    public func sync(quickResult: SuccessResult?, fullResult: SuccessResult?) {
        self.reloadData() { result in
            quickResult?(result)
            fullResult?(result)
        }
    }
    public func createItem(withID id: String?, quickResult: URLItemResult?, fullResult: URLItemResult?) {
        self.createItem(withID: id) { result in
            quickResult?(result)
            fullResult?(result)
        }
    }
    public func readItem(withID id: String, quickResult: URLItemResult?, fullResult: URLItemResult?) {
        self.readItem(withID: id) { result in
            quickResult?(result)
            fullResult?(result)
        }
    }
    public func update(item: URLItemType, quickResult: URLItemResult?, fullResult: URLItemResult?) {
        self.update(item: item) { result in
            quickResult?(result)
            fullResult?(result)
        }
    }
    public func delete(item: URLItemType, quickResult: SuccessResult?, fullResult: SuccessResult?) {
        self.delete(item: item) { result in
            quickResult?(result)
            fullResult?(result)
        }
    }
}
