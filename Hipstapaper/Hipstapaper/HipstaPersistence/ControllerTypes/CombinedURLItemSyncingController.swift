//
//  CombinedURLItemSyncingController.swift
//  Hipstapaper
//
//  Created by Jeffrey Bergier on 11/26/16.
//  Copyright © 2016 Jeffrey Bergier. All rights reserved.
//

class CombinedURLItemSyncingController: SyncingPersistenceType {
    
    private let realmController: SyncingPersistenceType = RealmURLItemSyncingController()
    private let cloudKitController: SyncingPersistenceType = CloudKitURLItemSyncingController()
    
    var ids: Set<String> {
        return self.realmController.ids
    }
    
    var isSyncing: Bool {
        return self.cloudKitController.isSyncing
    }
    
    func sync(completionHandler: SyncingPersistenceType.SuccessResult) {
        self.realmController.sync(completionHandler: completionHandler)
        self.cloudKitController.sync(completionHandler: .none)
    }
    
    func createItem() -> URLItemType {
        let cloudItem = self.cloudKitController.createItem()
        var realmItem = self.realmController.createItem()
        realmItem.cloudKitID = cloudItem.cloudKitID
        self.realmController.update(item: realmItem)
        return realmItem
    }
    
    func read(itemWithID id: String) -> URLItemType {
        return self.realmController.read(itemWithID: id)
    }
    
    func update(item: URLItemType) {
        self.cloudKitController.update(item: item)
        self.realmController.update(item: item)
    }
    
    func delete(item: URLItemType) {
        self.cloudKitController.delete(item: item)
        self.realmController.delete(item: item)
    }
}
