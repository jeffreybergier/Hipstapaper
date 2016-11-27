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
    }
    
    func createItem() -> URLItemType {
        return self.realmController.createItem()
    }
    
    func read(itemWithID id: String) -> URLItemType {
        return self.realmController.read(itemWithID: id)
    }
    
    func update(item: URLItemType) {
        self.realmController.update(item: item)
    }
    
    func delete(item: URLItemType) {
        self.realmController.delete(item: item)
    }
}
