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
    
    weak var dataSource: SyncingPersistenceType! {
        didSet {
            self.reloadData()
        }
    }
    
    // access to the array controller so we can poke at it occasionally
    @IBOutlet private weak var arrayController: NSArrayController? {
        didSet {
            // set the default sort order on application launch
            self.arrayController?.sortDescriptors = [NSSortDescriptor(key: #keyPath(URLItem.BindingObject.modificationDate), ascending: false)]
        }
    }
    
    @IBOutlet private weak var syncingToolbarActivityIndicator: NSProgressIndicator? {
        didSet {
            self.syncingToolbarActivityIndicator?.stopAnimation(self)
            self.syncingToolbarActivityIndicator?.isDisplayedWhenStopped = false
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
            let new = newValue.filter({ $0.value == nil })
            new.forEach() { newBindingObject in
                self.dataSource.createItem() { result in
                    if case .success(let urlItem) = result {
                        DispatchQueue.main.async {
                            newBindingObject.value = urlItem
                        }
                    }
                }
            }
            let deleted = newValue.deletedItems(from: oldValue)
            deleted?.forEach() { deletedItem in
                guard let item = deletedItem.value else { return }
                self.dataSource.delete(item: item)
            }
            self._listItems = newValue
        }
    }
    
    // Grab the selected items from the array controller
    var selectedItems: [URLItemType]? {
        let selectedItems = self.arrayController?.selectedObjects?.filter({ $0 is URLItem.BindingObject }).map({ $0 as! URLItem.BindingObject }) ?? []
        let mappedItems = selectedItems.map({ URLItem.Value(realmID: $0.realmID, cloudKitID: $0.cloudKitID, urlString: $0.urlString, modificationDate: $0.modificationDate) })
        if mappedItems.isEmpty == false { return mappedItems } else { return .none }
    }
    
    func reloadData() {
        self.syncingToolbarActivityIndicator?.startAnimation(self)
        self.dataSource.sync() { results in
            let ids = self.dataSource.ids
            let bindingObjects = ids.map() { id -> URLItem.BindingObject in
                let bindingObject = URLItem.BindingObject(value: nil)
                self.dataSource.readItem(withID: id) { result in
                    if case .success(let urlItem) = result {
                        DispatchQueue.main.async {
                            bindingObject.value = urlItem
                        }
                    }
                }
                return bindingObject
            }
            DispatchQueue.main.async {
                self._listItems = bindingObjects
                self.arrayController?.content = self.listItems
                self.syncingToolbarActivityIndicator?.stopAnimation(self)
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
        
        fileprivate(set) var value: URLItemType? {
            willSet {
                self.willChangeValue(forKey: #keyPath(BindingObject.realmID))
                self.willChangeValue(forKey: #keyPath(BindingObject.cloudKitID))
                self.willChangeValue(forKey: #keyPath(BindingObject.urlString))
                self.willChangeValue(forKey: #keyPath(BindingObject.archived))
//                self.willChangeValue(forKey: #keyPath(BindingObject.tags))
                self.willChangeValue(forKey: #keyPath(BindingObject.modificationDate))
            }
            didSet {
                self.didChangeValue(forKey: #keyPath(BindingObject.realmID))
                self.didChangeValue(forKey: #keyPath(BindingObject.cloudKitID))
                self.didChangeValue(forKey: #keyPath(BindingObject.urlString))
                self.didChangeValue(forKey: #keyPath(BindingObject.archived))
//                self.didChangeValue(forKey: #keyPath(BindingObject.tags))
                self.didChangeValue(forKey: #keyPath(BindingObject.modificationDate))
            }
        }
        weak var delegate: URLItemBindingChangeDelegate?
        
        var realmID: String {
            get {
                return self.value?.realmID ?? "–"
            }
            set {
                fatalError("Cannot change the ID from the tableview")
            }
        }
        var cloudKitID: String {
            get {
                return self.value?.cloudKitID ?? "–"
            }
            set {
                fatalError("Cannot change the ID from the tableview")
            }
        }
        var urlString: String {
            get {
                return self.value?.urlString ?? "–"
            }
            set {
                guard var value = self.value else { return }
                value.urlString = newValue
                value.modificationDate = Date()
                self.value = value
                self.delegate?.didChange(value)
            }
        }
        var archived: Bool {
            get {
                return self.value?.archived ?? false
            }
            set {
                guard var value = self.value else { return }
                value.archived = newValue
                value.modificationDate = Date()
                self.value = value
                self.delegate?.didChange(value)
            }
        }
        var tags: [TagItemType] {
            get {
                return self.value?.tags ?? []
            }
            set {
                guard var value = self.value else { return }
                value.tags = newValue
                value.modificationDate = Date()
                self.value = value
                self.delegate?.didChange(value)
            }
        }
        var modificationDate: Date {
            get {
                return self.value?.modificationDate ?? Date()
            }
            set {
                guard var value = self.value else { return }
                value.modificationDate = newValue
                self.value = value
                self.delegate?.didChange(value)
            }
        }
        
        override init() {
            self.value = .none
            super.init()
        }
        
        init(value: URLItemType?) {
            self.value = value
            super.init()
        }
    }
}
