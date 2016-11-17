//
//  CloudKitComms.swift
//  Hipstapaper
//
//  Created by Jeffrey Bergier on 11/15/16.
//  Copyright © 2016 Jeffrey Bergier. All rights reserved.
//

import CloudKit

enum Result<T> {
    case success(T), error(Error)
}

typealias CloudKitReload = (Result<[CKRecord]>) -> Void
typealias CloudKitUpdate = (Result<Void>) -> Void

class CloudKitComms {
    
    private let privateDB = CKContainer.default().privateCloudDatabase
    private let recordType: String
    
    init(recordType: String) {
        self.recordType = recordType
    }
    
    func reloadData(completionHandler: @escaping CloudKitReload) {
        let predicate = NSPredicate(value: true)
        let initialQuery = CKQuery(recordType: self.recordType, predicate: predicate)
        
        self.privateDB.perform(initialQuery, inZoneWith: .none) { records, error in
            NSLog("Reloaded: \(records?.count ?? 0) Error: \(error)")
            if let error = error {
                completionHandler(.error(error))
            } else {
                completionHandler(.success(records ?? []))
            }
        }
    }
    
    func writeToCloudKit(item: CKRecord, completionHandler: @escaping CloudKitUpdate) {
        self.privateDB.save(item) { record, error in
            NSLog("\nSaved: \(item)\nError: \(error)")
            if let error = error {
                completionHandler(.error(error))
            } else {
                completionHandler(.success(()))
            }
        }
    }
    
    func deleteFromCloudKit(item: CKRecord, completionHandler: @escaping CloudKitUpdate) {
        self.privateDB.delete(withRecordID: item.recordID)  { (recordID, error) in
            NSLog("\nDeleted: \(item)\nError: \(error)")
            if let error = error {
                completionHandler(.error(error))
            } else {
                completionHandler(.success(()))
            }
        }
    }
}
