//
//  RealmCloudKitSyncer.swift
//  Hipstapaper
//
//  Created by Jeffrey Bergier on 11/28/16.
//  Copyright © 2016 Jeffrey Bergier. All rights reserved.
//

class RealmCloudKitSyncer {
    
    private let realmController: SyncingPersistenceType
    private let cloudKitController: SyncingPersistenceType
    
    init(realmController: SyncingPersistenceType, cloudKitController: SyncingPersistenceType) {
        self.realmController = realmController
        self.cloudKitController = cloudKitController
    }
    
    func sync(syncResult: @escaping SuccessResult) {
        self.step1ReadAllItems(finalCompletionHandler: syncResult)
    }
    
    private func step1ReadAllItems(finalCompletionHandler: @escaping SuccessResult) {
        let realmIDs = self.realmController.ids
        let cloudIDs = self.cloudKitController.ids
        
        guard realmIDs.isEmpty == false || cloudIDs.isEmpty == false else { finalCompletionHandler(.success()); return; }
        
        var realmResults = [Result<URLItemType>]()
        var cloudResults = [Result<URLItemType>]()
        
        for cloudID in cloudIDs {
            self.cloudKitController.readItem(withID: cloudID, quickResult: { _ in }) { cloudResult in
                cloudResults.append(cloudResult)
                if realmResults.count == realmIDs.count && cloudResults.count == cloudIDs.count {
                    self.step2ProcessChanges(realmResults: realmResults, cloudResults: cloudResults, finalCompletionHandler: finalCompletionHandler)
                }
            }
        }
        for realmID in realmIDs {
            self.realmController.readItem(withID: realmID, quickResult: { _ in }) { realmResult in
                realmResults.append(realmResult)
                if realmResults.count == realmIDs.count && cloudResults.count == cloudIDs.count {
                    self.step2ProcessChanges(realmResults: realmResults, cloudResults: cloudResults, finalCompletionHandler: finalCompletionHandler)
                }
            }
        }
    }
    
    private func step2ProcessChanges(realmResults: [Result<URLItemType>], cloudResults: [Result<URLItemType>], finalCompletionHandler: @escaping SuccessResult) {
        let (addToCloud, addToRealm, updateInCloud, updateInRealm) = self.compare(cloudItems: cloudResults.mapSuccess(), realmItems: realmResults.mapSuccess())
        
        var finishedProcesses = 0 {
            didSet {
                if finishedProcesses == 4 {
                    finalCompletionHandler(.success())
                }
            }
        }
        
        if addToRealm.isEmpty == false {
            self.step3AddNewItemsToRealm(items: addToRealm) { addToRealmResults in
                finishedProcesses += 1
            }
        } else {
            finishedProcesses += 1
        }
        
        if addToCloud.isEmpty == false {
            self.step4AddNewItemsToCloudKit(items: addToCloud) { addToCloudResults in
                finishedProcesses += 1
            }
        } else {
            finishedProcesses += 1
        }
        
        if updateInRealm.isEmpty == false {
            self.step5UpdateInRealm(items: updateInRealm) { updateInRealmResults in
                finishedProcesses += 1
            }
        } else {
            finishedProcesses += 1
        }
        
        if updateInCloud.isEmpty == false {
            self.step6UpdateInCloudKit(items: updateInCloud) { updateInCloudResults in
                finishedProcesses += 1
            }
        } else {
            finishedProcesses += 1
        }
    }
    
    private func step3AddNewItemsToRealm(items addToRealm: [URLItemType], realmResults: @escaping URLItemResults) {
        self.addAndUpdate(items: addToRealm, property: .realm, to: self.realmController, resultsHandler: realmResults)
    }
    
    private func step4AddNewItemsToCloudKit(items addToCloud: [URLItemType], cloudResults: @escaping URLItemResults) {
        self.addAndUpdate(items: addToCloud, property: .cloud, to: self.cloudKitController, resultsHandler: cloudResults)
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
            storage.update(item: item, quickResult: { _ in }) { updateResult in
                results.append(updateResult)
            }
        }
    }
    
    private func addAndUpdate(items: [URLItemType], property: Property, to storage: SyncingPersistenceType, resultsHandler: @escaping URLItemResults) {
        var results = [Result<URLItemType>]() {
            didSet {
                if results.count == items.count {
                    resultsHandler(results)
                }
            }
        }
        for unsavedItem in items {
            let id: String
            switch property {
            case .cloud:
                id = unsavedItem.cloudKitID
            case .realm:
                id = unsavedItem.realmID
            }
            storage.createItem(withID: id, quickResult: { _ in }) { createResult in
                if case .success = createResult {
                    storage.update(item: unsavedItem, quickResult: { _ in }) { updateResult in
                        results.append(updateResult)
                    }
                } else {
                    results.append(createResult)
                }
            }
        }

    }
    
    private func compare(cloudItems: [URLItemType], realmItems: [URLItemType])
        -> (addToCloud: [URLItemType], addToRealm: [URLItemType], updateInCloud: [URLItemType], updateInRealm: [URLItemType])
    {
        var addToCloud = [URLItemType]()
        var addToRealm = [URLItemType]()
        var updateInCloud = [URLItemType]()
        var updateInRealm = [URLItemType]() // need to add info here so I know the original realm object
        
        for realmItem in realmItems {
            let matchingCloudItems = cloudItems.filter({ realmItem.cloudKitID == $0.cloudKitID })
            if matchingCloudItems.isEmpty == true {
                addToCloud.append(realmItem)
            } else {
                matchingCloudItems.forEach() { cloudItem in
                    switch realmItem.compareTo(other: cloudItem) {
                    case .newer:
                        updateInCloud.append(realmItem)
                    case .older:
                        updateInRealm.append(cloudItem)
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
    
    private enum Property {
        case cloud, realm
    }
}

enum URLItemComparison {
    case newer, older, same, notApplicable
}

extension URLItemType {
    func compareTo(other: URLItemType) -> URLItemComparison {
        guard self.cloudKitID == other.cloudKitID else { return .notApplicable }
        if self.urlString != other.urlString || self.archived != other.archived || self.tags.map({$0.name}) != other.tags.map({$0.name}) {
            if self.modificationDate >= other.modificationDate {
                return .newer
            } else {
                return .older
            }
        } else {
            return .same
        }
    }
}

extension Sequence where Iterator.Element == Result<URLItemType> {
    func mapSuccess() -> [URLItemType] {
        let items = self.map() { result -> URLItemType? in
            if case .success(let item) = result {
                return item
            }
            return .none
        }.filter({ $0 != nil }).map({ $0! })
        return items
    }
}
