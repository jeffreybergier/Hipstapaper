//
//  URLItemsCloudKitSyncer.swift
//  Hipstapaper
//
//  Created by Jeffrey Bergier on 11/11/16.
//  Copyright © 2016 Jeffrey Bergier. All rights reserved.
//

import CloudKit

class URLItemsCloudKitSyncer: NSObject {
    
    var listItems: [URLItem] = [] {
        didSet {
            let deleted = Set(self.listItems).deletedItems(from: Set(oldValue))
            let added = Set(self.listItems).addedItems(to: Set(oldValue))
            
            if let deleted = deleted {
                print("Deleted:\n\(deleted)")
            }
            if let added = added {
                print("Added:\n\(added)")
                added.forEach({ $0.changeDelegate = self })
            }
        }
    }
    
    override init() {
        super.init()
        
//        let privateDB = CKContainer.default().privateCloudDatabase
//        let predicate = NSPredicate(value: true)
//    
//        
//        let initialQuery = CKQuery(recordType: "URLItem", predicate: predicate)
//        privateDB.perform(initialQuery, inZoneWith: .none) { record, error in
//            print(record)
//            print(error)
//        }
        
//        let record = CKRecord(recordType: "URLItem")
//        record["urlString"] = "mysweetwebsite.com" as! CKRecordValue
//        privateDB.save(record) { record, error in
//            print(record)
//            print(error)
//        }
    }
    
}

extension URLItemsCloudKitSyncer: URLItemChangeDelegate {
    func itemDidChange(_ item: URLItem) {
        print("Changed:\n\(item)")
    }
}
