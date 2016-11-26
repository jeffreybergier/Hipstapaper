//
//  URLItemCloudKitObject.swift
//  Hipstapaper
//
//  Created by Jeffrey Bergier on 11/25/16.
//  Copyright © 2016 Jeffrey Bergier. All rights reserved.
//

import CloudKit

extension URLItem {
    class CloudKitObject {
        
        let record: CKRecord
        
        var cloudKitID: String {
            return self.record.recordID.recordName
        }
        
        var urlString: String {
            get {
                return (self.record["urlString"] as? String) ?? "http://www.url.com"
            }
            set {
                let correctedString = String(urlStringFromRawString: newValue)
                self.record["urlString"] = correctedString as CKRecordValue
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
        
        var tags: Set<String> {
            get {
                return Set((self.record["tags"] as? [String]) ?? [])
            }
            set {
                self.record["tags"] = Array(newValue) as CKRecordValue
                self.modificationDate = Date()
            }
        }
        
        private let offlineModificationDate = Date()
        private var autoModificationDate: Date {
            get {
                return (self.record.modificationDate ?? self.record.creationDate) ?? self.offlineModificationDate
            }
        }
        var modificationDate: Date {
            get {
                return (self.record["manualDate"] as? Date) ?? self.autoModificationDate
            }
            set {
                self.record["manualDate"] = newValue as CKRecordValue
            }
        }
        
        init() {
            let newRecord = CKRecord(recordType: "URLItem")
            self.record = newRecord
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
            self.tags = Set(urlItem.tags.map({ $0.name }))
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
