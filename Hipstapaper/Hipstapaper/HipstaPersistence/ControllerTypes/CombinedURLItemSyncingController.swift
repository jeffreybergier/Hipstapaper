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
    
    func sync(quickSyncResult: @escaping SyncingPersistenceType.SuccessResult,
              fullSyncResult: @escaping SyncingPersistenceType.SuccessResult)
    {
        self.realmController.sync(quickSyncResult: quickSyncResult, fullSyncResult: { realmResult in // perform the update and return quickly
            self.cloudKitController.sync(quickSyncResult: { _ in }, fullSyncResult: fullSyncResult) // sync cloudkit and ignore result
        })
    }
    
    func createItem(withID id: String?, result: @escaping SyncingPersistenceType.URLItemResult) {
        self.realmController.createItem(withID: id) { realmResult in
            // pass this back immediately because realm is fast
            result(realmResult)
            
            // if successful then add it to cloudkit to keep things in sync
            if case .success(var realmValue) = realmResult {
                self.cloudKitController.createItem(withID: realmValue.cloudKitID, result: { _ in })
            }
        }
    }
    
    func readItem(withID id: String, result: @escaping SyncingPersistenceType.URLItemResult) {
        self.realmController.readItem(withID: id, result: result) // perform the update and return quickly
    }
    
    func update(item: URLItemType, result: @escaping SyncingPersistenceType.URLItemResult) {
        self.realmController.update(item: item) { realmResult in
            result(realmResult) // perform the update and return quickly
            self.cloudKitController.update(item: item, result: { _ in }) // update cloudkit and ignore result
        }
    }
    
    func delete(item: URLItemType, result: @escaping SyncingPersistenceType.SuccessResult) {
        self.realmController.delete(item: item) { realmResult in
            result(realmResult) // perform the update and return quickly
            self.cloudKitController.delete(item: item, result: { _ in }) // update cloudkit and ignore result
        }
    }
}
