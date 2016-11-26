//
//  CloudKitSyncer.swift
//  Hipstapaper
//
//  Created by Jeffrey Bergier on 11/23/16.
//  Copyright © 2016 Jeffrey Bergier. All rights reserved.
//

import CloudKit

class CloudKitSyncer {
    
    private let privateDB = CKContainer.default().privateCloudDatabase
    private let recordType: String
    
    init(recordType: String) {
        self.recordType = recordType
    }
    
    convenience init() {
        self.init(recordType: "URLItem")
    }
    
    private var operationsInProgress = 0
    
    func allCloudKitURLItems(completionHandler: @escaping (Result<[URLItem.CloudKitObject]>) -> Void) {
        guard self.operationsInProgress == 0 else { completionHandler(.success([])); return; }
        
        let predicate = NSPredicate(value: true)
        let initialQuery = CKQuery(recordType: self.recordType, predicate: predicate)
        
        self.operationsInProgress = 1
        self.privateDB.perform(initialQuery, inZoneWith: .none) { records, error in
            self.operationsInProgress = 0
//            records?.forEach() { record in
//                self.privateDB.delete(withRecordID: record.recordID, completionHandler: {_ in})
//            }
            NSLog("Reloaded: \(records?.count ?? 0) Error: \(error)")
            if let error = error {
                completionHandler(.error(error))
            } else {
                let comparisons = records?.map({ URLItem.CloudKitObject(record: $0) })
                completionHandler(.success(comparisons ?? []))
            }
        }
    }
    
    private var realmToCloudIDsResultsToReturn: [String : Result<String>] = [:]
    
    func save(records: [(String, CKRecord)], completionHandler: @escaping ([String : Result<String>]) -> Void) {
        guard self.operationsInProgress == 0 else { completionHandler([:]); return; }
        
        self.operationsInProgress = records.count
        for (realmID, record) in records {
            self.privateDB.save(record) { (updatedRecord, error) in
                self.operationsInProgress -= 1
                if let updatedRecord = updatedRecord {
                    self.realmToCloudIDsResultsToReturn[realmID] = .success(updatedRecord.recordID.recordName)
                } else {
                    self.realmToCloudIDsResultsToReturn[realmID] = .error(error!)
                }
                if self.operationsInProgress == 0 {
                    completionHandler(self.realmToCloudIDsResultsToReturn)
                    self.realmToCloudIDsResultsToReturn = [:]
                }
            }
        }
    }
    
}
