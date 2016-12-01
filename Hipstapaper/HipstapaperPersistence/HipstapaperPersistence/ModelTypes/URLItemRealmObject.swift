//
//  URLItemRealmObject.swift
//  Hipstapaper
//
//  Created by Jeffrey Bergier on 11/25/16.
//  Copyright © 2016 Jeffrey Bergier. All rights reserved.
//

import RealmSwift

class URLItemRealmObject: Object, URLItemType {
    
    dynamic var realmID = UUID().uuidString
    dynamic var cloudKitID = UUID().uuidString
    dynamic var urlString = "http://www.url.com"
    dynamic var archived = false
    dynamic var modificationDate = Date()
    
    var tagList = List<TagItemRealmObject>()
    
    var tags: [TagItemType] {
        get {
            return Array(self.tagList.map({ TagItem.Value(name: $0.name) }))
        }
        set {
            fatalError("Cannot set tag list directly on a realm object without going through the controller")
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

extension URLItem.Value {
    init(realmObject: URLItemRealmObject) {
        self.init(
            realmID: realmObject.realmID,
            cloudKitID: realmObject.cloudKitID,
            urlString: realmObject.urlString,
            archived: realmObject.archived,
            tags: realmObject.tags,
            modificationDate: realmObject.modificationDate
        )
    }
}

