//
//  CloudKitComms.swift
//  Hipstapaper
//
//  Created by Jeffrey Bergier on 11/15/16.
//  Copyright © 2016 Jeffrey Bergier. All rights reserved.
//

import CloudKit

typealias CloudKitLoad = (([CKRecord]) throws -> Void) -> Void
typealias CloudKitUpdate = ((Void) throws -> Void) -> Void

class CloudKitComms {
    private func refreshData(completionHandler: @escaping CloudKitLoad) {
        let privateDB = CKContainer.default().privateCloudDatabase
        let predicate = NSPredicate(value: true)
        let initialQuery = CKQuery(recordType: "URLItem", predicate: predicate)
        
        privateDB.perform(initialQuery, inZoneWith: .none) { records, error in
            if let items = records {
                NSLog("Refreshed: Downloaded: \(items.count)")
                completionHandler({ _ in return items })
            } else if let error = error {
                NSLog("Refresh: Error: \(error)")
                completionHandler({ _ in throw error })
            } else {
                fatalError()
            }
        }
    }
    
    func writeToCloudKit(item: CKRecord, completionHandler: @escaping CloudKitUpdate) {
        let privateDB = CKContainer.default().privateCloudDatabase
        privateDB.save(item) { record, error in
            NSLog("Saved: \(item): Error: \(error)")
            if let error = error {
                completionHandler({ throw error })
            } else {
                completionHandler({})
            }
        }
    }
    
    func deleteFromCloudKit(item: CKRecord, completionHandler: @escaping CloudKitUpdate) {
        let privateDB = CKContainer.default().privateCloudDatabase
        privateDB.delete(withRecordID: item.recordID)  { (recordID, error) in
            NSLog("Deleted: \(item): Error: \(error)")
            if let error = error {
                completionHandler({ throw error })
            } else {
                completionHandler({})
            }
        }
    }
}
