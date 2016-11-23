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
    
    private var _listItems: [URLItem.BindingObject] = []
    
    var listItems: [URLItem.BindingObject] {
        get {
            return self._listItems
        }
        set {
            // grab the old value. Its easier to understand when using this variable name
            let oldValue = self._listItems
            
            // find the deleted and added items
            let deleted = newValue.deletedItems(from: oldValue)
            
            // delete them from realm
            if let deleted = deleted {
                let realm = try! Realm()
                let items = deleted.map({ realm.object(ofType: URLItemRealmObject.self, forPrimaryKey: $0.realmID)! })
                realm.beginWrite()
                items.forEach({ realm.delete($0) })
                try! realm.commitWrite()
            }
            
            // set the IVAR
            self._listItems = newValue
        }
    }
    
    // access to the array controller so we can poke at it occasionally
    @IBOutlet private weak var arrayController: NSArrayController? {
        didSet {
            // set the default sort order on application launch
            self.arrayController?.sortDescriptors = [NSSortDescriptor(key: #keyPath(URLItem.BindingObject.modificationDate), ascending: false)]
        }
    }
    
    // Grab the selected items from the array controller
    var selectedItems: [URLItem.Value]? {
        let selectedItems = self.arrayController?.selectedObjects?.filter({ $0 is URLItem.BindingObject }).map({ $0 as! URLItem.BindingObject }) ?? []
        let mappedItems = selectedItems.map({ URLItem.Value(realmID: $0.realmID, urlString: $0.urlString, modificationDate: $0.modificationDate) })
        if mappedItems.isEmpty == false { return mappedItems } else { return .none }
    }
    
    override init() {
        super.init()
        self.reloadData()
    }
    
    func reloadData() {
        let ids = (NSApplication.shared().delegate as! AppDelegate).realmStorer.realmItemIDs
        let bindingItems = ids.map({ URLItem.BindingObject(realmID: $0) })
        self._listItems = bindingItems
        self.arrayController?.content = self.listItems
    }
    
}
