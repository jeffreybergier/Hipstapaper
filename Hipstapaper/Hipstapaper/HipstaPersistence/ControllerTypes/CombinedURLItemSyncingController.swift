//
//  CombinedURLItemSyncingController.swift
//  Hipstapaper
//
//  Created by Jeffrey Bergier on 11/26/16.
//  Copyright © 2016 Jeffrey Bergier. All rights reserved.
//

class CombinedURLItemSyncingController: SyncingPersistenceType {
    
    private let realmController /*: SyncingPersistenceType */ = RealmURLItemSyncingController()
    private let cloudKitController /*: SyncingPersistenceType */ = CloudKitURLItemSyncingController()
    
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
    
    func createItem(result: @escaping SyncingPersistenceType.URLItemResult) {
        self.realmController.createItem() { realmResult in
            // passs this back immediately because realm is fast
            result(realmResult)
            
            // then add it to cloudkit to keep thing sin sync
            if case .success(var realmValue) = realmResult {
                self.cloudKitController.createItem() { cloudResult in
                    // if it comes back from cloudkit successfully
                    // update the realm object to have the correct cloudkit id
                    if case .success(let cloudValue) = cloudResult {
                        realmValue.cloudKitID = cloudValue.cloudKitID
                        self.realmController.update(item: realmValue)
                    }
                }
            }
        }
    }
    
    func read(itemWithID id: String) -> URLItemType? {
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
