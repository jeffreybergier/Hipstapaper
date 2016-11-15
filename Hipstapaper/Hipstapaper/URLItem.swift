//
//  URLItem.swift
//  Hipstapaper
//
//  Created by Jeffrey Bergier on 11/12/16.
//  Copyright © 2016 Jeffrey Bergier. All rights reserved.
//

import CloudKit

protocol URLItemChangeDelegate: class {
    func itemDidChange(_: URLItem)
}

@objc(URLItem)
class URLItem: NSObject {
    
    let record: CKRecord
    
    var id: String {
        return self.record.recordID.recordName
    }
    
    var urlString: String {
        get {
            return (self.record["urlString"] as? String) ?? "www.url.com"
        }
        set {
            self.record["urlString"] = newValue as CKRecordValue
            self.changeDelegate?.itemDidChange(self)
        }
    }
    
    private let offlineCreationDate = Date() // needed until records are saved to the server
    var modifiedDate: Date {
        return (self.record.modificationDate ?? self.record.creationDate) ?? self.offlineCreationDate
    }
    
    weak var changeDelegate: URLItemChangeDelegate?
    
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

extension URLItem /*Hashable*/ {
    override var hashValue: Int {
        return self.id.hashValue
    }
}

extension URLItem /*Equatable*/ {}
func ==(lhs: URLItem, rhs: URLItem) -> Bool {
    return lhs.hashValue == rhs.hashValue
}

extension URLItem /*ContentsDiffer*/ {
    func contentsDiffer(from otherItem: URLItem) -> Bool {
        return self.urlString != otherItem.urlString
    }
}

extension URLItem /*CustomStringConvertible*/ {
    override var description: String {
        return super.description + " \(self.urlString)"
    }
}
