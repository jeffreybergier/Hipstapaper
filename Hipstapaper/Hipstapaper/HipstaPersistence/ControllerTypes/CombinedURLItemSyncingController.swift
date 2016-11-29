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
    
    func sync(quickResult: @escaping SuccessResult, fullResult: @escaping SuccessResult) {
        self.realmController.sync(quickResult: quickResult) { realmResult in
            if case .success = realmResult {
                self.cloudKitController.sync(quickResult: { _ in }) { cloudResult in
                    fullResult(cloudResult)
                    if case .success = cloudResult {
                        // now the cloud sync and the realm sync were both successful, time to sync
                        let syncer = RealmCloudKitSyncer(realmController: self.realmController, cloudKitController: self.cloudKitController)
                        syncer.sync() { syncResult in
                            print("Sync Complete: Result: \(syncResult)")
                        }
                    }
                }
            }
        }
    }
    
    func createItem(withID id: String?, quickResult: @escaping URLItemResult, fullResult: @escaping URLItemResult) {
        self.realmController.createItem(withID: nil, quickResult: quickResult) { realmResult in
            if case .success(var realmValue) = realmResult {
                self.cloudKitController.createItem(withID: realmValue.cloudKitID, quickResult: { _ in }, fullResult: fullResult)
            }
        }
    }
    
    func readItem(withID id: String, quickResult: @escaping URLItemResult, fullResult: @escaping URLItemResult) {
        self.realmController.readItem(withID: id, quickResult: quickResult, fullResult: fullResult)
    }
    
    func update(item: URLItemType, quickResult: @escaping URLItemResult, fullResult: @escaping URLItemResult) {
        self.realmController.update(item: item, quickResult: quickResult) { realmResult in
            if case .success(let updatedItem) = realmResult {
                self.cloudKitController.update(item: updatedItem, quickResult: { _ in }, fullResult: fullResult)
            }
        }
    }
    
    func delete(item: URLItemType, quickResult: @escaping SuccessResult, fullResult: @escaping SuccessResult) {
        self.realmController.delete(item: item, quickResult: quickResult) { realmResult in
            if case .success = realmResult {
                self.cloudKitController.delete(item: item, quickResult: { _ in }, fullResult: fullResult)
            }
        }
    }
}
