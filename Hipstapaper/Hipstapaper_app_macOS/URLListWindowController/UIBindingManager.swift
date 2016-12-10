//
//  RealmBindingManager.swift
//  Hipstapaper
//
//  Created by Jeffrey Bergier on 11/21/16.
//  Copyright © 2016 Jeffrey Bergier. All rights reserved.
//

import HipstapaperPersistence
import AppKit

class UIBindingManager: NSObject, URLItemBindingChangeDelegate {
    
    weak var dataSource: URLItemCRUDDoublePersistanceType! {
        didSet {
            self.reloadData()
        }
    }
    
    private var spinnerOperationsInProgress = 0 {
        didSet {
            DispatchQueue.main.async {
                if self.spinnerOperationsInProgress > 0 {
                    self.syncingToolbarActivityIndicator?.startAnimation(self)
                } else {
                    self.syncingToolbarActivityIndicator?.stopAnimation(self)
                }
            }
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
                self.spinnerOperationsInProgress += 1 // update the spinner
                let itemToCreate = newBindingObject.value ?? URLItem.Value()
                self.dataSource.create(item: itemToCreate, quickResult: { createResult in
                    DispatchQueue.main.async {
                        switch createResult {
                        case .success(let createdItem):
                            newBindingObject.value = createdItem
                        case .error(let errors):
                            newBindingObject.value = itemToCreate
                            NSLog("Error Creating Item: \(itemToCreate) Error: \(errors)")
                        }
                    }
                }, fullResult: { _ in
                    DispatchQueue.main.async {
                        self.spinnerOperationsInProgress -= 1 // update the spinner
                    }
                })
            }
            let deleted = newValue.deletedItems(from: oldValue)
            deleted?.forEach() { deletedItem in
                self.spinnerOperationsInProgress += 1 // update the spinner
                guard let item = deletedItem.value else { return }
                self.dataSource.delete(item: item, quickResult: .none, fullResult: { _ in
                    DispatchQueue.main.async {
                        self.spinnerOperationsInProgress -= 1
                    }
                })
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
        DispatchQueue.main.async {
            self.spinnerOperationsInProgress += 1 // update the spinner
            self.dataSource.sync(sortedBy: .urlString, ascending: true, quickResult: { quickResult in
                let sortedIDs: [String]
                switch quickResult {
                case .success(let ids):
                    sortedIDs = ids
                case .error(let errors):
                    NSLog("Errors While Syncing: \(errors)")
                    sortedIDs = []
                }
                self.process(sortedIDs: sortedIDs) // process the data
            }, fullResult: { fullResult in
                let sortedIDs: [String]
                switch fullResult {
                case .success(let ids):
                    sortedIDs = ids
                case .error(let errors):
                    NSLog("Errors While Syncing: \(errors)")
                    sortedIDs = []
                }
                self.process(sortedIDs: sortedIDs) // process the data
                DispatchQueue.main.async {
                    self.spinnerOperationsInProgress -= 1 // update the spinner
                }
            })
        }
    }
    
    private func process(sortedIDs ids: [String]) {
        DispatchQueue.global(qos: .userInitiated).async {
            let bindingObjects = ids.map() { id -> URLItem.BindingObject in
                let bindingObject = URLItem.BindingObject(value: nil)
                self.spinnerOperationsInProgress += 1 // update the spinner
                self.dataSource.readItem(withID: id) { result in
                    if case .success(let urlItem) = result {
                        DispatchQueue.main.async {
                            bindingObject.value = urlItem
                            self.spinnerOperationsInProgress -= 1 // update the spinner
                        }
                    }
                }
                return bindingObject
            }
            DispatchQueue.main.async {
                self._listItems = bindingObjects
                self.arrayController?.content = self.listItems
            }
        }
    }
    
    fileprivate func didChange(item: URLItemType, withinObject object: URLItem.BindingObject) {
        self.spinnerOperationsInProgress += 1 // update the spinner
        self.dataSource.update(item: item, quickResult: { result in
            DispatchQueue.main.async {
                if case .success(let updatedValue) = result {
                    object.value = updatedValue
                } else {
                    object.value = .none
                }
            }
        }, fullResult: { _ in
            DispatchQueue.main.async {
                self.spinnerOperationsInProgress -= 1 // update the spinner
            }
        })
    }
    
}

private protocol URLItemBindingChangeDelegate: class {
    func didChange(item: URLItemType, withinObject object: URLItem.BindingObject)
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
                self.willChangeValue(forKey: "tags")
                self.willChangeValue(forKey: #keyPath(BindingObject.modificationDate))
            }
            didSet {
                self.didChangeValue(forKey: #keyPath(BindingObject.realmID))
                self.didChangeValue(forKey: #keyPath(BindingObject.cloudKitID))
                self.didChangeValue(forKey: #keyPath(BindingObject.urlString))
                self.didChangeValue(forKey: #keyPath(BindingObject.archived))
                self.didChangeValue(forKey: "tags")
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
                self.delegate?.didChange(item: value, withinObject: self)
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
                self.delegate?.didChange(item: value, withinObject: self)
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
                self.delegate?.didChange(item: value, withinObject: self)
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
                self.delegate?.didChange(item: value, withinObject: self)
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
