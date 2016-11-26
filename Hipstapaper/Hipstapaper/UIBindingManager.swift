//
//  RealmBindingManager.swift
//  Hipstapaper
//
//  Created by Jeffrey Bergier on 11/21/16.
//  Copyright © 2016 Jeffrey Bergier. All rights reserved.
//

import RealmSwift
import AppKit

class UIBindingManager: NSObject, URLItemBindingChangeDelegate {
    
    private var dataSource: SyncingPersistenceType {
        return (NSApplication.shared().delegate as! AppDelegate).dataSource
    }
    
    // access to the array controller so we can poke at it occasionally
    @IBOutlet private weak var arrayController: NSArrayController? {
        didSet {
            // set the default sort order on application launch
            self.arrayController?.sortDescriptors = [NSSortDescriptor(key: #keyPath(URLItem.BindingObject.modificationDate), ascending: false)]
        }
    }
    
    private var _listItems: [URLItem.BindingObject] = [] {
        didSet {
            self._listItems.forEach({ $0.delegate = self })
        }
    }
    
    @objc private var listItems: [URLItem.BindingObject] {
        get {
            return self._listItems
        }
        set {
            let oldValue = self._listItems
            let deleted = newValue.deletedItems(from: oldValue)
            deleted?.forEach() { deletedItem in
                self.dataSource.delete(item: deletedItem.value)
            }
            self._listItems = newValue
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
        self.dataSource.sync() { results in
            DispatchQueue.main.async {
                let ids = self.dataSource.ids
                let bindingObjects = ids.map() { id -> URLItem.BindingObject in
                    let urlValue = self.dataSource.read(itemWithID: id)
                    let bindingObject = URLItem.BindingObject(value: urlValue)
                    return bindingObject
                }
                self._listItems = bindingObjects
                self.arrayController?.content = self.listItems
            }
        }
    }
    
    func didChange(_ value: URLItemType) {
        self.dataSource.update(item: value)
    }
    
}

private protocol URLItemBindingChangeDelegate: class {
    func didChange(_: URLItemType)
}

extension URLItem {
    
    @objc(URLItemBindingObject)
    fileprivate class BindingObject: NSObject, URLItemType {
        
        private(set) fileprivate var value: URLItemType
        weak var delegate: URLItemBindingChangeDelegate?
        
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
                self.value.modificationDate = Date()
                self.delegate?.didChange(self.value)
            }
        }
        var archived: Bool {
            get {
                return self.value.archived
            }
            set {
                self.value.archived = newValue
                self.value.modificationDate = Date()
                self.delegate?.didChange(self.value)
            }
        }
        var tags: [TagItemType] {
            get {
                return self.value.tags
            }
            set {
                self.value.tags = newValue
                self.value.modificationDate = Date()
                self.delegate?.didChange(self.value)
            }
        }
        var modificationDate: Date {
            get {
                return self.value.modificationDate
            }
            set {
                self.value.modificationDate = newValue
                self.delegate?.didChange(self.value)
            }
        }
        
        private static var dataSource: SyncingPersistenceType {
            return (NSApplication.shared().delegate as! AppDelegate).dataSource
        }
        
        override init() {
            let newItem = BindingObject.dataSource.createItem()
            self.value = newItem
            super.init()
        }
        
        init(value: URLItemType) {
            self.value = value
            super.init()
        }
    }
}
