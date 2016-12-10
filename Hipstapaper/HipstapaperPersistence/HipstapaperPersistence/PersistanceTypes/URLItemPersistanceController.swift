//
//  CombinedURLItemSyncingController.swift
//  Hipstapaper
//
//  Created by Jeffrey Bergier on 11/26/16.
//  Copyright © 2016 Jeffrey Bergier. All rights reserved.
//

open class URLItemPersistanceController {
    
    fileprivate let realmController: URLItemCRUDSinglePersistanceType = URLItemRealmController()
    fileprivate let cloudKitController: URLItemCRUDSinglePersistanceType = URLItemCloudKitController()
    
    public init() {}
    
}

extension URLItemPersistanceController: URLItemCRUDDoublePersistanceType {

    // ugh this is pretty bad pyramid of doom
    // it basically just calls back the completion handlers on error
    // if there is success it keeps going forward with the syncing process
    public func sync(sortedBy: URLItem.Sort, ascending: Bool, quickResult: URLItemIDsResult?, fullResult: URLItemIDsResult?) {
        self.realmController.reloadData(sortedBy: sortedBy, ascending: ascending) { realmResult in
            // always call the quick result with the results of realm
            quickResult?(realmResult)
            
            switch realmResult {
            case .error:
                // if realm errors, also call fullResult with the realmError
                fullResult?(realmResult)
            case .success(let sortedRealmIDs):
                // if realm is successful, continue to cloud controller
                self.cloudKitController.reloadData(sortedBy: sortedBy, ascending: ascending) { cloudResult in
                    switch cloudResult {
                    case .error:
                        // if cloud errors, call fullResult with the cloudError
                        fullResult?(cloudResult)
                    case .success(let sortedCloudIDs):
                        // now the cloud sync and the realm sync were both successful, time to sync
                        let syncer = RealmCloudKitSyncer(realmController: self.realmController, cloudKitController: self.cloudKitController, sortedRealmIDs: sortedRealmIDs, sortedCloudIDs: sortedCloudIDs)

                        // call to sync with the full completion handler
                        syncer.sync() { syncResult in
                            switch syncResult {
                            case .error(let errors):
                                // if there is an error syncing, call back
                                fullResult?(.error(errors))
                            case .success(let changes):
                                // if we are successful, we need to know if there are changes
                                switch changes {
                                case .noChanges:
                                    // if there are no changes, call back
                                    fullResult?(realmResult)
                                case .changes:
                                    // if there are changes, recurse
                                    self.sync(sortedBy: sortedBy, ascending: ascending, quickResult: .none, fullResult: fullResult)
                                }
                            }
                        }
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
                self.cloudKitController.createItem(withID: realmValue.cloudKitID) { cloudCreateResult in
                    let updatedResult = type(of: self).update(cloudItemResult: cloudCreateResult, withRealmItemID: realmValue.realmID)
                    fullResult?(updatedResult)
                }
            }
        }
    }
    
    public func create(item: URLItemType?, quickResult: URLItemResult?, fullResult: URLItemResult?) {
        // always call the quick result with the results of realm
        self.realmController.create(item: item) { realmResult in
            // always call the quick result with the results of realm
            quickResult?(realmResult)
            switch realmResult {
            case .error:
                // if realm errors, call fullResult with the realmError
                fullResult?(realmResult)
            case .success(let realmValue):
                // if realm is successful, continue to cloud controller
                self.cloudKitController.create(item: realmValue) { cloudCreateResult in
                    let updatedResult = type(of: self).update(cloudItemResult: cloudCreateResult, withRealmItemID: realmValue.realmID)
                    fullResult?(updatedResult)
                }
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
                self.cloudKitController.readItem(withID: id) { cloudReadResult in
                    let updatedResult = type(of: self).update(cloudItemResult: cloudReadResult, withRealmItemID: id)
                    fullResult?(updatedResult)
                }
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
                self.cloudKitController.update(item: updatedItem) { cloudUpdateResult in
                    let updatedResult = type(of: self).update(cloudItemResult: cloudUpdateResult, withRealmItemID: item.realmID)
                    fullResult?(updatedResult)
                }
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
    
    private class func update(cloudItemResult: Result<URLItemType>, withRealmItemID realmID: String) -> Result<URLItemType> {
        // since cloud results don't have a real realm ID, we need to add the realm realm ID before returning it to the app
        switch cloudItemResult {
        case .success(var cloudItem):
            cloudItem.realmID = realmID
            return .success(cloudItem)
        case .error:
            return cloudItemResult
        }
    }
}
