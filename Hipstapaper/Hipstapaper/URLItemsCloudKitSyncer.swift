//
//  URLItemsCloudKitSyncer.swift
//  Hipstapaper
//
//  Created by Jeffrey Bergier on 11/11/16.
//  Copyright © 2016 Jeffrey Bergier. All rights reserved.
//

import CloudKit

class URLItemsCloudKitSyncer: NSObject {
    
    var listItems: [URLItem] = [
            URLItem(urlString: "http://www.apple.com"),
            URLItem(urlString: "http://www.microsoft.com"),
            URLItem(urlString: "http://www.google.com")
        ] {
        didSet {
            print("array changed")
        }
    }
    
    override init() {
        super.init()
        
        let privateDB = CKContainer.default().privateCloudDatabase
        let predicate = NSPredicate(value: true)
    
        
        let initialQuery = CKQuery(recordType: "URLItem", predicate: predicate)
        privateDB.perform(initialQuery, inZoneWith: .none) { record, error in
            print(record)
            print(error)
        }
        
//        let record = CKRecord(recordType: "URLItem")
//        record["urlString"] = "mysweetwebsite.com" as! CKRecordValue
//        privateDB.save(record) { record, error in
//            print(record)
//            print(error)
//        }
    }
    
}
