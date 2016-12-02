//
//  CombinedURLItemSyncingController.swift
//  Hipstapaper
//
//  Created by Jeffrey Bergier on 11/26/16.
//  Copyright © 2016 Jeffrey Bergier. All rights reserved.
//

open class CombinedURLItemSyncingController: DoubleSourcePersistenceType {
    
    private let realmController: SingleSourcePersistenceType = RealmURLItemSyncingController()
    private let cloudKitController: SingleSourcePersistenceType = CloudKitURLItemSyncingController()
    
    public var ids: Set<String> {
        return self.realmController.ids
    }
    
    public init() {}
    
    public func sync(quickResult: SuccessResult?, fullResult: SuccessResult?) {
        self.realmController.reloadData() { realmResult in
            // always call the quick result with the results of realm
            quickResult?(realmResult)
            
            switch realmResult {
            case .error:
                // if realm errors, also call fullResult with the realmError
                fullResult?(realmResult)
            case .success:
                // if realm is successful, continue to cloud controller
                self.cloudKitController.reloadData() { cloudResult in
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
    
    public func createItem(withID id: String?, quickResult: URLItemResult?, fullResult: URLItemResult?) {
        self.realmController.createItem(withID: id) { realmResult in
            // always call the quick result with the results of realm
            quickResult?(realmResult)
            
            switch realmResult {
            case .error:
                // if realm errors, call fullResult with the realmError
                fullResult?(realmResult)
            case .success(let realmValue):
                // if realm is successful, continue to cloud controller
                self.cloudKitController.createItem(withID: realmValue.cloudKitID, result: fullResult)
            }
        }
    }
    
    public func readItem(withID id: String, quickResult: URLItemResult?, fullResult: URLItemResult?) {
        self.realmController.readItem(withID: id) { realmResult in
            // always call the quick result with the results of realm
            quickResult?(realmResult)
            
            switch realmResult {
            case .success:
                // if realm succeeds, just finish
                fullResult?(realmResult)
            case .error:
                // if realm errors, try getting the value from the cloud
                self.cloudKitController.readItem(withID: id, result: fullResult)
            }
            
        }
    }
    
    public func update(item: URLItemType, quickResult: URLItemResult?, fullResult: URLItemResult?) {
        self.realmController.update(item: item) { realmResult in
            // always call the quick result with the results of realm
            quickResult?(realmResult)
            
            switch realmResult {
            case .error:
                // if realm errors, call fullResult with the realmError
                fullResult?(realmResult)
            case .success(let updatedItem):
                // if realm is successful, continue to cloud controller
                self.cloudKitController.update(item: updatedItem, result: fullResult)
            }
        }
    }
    
    public func delete(item: URLItemType, quickResult: SuccessResult?, fullResult: SuccessResult?) {
        self.realmController.delete(item: item) { realmResult in
            // always call the quick result with the results of realm
            quickResult?(realmResult)
            
            switch realmResult {
            case .error:
                // if realm errors, call fullResult with the realmError
                fullResult?(realmResult)
            case .success:
                // if realm is successful, continue to cloud controller
                self.cloudKitController.delete(item: item, result: fullResult)
            }
        }
    }
}
