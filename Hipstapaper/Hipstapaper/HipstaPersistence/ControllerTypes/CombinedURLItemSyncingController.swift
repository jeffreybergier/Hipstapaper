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
    
    func sync(quickResult: SuccessResult?, fullResult: SuccessResult?) {
        self.realmController.sync(quickResult: quickResult) { realmResult in
            if case .success = realmResult {
                self.cloudKitController.sync(quickResult: .none) { cloudResult in
                    if case .success = cloudResult {
                        // now the cloud sync and the realm sync were both successful, time to sync
                        let syncer = RealmCloudKitSyncer(realmController: self.realmController, cloudKitController: self.cloudKitController)
                        // call to sync with the full completion handler
                        syncer.sync(syncResult: fullResult)
                    }
                }
            }
        }
    }
    
    func createItem(withID id: String?, quickResult: URLItemResult?, fullResult: URLItemResult?) {
        self.realmController.createItem(withID: nil, quickResult: quickResult) { realmResult in
            if case .success(var realmValue) = realmResult {
                self.cloudKitController.createItem(withID: realmValue.cloudKitID, quickResult: .none, fullResult: fullResult)
            }
        }
    }
    
    func readItem(withID id: String, quickResult: URLItemResult?, fullResult: URLItemResult?) {
        self.realmController.readItem(withID: id, quickResult: quickResult, fullResult: fullResult)
    }
    
    func update(item: URLItemType, quickResult: URLItemResult?, fullResult: URLItemResult?) {
        self.realmController.update(item: item, quickResult: quickResult) { realmResult in
            if case .success(let updatedItem) = realmResult {
                self.cloudKitController.update(item: updatedItem, quickResult: .none, fullResult: fullResult)
            }
        }
    }
    
    func delete(item: URLItemType, quickResult: SuccessResult?, fullResult: SuccessResult?) {
        self.realmController.delete(item: item, quickResult: quickResult) { realmResult in
            if case .success = realmResult {
                self.cloudKitController.delete(item: item, quickResult: .none, fullResult: fullResult)
            }
        }
    }
}
