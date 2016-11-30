//
//  URLItemCloudKitObject.swift
//  Hipstapaper
//
//  Created by Jeffrey Bergier on 11/25/16.
//  Copyright © 2016 Jeffrey Bergier. All rights reserved.
//

import CloudKit

extension URLItem {
    class CloudKitObject: URLItemType {
        
        let record: CKRecord
        
        var realmID: String {
            get {
                fatalError("tried to get or set realm ID from cloudkit object")
            }
            set {
                fatalError("tried to get or set realm ID from cloudkit object")
            }
        }
        
        var cloudKitID: String {
            get {
                if let id = self.record["cloudKitID"] as? String {
                    return id
                } else {
                    let newID = UUID().uuidString
                    self.record["cloudKitID"] = newID as CKRecordValue
                    return newID
                }
            }
            set {
                self.record["cloudKitID"] = newValue as CKRecordValue
                self.modificationDate = Date()
            }
        }
        
        var urlString: String {
            get {
                return (self.record["urlString"] as? String) ?? "http://www.url.com"
            }
            set {
                self.record["urlString"] = newValue as CKRecordValue
                self.modificationDate = Date()
            }
        }
        
        var archived: Bool {
            get {
                return (self.record["archived"] as? Bool) ?? false
            }
            set {
                self.record["archived"] = newValue as CKRecordValue
                self.modificationDate = Date()
            }
        }
        
        var tags: [TagItemType] {
            get {
                return (self.record["tags"] as? [String]) ?? []
            }
            set {
                let newSet = Set(newValue.map({ $0.name }))
                self.record["tags"] = Array(newSet) as CKRecordValue
                self.modificationDate = Date()
            }
        }
        
        var modificationDate: Date {
            get {
                if let date = self.record["manualDate"] as? Date {
                    return date
                } else {
                    let newDate = Date()
                    self.record["manualDate"] = newDate as CKRecordValue
                    return newDate
                }
            }
            set {
                self.record["manualDate"] = newValue as CKRecordValue
            }
        }
        
        init() {
            let newRecord = CKRecord(recordType: "URLItem")
            self.record = newRecord
            self.cloudKitID = UUID().uuidString
            self.modificationDate = Date()
        }
        
        init(record: CKRecord) {
            precondition(record.recordType == "URLItem", "Not a URLItem Record")
            self.record = record
        }
        
        init(urlItem: URLItemType) {
            let newRecord = CKRecord(recordType: "URLItem")
            self.record = newRecord
            self.urlString = urlItem.urlString
            self.modificationDate = urlItem.modificationDate
            self.tags = urlItem.tags
            self.archived = urlItem.archived
        }
    }
}

extension URLItem.Value {
    init(cloudKitObject: URLItem.CloudKitObject) {
        self.init(
            realmID: UUID().uuidString, // fix this
            cloudKitID: cloudKitObject.cloudKitID,
            urlString: cloudKitObject.urlString,
            archived: cloudKitObject.archived,
            tags: Array(cloudKitObject.tags),
            modificationDate: cloudKitObject.modificationDate
        )
    }
}

extension URLItem.CloudKitObject: Equatable {}
func ==(lhs: URLItem.CloudKitObject, rhs: URLItem.CloudKitObject) -> Bool {
    return lhs.cloudKitID == rhs.cloudKitID
}

extension URLItem.CloudKitObject: Hashable {
    var hashValue: Int {
        return self.cloudKitID.hashValue
    }
}
