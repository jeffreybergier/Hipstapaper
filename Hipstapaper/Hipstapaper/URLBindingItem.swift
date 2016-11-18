//
//  URLItem.swift
//  Hipstapaper
//
//  Created by Jeffrey Bergier on 11/12/16.
//  Copyright © 2016 Jeffrey Bergier. All rights reserved.
//

import CloudKit

protocol URLItemChangeDelegate: class {
    func itemDidChange(_: URLBindingItem)
}

@objc(URLBindingItem)
class URLBindingItem: NSObject {
    
    let record: CKRecord
    
    var id: String {
        return self.record.recordID.recordName
    }
    
    var urlString: String {
        get {
            return (self.record["urlString"] as? String) ?? "www.url.com"
        }
        set {
            let correctedString = String(urlStringFromRawString: newValue)
            self.record["urlString"] = correctedString as CKRecordValue
            self.changeDelegate?.itemDidChange(self)
        }
    }
    
    private let offlineModificationDate = Date()
    var modificationDate: Date {
        return (self.record.modificationDate ?? self.record.creationDate) ?? self.offlineModificationDate
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

extension URLBindingItem /*Hashable*/ {
    override var hashValue: Int {
        return self.id.hashValue
    }
}

extension URLBindingItem /*Equatable*/ {}
func ==(lhs: URLBindingItem, rhs: URLBindingItem) -> Bool {
    return lhs.hashValue == rhs.hashValue
}

extension URLBindingItem /*ContentsDiffer*/ {
    func contentsDiffer(from otherItem: URLBindingItem) -> Bool {
        return self.urlString != otherItem.urlString
    }
}

extension URLBindingItem /*CustomStringConvertible*/ {
    override var description: String {
        return super.description + " \(self.urlString)"
    }
}
