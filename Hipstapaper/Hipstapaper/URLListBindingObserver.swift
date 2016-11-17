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
    
    // Grab the selected items from the array controller
    var selectedItems: [URLBindingItem]? {
        let mappedItems = self.arrayController?.selectedObjects?.filter({ $0 is URLBindingItem }).map({ $0 as! URLBindingItem }) ?? []
        if mappedItems.isEmpty == false { return mappedItems } else { return .none }
    }
    
    // delegate so the WindowController can response to the user changing the URL objects
    weak var delegate: RecordChangeDelegate?
    
    // access to the array controller so we can poke at it occasionally
    @IBOutlet private weak var arrayController: NSArrayController? {
        didSet {
            // set the default sort order on application launch
            self.arrayController?.sortDescriptors = [NSSortDescriptor(key: #keyPath(URLBindingItem.modificationDate), ascending: false)]
        }
    }
    
    // set this property when downloading items that are already saved in cloudkit
    private var _listItems: [URLBindingItem] = []
    
    // set this property when you want the new things set to be saved back into cloudkit
    @objc private var listItems: [URLBindingItem] {
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
    
    // replace the filter list from the outside without going through the normal bindings trigger
    // this is needed when we fetch items from cloudkit manually, we don't want them resynced
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
