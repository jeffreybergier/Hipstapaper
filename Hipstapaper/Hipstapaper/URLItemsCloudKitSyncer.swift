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
    
    // set this property when downloading items that are already saved in cloudkit
    private var _listItems: [URLBindingItem] = []
    
    // set this property when you want the new things set to be saved back into cloudkit
    var listItems: [URLBindingItem] {
        get {
            return self._listItems
        }
        set {
            // grab the old value
            let oldValue = self._listItems
            
            // find the deleted and added items
            let deleted = newValue.deletedItems(from: oldValue)
            let added = newValue.addedItems(to: oldValue)
            
            // delete them from cloudkit
            deleted?.forEach({ self.deleteFromCloudKit(item: $0.record) })
            
            // make sure new items are configured so we can listen for changes on them
            added?.forEach({ $0.changeDelegate = self })
            
            // make sure we add new items to cloudkit
            added?.forEach({ self.writeToCloudKit(item: $0.record) })
            
            // save the newValue into the IVAR
            self._listItems = newValue
        }
    }
    
    // NSObject because any cocoa object could be sent by IB
    @IBAction private func refreshButtonClicked(sender: NSObject?) {
        self.refreshData()
    }
    
    private func refreshData() {
        let privateDB = CKContainer.default().privateCloudDatabase
        let predicate = NSPredicate(value: true)
        let initialQuery = CKQuery(recordType: "URLItem", predicate: predicate)
        
        privateDB.perform(initialQuery, inZoneWith: .none) { records, error in
            if let items = records?.map({ URLBindingItem(record: $0) }) {
                items.forEach({ $0.changeDelegate = self })
                self._listItems = items
                self.programmaticallyUpdatedListItems()
                NSLog("Refreshed: Downloaded: \(items.count)")
            }
            if let error = error { NSLog("Refresh: Error: \(error)") }
        }
    }
    
    private func programmaticallyUpdatedListItems() {
        DispatchQueue.main.async {
            self.arrayController?.content = self.listItems // forces the array controller to redisplay
        }
    }
    
    fileprivate func writeToCloudKit(item: CKRecord) {
        let privateDB = CKContainer.default().privateCloudDatabase
        privateDB.save(item) { record, error in
            NSLog("Saved: \(item): Error: \(error)")
        }
    }
    
    private func deleteFromCloudKit(item: CKRecord) {
        let privateDB = CKContainer.default().privateCloudDatabase
        privateDB.delete(withRecordID: item.recordID)  { (recordID, error) in
            NSLog("Deleted: \(item): Error: \(error)")
        }
    }
}

extension URLItemsCloudKitSyncer: URLItemChangeDelegate {
    func itemDidChange(_ item: URLBindingItem) {
        self.writeToCloudKit(item: item.record)
    }
}
