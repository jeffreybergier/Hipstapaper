//
//  URLItem.swift
//  Hipstapaper
//
//  Created by Jeffrey Bergier on 11/12/16.
//  Copyright © 2016 Jeffrey Bergier. All rights reserved.
//

import CloudKit

@objc(URLItem)
class URLItem: NSObject {
    
    private let record: CKRecord
    
    var id: String {
        return self.record.recordID.recordName
    }
    
    var urlString: String {
        get {
            return (self.record["urlString"] as? String) ?? "www.url.com"
        }
        set {
            self.record["urlString"] = newValue as CKRecordValue
        }
    }
    
    private let offlineCreationDate = Date() // needed until records are saved to the server
    var modifiedDate: Date {
        return (self.record.modificationDate ?? self.record.creationDate) ?? self.offlineCreationDate
    }
    
    override init() {
        self.record = CKRecord(recordType: "URLItem")
        super.init()
    }
    
    convenience init(urlString: String) {
        self.init()
        self.urlString = urlString
    }
    
    init(record: CKRecord) {
        if record.recordType == "URLItem" {
            self.record = record
            super.init()
        } else {
            fatalError("Not a URLItem Record")
        }
    }
}
