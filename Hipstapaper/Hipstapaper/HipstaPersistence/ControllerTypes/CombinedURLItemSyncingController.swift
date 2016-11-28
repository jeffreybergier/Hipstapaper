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
    
    func sync(completionHandler: @escaping SyncingPersistenceType.SuccessResult) {
        self.realmController.sync(completionHandler: completionHandler)
        self.cloudKitController.sync(completionHandler: {_ in})
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
                        self.realmController.update(item: realmValue, result: { _ in })
                    }
                }
            }
        }
    }
    
    func readItem(withID id: String, result: @escaping SyncingPersistenceType.URLItemResult) {
        self.realmController.readItem(withID: id, result: result)
    }
    
    func update(item: URLItemType, result: @escaping SyncingPersistenceType.URLItemResult) {
        self.realmController.update(item: item, result: result) // perform the update and return quickly
        self.cloudKitController.update(item: item, result: { _ in }) // update cloudkit and ignore result
    }
    
    func delete(item: URLItemType) {
        self.cloudKitController.delete(item: item)
        self.realmController.delete(item: item)
    }
}
