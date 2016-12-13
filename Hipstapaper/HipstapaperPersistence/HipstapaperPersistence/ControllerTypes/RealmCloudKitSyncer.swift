//
//  RealmCloudKitSyncer.swift
//  Hipstapaper
//
//  Created by Jeffrey Bergier on 11/28/16.
//  Copyright © 2016 Jeffrey Bergier. All rights reserved.
//

import Foundation

typealias SyncSuccess = ((Result<SyncChanges>) -> Void)

enum SyncChanges {
    case changes, noChanges
}

class RealmCloudKitSyncer {
    
    private typealias URLItemResults = (([Result<URLItemType>]) -> Void)
    
    private let realmController: URLItemCRUDSinglePersistanceType
    private let cloudKitController: URLItemCRUDSinglePersistanceType
    private let originalSortedRealmIDs: [String]
    private let originalSortedCloudIDs: [String]
    
    // serial queue needed for all the local arrays I populate from all sorts of different callbacks
    // http://stackoverflow.com/questions/33512477/adding-to-array-in-parallel
    private let serialQueue = DispatchQueue(label: "RealmCloudKitSyncer", qos: .userInitiated)
    
    init(realmController: URLItemCRUDSinglePersistanceType, cloudKitController: URLItemCRUDSinglePersistanceType, sortedRealmIDs: [String], sortedCloudIDs: [String]) {
        self.realmController = realmController
        self.cloudKitController = cloudKitController
        self.originalSortedRealmIDs = sortedRealmIDs
        self.originalSortedCloudIDs = sortedCloudIDs
    }
    
    func sync(syncResult: SyncSuccess?) {
        self.step1ReadAllItems(finalCompletionHandler: syncResult)
    }
    
    private func step1ReadAllItems(finalCompletionHandler: SyncSuccess?) {
        self.serialQueue.async {
            let realmIDs = self.originalSortedRealmIDs
            let cloudIDs = self.originalSortedCloudIDs
            
            guard realmIDs.isEmpty == false || cloudIDs.isEmpty == false else {
                self.step7CallBack(allResults: [], syncChanges: .noChanges, finalCompletionHandler: finalCompletionHandler); return;
            }
            
            var realmResults = [Result<URLItemType>]()
            var cloudResults = [Result<URLItemType>]()
            
            for cloudID in cloudIDs {
                self.cloudKitController.readItem(withID: cloudID) { cloudResult in
                    self.serialQueue.async {
                        cloudResults.append(cloudResult)
                        if realmResults.count == realmIDs.count && cloudResults.count == cloudIDs.count {
                            self.step2ProcessChanges(realmResults: realmResults, cloudResults: cloudResults, finalCompletionHandler: finalCompletionHandler)
                        }
                    }
                }
            }
            for realmID in realmIDs {
                self.realmController.readItem(withID: realmID) { realmResult in
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
    
    private func step2ProcessChanges(realmResults: [Result<URLItemType>], cloudResults: [Result<URLItemType>], finalCompletionHandler: SyncSuccess?) {
        self.serialQueue.async {
            let (addToCloud, addToRealm, updateInCloud, updateInRealm) = type(of: self).diff(cloudItems: cloudResults.mapSuccess(), realmItems: realmResults.mapSuccess())
            
            var allResults = realmResults + cloudResults
            
            var finishedProcesses = 0 {
                didSet {
                    if finishedProcesses == 4 {
                        let changes: SyncChanges
                        if addToRealm.isEmpty == true && updateInRealm.isEmpty == true {
                            changes = .noChanges
                        } else {
                            changes = .changes
                        }
                        self.step7CallBack(allResults: [], syncChanges: changes, finalCompletionHandler: finalCompletionHandler);
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
        self.add(items: addToRealm, toStorage: self.realmController, resultsHandler: realmResults)
    }
    
    private func step4AddNewItemsToCloudKit(items addToCloud: [URLItemType], cloudResults: @escaping URLItemResults) {
        self.add(items: addToCloud, toStorage: self.cloudKitController, resultsHandler: cloudResults)
    }
    
    private func step5UpdateInRealm(items: [URLItemType], resultsHandler: @escaping URLItemResults) {
        self.update(items: items, in: self.realmController, resultsHandler: resultsHandler)
    }
    
    private func step6UpdateInCloudKit(items: [URLItemType], resultsHandler: @escaping URLItemResults) {
        self.update(items: items, in: self.cloudKitController, resultsHandler: resultsHandler)
    }
    
    private func step7CallBack(allResults: [Result<URLItemType>], syncChanges: SyncChanges, finalCompletionHandler: SyncSuccess?) {
        let errors = allResults.mapError()
        
        // wait 10 seconds to call back because cloudkit takes a second to update
        // at least I've noticed it has
        // and its easy to duplicate items if syncing happens twice really quickly
        DispatchQueue.main.async {
            Timer.scheduledTimer(withTimeInterval: 10, repeats: false) { _ in
                self.serialQueue.async {
                    if errors.isEmpty == true {
                        NSLog("Sync Succeeded: No Errors.")
                        finalCompletionHandler?(.success(syncChanges))
                    } else {
                        NSLog("Sync Errors: \(errors.count)\n\(errors)")
                        finalCompletionHandler?(.error(errors))
                    }
                }
            }
        }
    }
    
    private func update(items: [URLItemType], in storage: URLItemCRUDSinglePersistanceType, resultsHandler: @escaping URLItemResults) {
        var results = [Result<URLItemType>]() {
            didSet {
                if results.count == items.count {
                    resultsHandler(results)
                }
            }
        }
        for item in items {
            storage.update(item: item) { updateResult in
                results.append(updateResult)
            }
        }
    }
    
    private func add(items: [URLItemType], toStorage storage: URLItemCRUDSinglePersistanceType, resultsHandler: @escaping URLItemResults) {
        var results = [Result<URLItemType>]() {
            didSet {
                if results.count == items.count {
                    resultsHandler(results)
                }
            }
        }
        for unsavedItem in items {
            storage.create(item: unsavedItem) { createResult in
                results.append(createResult)
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
