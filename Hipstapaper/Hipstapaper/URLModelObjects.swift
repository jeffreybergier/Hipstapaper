//
//  URLModelObjects.swift
//  Hipstapaper
//
//  Created by Jeffrey Bergier on 11/21/16.
//  Copyright © 2016 Jeffrey Bergier. All rights reserved.
//

import RealmSwift
import CloudKit
import Foundation

protocol URLItemType {
    var realmID: String { get set }
    var cloudKitID: String? { get set }
    var urlString: String { get set }
    var archived: Bool { get set }
    var tags: [TagItemType] { get set }
    var modificationDate: Date { get set }
}

protocol TagItemType {
    var name: String { get set }
}

enum URLItem {
//    enum RealmObject {}
//    enum CloudKitObject {}
//    enum BindingObject {}
//    enum Value {}
}

enum TagItem {
//    enum RealmObject {}
//    enum Value {}
}

//extension TagItem { }
class TagItemRealmObject: Object, TagItemType {
    
    dynamic var name: String = "Unknown"
    
    convenience init(name: String) {
        self.init()
        self.name = name
    }
    
    override static func primaryKey() -> String {
        return "name"
    }
}

extension TagItem {
    struct Value: TagItemType {
        var name: String
    }
}

extension String: TagItemType {
    var name: String {
        get {
            return self
        }
        set {
            self = newValue
        }
    }
}

//extension URLItem {}

class URLItemRealmObject: Object {
    
    dynamic var realmID = UUID().uuidString
    dynamic var cloudKitID: String? = nil
    dynamic var urlString = "http://www.url.com"
    dynamic var archived = false
    dynamic var modificationDate = Date()
    var tagList = List<TagItemRealmObject>()
    var tags: [TagItemType] {
        get {
            return Array(self.tagList.map({ TagItem.Value(name: $0.name) }))
        }
        set {
            let newObjects = List(newValue.map({ TagItemRealmObject(name: $0.name) }))
            self.tagList = newObjects
        }
    }
    
    override static func primaryKey() -> String {
        return "realmID"
    }
    
    convenience init(urlString: String) {
        self.init()
        self.urlString = urlString
    }
}

extension URLItem {
    
    @objc(URLItemBindingObject)
    class BindingObject: NSObject, URLItemType {
        
        var realmID: String
        var cloudKitID: String?
        
        var urlString: String {
            get {
                return URLRealmItemStorer.realmObject(withID: self.realmID).urlString
            }
            set {
                URLRealmItemStorer.updateRealmObject(withID: self.realmID) { object in
                    object.urlString = newValue
                }
            }
        }
        
        var modificationDate: Date {
            get {
                return URLRealmItemStorer.realmObject(withID: self.realmID).modificationDate
            }
            set {
                URLRealmItemStorer.updateRealmObject(withID: self.realmID) { object in
                    object.modificationDate = Date() // not actually needed because this is done by the class method
                }
            }
        }
        
        var archived: Bool {
            get {
                return URLRealmItemStorer.realmObject(withID: self.realmID).archived
            }
            set {
                URLRealmItemStorer.updateRealmObject(withID: self.realmID) { object in
                    object.archived = newValue
                }
            }
        }
        
        var tags: [TagItemType] {
            get {
                return URLRealmItemStorer.realmObject(withID: self.realmID).tags
            }
            set {
                URLRealmItemStorer.updateRealmObject(withID: self.realmID) { object in
                    object.tags = newValue
                }
            }
        }
        
        override init() {
            self.realmID = URLRealmItemStorer.idForNewRealmObject()
            super.init()
        }

        init(realmID: String) {
            self.realmID = realmID
            super.init()
        }
    }
}

extension URLItem {
    struct Value: URLItemType {
        var realmID: String
        var cloudKitID: String?
        var urlString: String
        var archived: Bool
        var tags: [TagItemType]
        var modificationDate: Date
        
        init(realmID: String, cloudKitID: String? = .none, urlString: String, archived: Bool = false, tags: [TagItemType] = [], modificationDate: Date) {
            self.realmID = realmID
            self.cloudKitID = cloudKitID
            self.urlString = urlString
            self.archived = archived
            self.tags = tags
            self.modificationDate = modificationDate
        }
    }
}

extension URLItem.Value: Equatable {}
func ==(lhs: URLItem.Value, rhs: URLItem.Value) -> Bool {
    return lhs.realmID == rhs.realmID
}

extension URLItem.Value: Hashable {
    var hashValue: Int {
        return self.realmID.hashValue
    }
}

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
        
        init(record: CKRecord) {
            precondition(record.recordType == "URLItem", "Not a URLItem Record")
            self.record = record
        }
        
        init(realmValue: URLItemType) {
            let newRecord = CKRecord(recordType: "URLItem")
            self.record = newRecord
            self.urlString = realmValue.urlString
            self.modificationDate = realmValue.modificationDate
            self.tags = Set(realmValue.tags.map({ $0.name }))
            self.archived = realmValue.archived
        }
    }
}
