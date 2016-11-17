//
//  URLItemsCloudKitSyncer.swift
//  Hipstapaper
//
//  Created by Jeffrey Bergier on 11/11/16.
//  Copyright © 2016 Jeffrey Bergier. All rights reserved.
//

import AppKit
import CloudKit

protocol RecordChangeDelegate: class {
    func bindingsObserver(_: URLListBindingObserver, didAdd records: [URLBindingItem])
    func bindingsObserver(_: URLListBindingObserver, didChange records: [URLBindingItem])
    func bindingsObserver(_: URLListBindingObserver, didDelete records: [URLBindingItem])
}

class URLListBindingObserver: NSObject {
    
    @IBOutlet private weak var arrayController: NSArrayController?
    
    weak var delegate: RecordChangeDelegate?
    
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
            
            // make sure new items are configured so we can listen for changes on them
            added?.forEach({ $0.changeDelegate = self })
            
            // make sure we add new items to cloudkit
            if let added = added {
                self.delegate?.bindingsObserver(self, didAdd: added)
            }
            
            // delete them from cloudkit
            if let deleted = deleted {
                self.delegate?.bindingsObserver(self, didDelete: deleted)
            }
            
            // save the newValue into the IVAR
            self._listItems = newValue
        }
    }
    
    func replaceList(list: [URLBindingItem]) {
        DispatchQueue.main.async {
            list.forEach({ $0.changeDelegate = self })
            self._listItems = list
            self.arrayController?.content = self.listItems // forces the array controller to redisplay
        }
    }
}

extension URLListBindingObserver: URLItemChangeDelegate {
    func itemDidChange(_ item: URLBindingItem) {
        self.delegate?.bindingsObserver(self, didChange: [item])
    }
}
