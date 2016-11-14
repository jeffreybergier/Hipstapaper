//
//  URLItemsCloudKitSyncer.swift
//  Hipstapaper
//
//  Created by Jeffrey Bergier on 11/11/16.
//  Copyright © 2016 Jeffrey Bergier. All rights reserved.
//

import CloudKit
import AppKit

class URLItemsCloudKitSyncer: NSObject {
    
    @IBOutlet private weak var arrayController: NSArrayController?
    
    var listItems: [URLItem] = [] {
        didSet {
            let deleted = self.listItems.deletedItems(from: oldValue)
            let added = self.listItems.addedItems(to: oldValue)
            
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
        
        let privateDB = CKContainer.default().privateCloudDatabase
        let predicate = NSPredicate(value: true)
        
        let initialQuery = CKQuery(recordType: "URLItem", predicate: predicate)
        privateDB.perform(initialQuery, inZoneWith: .none) { records, error in
            DispatchQueue.main.async {
                if let items = records?.map({ URLItem(record: $0) }) {
                    self.listItems += items
                    self.programmaticallyUpdatedListItems()
                }
                if let error = error { print("Downloading Records Failed: \(error)") }
            }
        }
        
//        let record = CKRecord(recordType: "URLItem")
//        record["urlString"] = "mysweetwebsite.com" as! CKRecordValue
//        privateDB.save(record) { record, error in
//            print(record)
//            print(error)
//        }
    }
    
    func programmaticallyUpdatedListItems() {
        self.arrayController?.content = self.listItems // forces the array controller to redisplay
    }
    
}

extension URLItemsCloudKitSyncer: URLItemChangeDelegate {
    func itemDidChange(_ item: URLItem) {
        print("Changed:\n\(item)")
    }
}
