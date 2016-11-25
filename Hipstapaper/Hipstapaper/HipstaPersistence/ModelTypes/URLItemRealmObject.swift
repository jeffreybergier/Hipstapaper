//
//  URLItemRealmObject.swift
//  Hipstapaper
//
//  Created by Jeffrey Bergier on 11/25/16.
//  Copyright © 2016 Jeffrey Bergier. All rights reserved.
//

import RealmSwift

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

