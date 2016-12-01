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
        // put the quick result handler in the realmController
        self.realmController.sync(quickResult: quickResult) { realmResult in
            switch realmResult {
            case .error:
                // if realm errors, call fullResult with the realmError
                fullResult?(realmResult)
            case .success:
                // if realm is successful, continue to cloud controller
                self.cloudKitController.sync(quickResult: .none) { cloudResult in
                    switch cloudResult {
                    case .error:
                        // if cloud errors, call fullResult with the cloudError
                        fullResult?(cloudResult)
                    case .success:
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
            switch realmResult {
            case .error:
                // if realm errors, call fullResult with the realmError
                fullResult?(realmResult)
            case .success(let realmValue):
                // if realm is successful, continue to cloud controller
                self.cloudKitController.createItem(withID: realmValue.cloudKitID, quickResult: .none, fullResult: fullResult)
            }
        }
    }
    
    func readItem(withID id: String, quickResult: URLItemResult?, fullResult: URLItemResult?) {
        self.realmController.readItem(withID: id, quickResult: quickResult) { realmResult in
            switch realmResult {
            case .success:
                // if realm succeeds, just finish
                fullResult?(realmResult)
            case .error:
                // if realm errors, try getting the value from the cloud
                self.cloudKitController.readItem(withID: id, quickResult: .none, fullResult: fullResult)
            }
            
        }
    }
    
    func update(item: URLItemType, quickResult: URLItemResult?, fullResult: URLItemResult?) {
        self.realmController.update(item: item, quickResult: quickResult) { realmResult in
            switch realmResult {
            case .error:
                // if realm errors, call fullResult with the realmError
                fullResult?(realmResult)
            case .success(let updatedItem):
                // if realm is successful, continue to cloud controller
                self.cloudKitController.update(item: updatedItem, quickResult: .none, fullResult: fullResult)
            }
        }
    }
    
    func delete(item: URLItemType, quickResult: SuccessResult?, fullResult: SuccessResult?) {
        self.realmController.delete(item: item, quickResult: quickResult) { realmResult in
            switch realmResult {
            case .error:
                // if realm errors, call fullResult with the realmError
                fullResult?(realmResult)
            case .success:
                // if realm is successful, continue to cloud controller
                self.cloudKitController.delete(item: item, quickResult: .none, fullResult: fullResult)
            }
        }
    }
}
