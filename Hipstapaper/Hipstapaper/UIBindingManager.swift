//
//  RealmBindingManager.swift
//  Hipstapaper
//
//  Created by Jeffrey Bergier on 11/21/16.
//  Copyright © 2016 Jeffrey Bergier. All rights reserved.
//

import RealmSwift
import AppKit

class UIBindingManager: NSObject {
    
    private var dataSource: SyncingPersistenceType {
        return (NSApplication.shared().delegate as! AppDelegate).dataSource
    }
    
    @objc private var listItems: [URLItem.BindingObject] = []
    
    // access to the array controller so we can poke at it occasionally
    @IBOutlet private weak var arrayController: NSArrayController? {
        didSet {
            // set the default sort order on application launch
            self.arrayController?.sortDescriptors = [NSSortDescriptor(key: #keyPath(URLItem.BindingObject.modificationDate), ascending: false)]
        }
    }
    
    // Grab the selected items from the array controller
    var selectedItems: [URLItemType]? {
        let selectedItems = self.arrayController?.selectedObjects?.filter({ $0 is URLItem.BindingObject }).map({ $0 as! URLItem.BindingObject }) ?? []
        let mappedItems = selectedItems.map({ URLItem.Value(realmID: $0.realmID, urlString: $0.urlString, modificationDate: $0.modificationDate) })
        if mappedItems.isEmpty == false { return mappedItems } else { return .none }
    }
    
    override init() {
        super.init()
        self.reloadData()
    }
    
    func reloadData() {
        let ids = self.dataSource.ids
        let bindingObjects = ids.map() { id -> URLItem.BindingObject in
            let urlValue = self.dataSource.read(itemWithID: id)
            let bindingObject = URLItem.BindingObject(value: urlValue)
            return bindingObject
        }
        self.listItems = bindingObjects
        self.arrayController?.content = self.listItems
    }
    
}

extension URLItem {
    
    @objc(URLItemBindingObject)
    fileprivate class BindingObject: NSObject, URLItemType {
        
        private var value: URLItemType
        
        var realmID: String {
            get {
                return self.value.realmID
            }
            set {
                fatalError("Cannot change the ID from the tableview")
            }
        }
        var cloudKitID: String? {
            get {
                return self.value.cloudKitID
            }
            set {
                fatalError("Cannot change the ID from the tableview")
            }
        }
        var urlString: String {
            get {
                return self.value.urlString
            }
            set {
                self.value.urlString = newValue
            }
        }
        var archived: Bool {
            get {
                return self.value.archived
            }
            set {
                self.value.archived = newValue
            }
        }
        var tags: [TagItemType] {
            get {
                return self.value.tags
            }
            set {
                self.value.tags = newValue
            }
        }
        var modificationDate: Date {
            get {
                return self.value.modificationDate
            }
            set {
                self.modificationDate = newValue
            }
        }
        
        override init() {
            fatalError()
        }
        
        init(value: URLItemType) {
            self.value = value
            super.init()
        }
    }
}
