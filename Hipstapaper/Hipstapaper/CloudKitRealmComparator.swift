//
//  CloudKitRealmComparator.swift
//  Hipstapaper
//
//  Created by Jeffrey Bergier on 11/23/16.
//  Copyright © 2016 Jeffrey Bergier. All rights reserved.
//

import CloudKit
import RealmSwift

typealias CloudKitID = String

struct CloudKitRealmComparator {
    var addToCloud: [String]?
    var addToRealm: [URLItem.CloudKitObject]?
    var updateInCloud: [(realmID: String, cloudKitObject: URLItem.CloudKitObject)]?
    var updateInRealm: [(realmID: String, cloudKitObject: URLItem.CloudKitObject)]?
    
    init(realm: Results<URLItemRealmObject>, cloud: [URLItem.CloudKitObject]) {
        var addToCloud: [String] = []
        var addToRealm: [URLItem.CloudKitObject] = []
        var updateInCloud: [(realmID: String, cloudKitObject: URLItem.CloudKitObject)] = []
        var updateInRealm: [(realmID: String, cloudKitObject: URLItem.CloudKitObject)] = []
        
        for realmObject in realm {
            for cloudObject in cloud {
                if realmObject.cloudKitID == cloudObject.cloudKitID {
                    let match = type(of: self).match(lhs: realmObject, rhs: cloudObject)
                    if match == false {
                        let realmModificationDate = realmObject.modificationDate
                        let cloudModificationDate = cloudObject.modificationDate
                        if realmModificationDate > cloudModificationDate {
                            updateInCloud.append((realmObject.realmID, cloudObject))
                        } else {
                            updateInRealm.append((realmObject.realmID, cloudObject))
                        }
                    }
                }
            }
            if realmObject.cloudKitID == .none {
                addToCloud += [realmObject.realmID]
            }
        }
        
        for cloudObject in cloud {
            var matchingRealmObjects = 0
            for realmObject in realm {
                if let realmCloudKitID = realmObject.cloudKitID, realmCloudKitID == cloudObject.cloudKitID {
                    matchingRealmObjects += 1
                }
            }
            if matchingRealmObjects == 0 {
                addToRealm += [cloudObject]
            }
        }
        
        
        
        self.addToCloud = addToCloud.isEmpty == false ? addToCloud : .none
        self.addToRealm = addToRealm.isEmpty == false ? addToRealm : .none
        self.updateInCloud = updateInCloud.isEmpty == false ? updateInCloud : .none
        self.updateInRealm = updateInRealm.isEmpty == false ? updateInRealm : .none
    }
    
    private static func match(lhs: URLItemRealmObject, rhs: URLItem.CloudKitObject) -> Bool {
        guard lhs.urlString == rhs.urlString else { return false }
        let lhsTagSet = Set(lhs.tagList.map({$0.name}))
        guard lhs.archived == rhs.archived else { return false }
        let rhsTagSet = rhs.tags
        guard lhsTagSet.symmetricDifference(rhsTagSet).isEmpty == true else { return false }
        return true
    }
}


