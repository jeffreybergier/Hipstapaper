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

extension TagItem {
    @objc(TagItemRealmObject)
    class RealmObject: Object {
        
        dynamic var name: String = "Unknown"
        
        convenience init(name: String) {
            self.init()
            self.name = name
        }
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

extension URLItem {
    
    @objc(URLItemRealmObject)
    class RealmObject: Object, URLItemType {
        
        dynamic var realmID = UUID().uuidString
        dynamic var cloudKitID: String? = "NaN" // default value for now. NIL is not working 😫
        dynamic var urlString = "http://www.url.com"
        dynamic var archived = false
        dynamic var modificationDate = Date()
        var tagList = List<TagItem.RealmObject>()
        var tags: [TagItemType] {
            get {
                return Array(self.tagList.map({ TagItem.Value(name: $0.name) }))
            }
            set {
                let newObjects = List(newValue.map({ TagItem.RealmObject(name: $0.name) }))
                self.tagList = newObjects
            }
        }
        
        // for some reason this is not inherited from the parent object
        static var defaultPropertyValues: NSDictionary? {
            return .none
        }
        
        override static func primaryKey() -> String {
            return "realmID"
        }
        
        convenience init(urlString: String) {
            self.init()
            self.urlString = urlString
        }
    }
}

extension URLItem {
    
    @objc(URLItemBindingObject)
    class BindingObject: NSObject, URLItemType {
        
        var realmID: String
        var cloudKitID: String?
        
        var urlString: String {
            get {
                return URLRealmItemStorer.realmObject(with: self.realmID).urlString
            }
            set {
                URLRealmItemStorer.updateRealmObject(with: self.realmID) { object in
                    object.urlString = newValue
                }
            }
        }
        
        var modificationDate: Date {
            get {
                return URLRealmItemStorer.realmObject(with: self.realmID).modificationDate
            }
            set {
                URLRealmItemStorer.updateRealmObject(with: self.realmID) { object in
                    object.modificationDate = Date() // not actually needed because this is done by the class method
                }
            }
        }
        
        var archived: Bool {
            get {
                return URLRealmItemStorer.realmObject(with: self.realmID).archived
            }
            set {
                URLRealmItemStorer.updateRealmObject(with: self.realmID) { object in
                    object.archived = newValue
                }
            }
        }
        
        var tags: [TagItemType] {
            get {
                return URLRealmItemStorer.realmObject(with: self.realmID).tags
            }
            set {
                URLRealmItemStorer.updateRealmObject(with: self.realmID) { object in
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
        
        var id: String {
            return self.record.recordID.recordName
        }
        
        var urlString: String {
            get {
                return (self.record["urlString"] as? String) ?? "http://www.url.com"
            }
            set {
                let correctedString = String(urlStringFromRawString: newValue)
                self.record["urlString"] = correctedString as CKRecordValue
            }
        }
        
        private let offlineModificationDate = Date()
        var modificationDate: Date {
            return (self.record.modificationDate ?? self.record.creationDate) ?? self.offlineModificationDate
        }
        
        init(record: CKRecord) {
            precondition(record.recordType == "URLItem", "Not a URLItem Record")
            self.record = record
        }
    }
}
