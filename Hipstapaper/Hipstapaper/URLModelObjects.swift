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

extension URLItem {
    
    @objc(URLItemRealmObject)
    class RealmObject: Object {
        
        dynamic var id = UUID().uuidString
        dynamic var urlString = "http://www.url.com"
        dynamic var archived = false
        dynamic var modificationDate = Date()
        //var tags = List<TagItem.RealmObject>()
        
        // for some reason this is not inherited from the parent object
        static var defaultPropertyValues: NSDictionary? {
            return .none
        }
        
        override static func primaryKey() -> String {
            return "id"
        }
        
        convenience init(urlString: String) {
            self.init()
            self.urlString = urlString
        }
    }
}

//extension TagItem {
//    
//    @objc(TagItemRealmObject)
//    class RealmObject: Object {
//        
//        dynamic var name: String = ""
//        
//        convenience init(name: String) {
//            self.init()
//            self.name = name
//        }
//    }
//}


extension URLItem {
    
    @objc(URLItemBindingObject)
    class BindingObject: NSObject {
        
        var realmID: String
        var cloudKitID: String?
        
        var urlString: String {
            get {
                let realm = try! Realm()
                let realmObject = realm.object(ofType: URLItem.RealmObject.self, forPrimaryKey: self.realmID)!
                return realmObject.urlString
            }
            set {
                let realm = try! Realm()
                let realmObject = realm.object(ofType: URLItem.RealmObject.self, forPrimaryKey: self.realmID)!
                realm.beginWrite()
                realmObject.urlString = newValue
                realmObject.modificationDate = Date()
                try! realm.commitWrite()
            }
        }
        
        var modificationDate: Date {
            let realm = try! Realm()
            let realmObject = realm.object(ofType: URLItem.RealmObject.self, forPrimaryKey: self.realmID)!
            return realmObject.modificationDate
        }
        
        override init() {
            let realm = try! Realm()
            let realmObject = URLItem.RealmObject()
            realm.beginWrite()
            realm.add(realmObject)
            try! realm.commitWrite()
            self.realmID = realmObject.id
            super.init()
        }

        init(realmID: String) {
            self.realmID = realmID
            super.init()
        }
    }
}

extension URLItem {
    struct Value {
        var realmID: String
        var urlString: String
        var modificationDate: Date
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
