//
//  RealmCloudKitSyncer.swift
//  Hipstapaper
//
//  Created by Jeffrey Bergier on 11/28/16.
//  Copyright © 2016 Jeffrey Bergier. All rights reserved.
//

import Foundation

typealias URLItemResults = (([Result<URLItemType>]) -> Void)

class RealmCloudKitSyncer {
    
    private let realmController: SyncingPersistenceType
    private let cloudKitController: SyncingPersistenceType
    
    // serial queue needed for all the local arrays I populate from all sorts of different callbacks
    // http://stackoverflow.com/questions/33512477/adding-to-array-in-parallel
    private let serialQueue = DispatchQueue(label: "RealmCloudKitSyncer", qos: .userInitiated)
    
    init(realmController: SyncingPersistenceType, cloudKitController: SyncingPersistenceType) {
        self.realmController = realmController
        self.cloudKitController = cloudKitController
    }
    
    func sync(syncResult: SuccessResult?) {
        self.step1ReadAllItems(finalCompletionHandler: syncResult)
    }
    
    private func step1ReadAllItems(finalCompletionHandler: SuccessResult?) {
        self.serialQueue.async {
            let realmIDs = self.realmController.ids
            let cloudIDs = self.cloudKitController.ids
            
            guard realmIDs.isEmpty == false || cloudIDs.isEmpty == false else { finalCompletionHandler?(.success()); return; }
            
            var realmResults = [Result<URLItemType>]()
            var cloudResults = [Result<URLItemType>]()
            
            for cloudID in cloudIDs {
                self.cloudKitController.readItem(withID: cloudID, quickResult: .none) { cloudResult in
                    self.serialQueue.async {
                        cloudResults.append(cloudResult)
                        if realmResults.count == realmIDs.count && cloudResults.count == cloudIDs.count {
                            self.step2ProcessChanges(realmResults: realmResults, cloudResults: cloudResults, finalCompletionHandler: finalCompletionHandler)
                        }
                    }
                }
            }
            for realmID in realmIDs {
                self.realmController.readItem(withID: realmID, quickResult: .none) { realmResult in
                    self.serialQueue.async {
                        realmResults.append(realmResult)
                        if realmResults.count == realmIDs.count && cloudResults.count == cloudIDs.count {
                            self.step2ProcessChanges(realmResults: realmResults, cloudResults: cloudResults, finalCompletionHandler: finalCompletionHandler)
                        }
                    }
                }
            }
        }
    }
    
    private func step2ProcessChanges(realmResults: [Result<URLItemType>], cloudResults: [Result<URLItemType>], finalCompletionHandler: SuccessResult?) {
        self.serialQueue.async {
            let (addToCloud, addToRealm, updateInCloud, updateInRealm) = type(of: self).diff(cloudItems: cloudResults.mapSuccess(), realmItems: realmResults.mapSuccess())
            
            var allResults = realmResults + cloudResults
            
            var finishedProcesses = 0 {
                didSet {
                    if finishedProcesses == 4 {
                        let errors = allResults.mapError()
                        if errors.isEmpty == true {
                            NSLog("Sync Succeeded: No Errors.")
                            finalCompletionHandler?(.success())
                        } else {
                            NSLog("Sync Errors: \(errors.count)\n\(errors)")
                            finalCompletionHandler?(.error(errors))
                        }
                    }
                }
            }
            
            if addToRealm.isEmpty == false {
                self.step3AddNewItemsToRealm(items: addToRealm) { results in
                    self.serialQueue.async {
                        allResults += results
                        finishedProcesses += 1
                    }
                }
            } else {
                finishedProcesses += 1
            }
            
            if addToCloud.isEmpty == false {
                self.step4AddNewItemsToCloudKit(items: addToCloud) { results in
                    self.serialQueue.async {
                        allResults += results
                        finishedProcesses += 1
                    }
                }
            } else {
                finishedProcesses += 1
            }
            
            if updateInRealm.isEmpty == false {
                self.step5UpdateInRealm(items: updateInRealm) { results in
                    self.serialQueue.async {
                        allResults += results
                        finishedProcesses += 1
                    }
                }
            } else {
                finishedProcesses += 1
            }
            
            if updateInCloud.isEmpty == false {
                self.step6UpdateInCloudKit(items: updateInCloud) { results in
                    self.serialQueue.async {
                        allResults += results
                        finishedProcesses += 1
                    }
                }
            } else {
                finishedProcesses += 1
            }
        }
    }
    
    private func step3AddNewItemsToRealm(items addToRealm: [URLItemType], realmResults: @escaping URLItemResults) {
        self.add(items: addToRealm, toStorage: .realm(self.realmController), resultsHandler: realmResults)
    }
    
    private func step4AddNewItemsToCloudKit(items addToCloud: [URLItemType], cloudResults: @escaping URLItemResults) {
        self.add(items: addToCloud, toStorage: .cloud(self.cloudKitController), resultsHandler: cloudResults)
    }
    
    private func step5UpdateInRealm(items: [URLItemType], resultsHandler: @escaping URLItemResults) {
        self.update(items: items, in: self.realmController, resultsHandler: resultsHandler)
    }
    
    private func step6UpdateInCloudKit(items: [URLItemType], resultsHandler: @escaping URLItemResults) {
        self.update(items: items, in: self.cloudKitController, resultsHandler: resultsHandler)
    }
    
    private func update(items: [URLItemType], in storage: SyncingPersistenceType, resultsHandler: @escaping URLItemResults) {
        var results = [Result<URLItemType>]() {
            didSet {
                if results.count == items.count {
                    resultsHandler(results)
                }
            }
        }
        for item in items {
            storage.update(item: item, quickResult: .none) { updateResult in
                results.append(updateResult)
            }
        }
    }
    
    private enum Location {
        case cloud(SyncingPersistenceType), realm(SyncingPersistenceType)
    }
    
    private func add(items: [URLItemType], toStorage location: Location, resultsHandler: @escaping URLItemResults) {
        var results = [Result<URLItemType>]() {
            didSet {
                if results.count == items.count {
                    resultsHandler(results)
                }
            }
        }
        for unsavedItem in items {
            let id: String
            let storage: SyncingPersistenceType
            switch location {
            case .cloud(let cloudController):
                id = unsavedItem.cloudKitID
                storage = cloudController
            case .realm(let realmController):
                id = unsavedItem.realmID
                storage = realmController
            }
            storage.createItem(withID: id, quickResult: .none) { createResult in
                if case .success = createResult {
                    storage.update(item: unsavedItem, quickResult: .none) { updateResult in
                        results.append(updateResult)
                    }
                } else {
                    results.append(createResult)
                }
            }
        }

    }
    
    private class func diff(cloudItems: [URLItemType], realmItems: [URLItemType])
        -> (addToCloud: [URLItemType], addToRealm: [URLItemType], updateInCloud: [URLItemType], updateInRealm: [URLItemType]) {
        var addToCloud = [URLItemType]()
        var addToRealm = [URLItemType]()
        var updateInCloud = [URLItemType]()
        var updateInRealm = [URLItemType]()
        
        for realmItem in realmItems {
            let matchingCloudItems = cloudItems.filter({ realmItem.cloudKitID == $0.cloudKitID })
            if matchingCloudItems.isEmpty == true {
                addToCloud.append(realmItem)
            } else {
                matchingCloudItems.forEach() { cloudItem in
                    switch realmItem.compare(with: cloudItem) {
                    case .newer:
                        updateInCloud.append(realmItem)
                    case .older:
                        // the cloud item has no notion of the realm object
                        // so the realmID in the clouditem is fake
                        // so we need to set the realmID of the cloud item to its matching realmObject
                        var mCloudItem = cloudItem
                        mCloudItem.realmID = realmItem.realmID
                        updateInRealm.append(mCloudItem)
                    case .same, .notApplicable:
                        break
                    }
                }
            }
        }
        
        for cloudItem in cloudItems {
            let matchingRealmItems = realmItems.filter({ cloudItem.cloudKitID == $0.cloudKitID })
            if matchingRealmItems.isEmpty == true {
                addToRealm.append(cloudItem)
            }
        }
        return (addToCloud: addToCloud, addToRealm: addToRealm, updateInCloud: updateInCloud, updateInRealm: updateInRealm)
    }
}
