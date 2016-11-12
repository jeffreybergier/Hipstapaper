//
//  URLItemsCloudKitSyncer.swift
//  Hipstapaper
//
//  Created by Jeffrey Bergier on 11/11/16.
//  Copyright © 2016 Jeffrey Bergier. All rights reserved.
//

import CloudKit

class URLItemsCloudKitSyncer: NSObject {
    
    override init() {
        super.init()
        
        let privateDB = CKContainer.default().publicCloudDatabase
        let predicate = NSPredicate(value: true)
        let initialQuery = CKQuery(recordType: "URLItem", predicate: predicate)
        privateDB.perform(initialQuery, inZoneWith: .none) { record, error in
            print(record)
            print(error)
        }
    }
    
}
