//
//  TagItemRealmObject.swift
//  Hipstapaper
//
//  Created by Jeffrey Bergier on 11/25/16.
//  Copyright © 2016 Jeffrey Bergier. All rights reserved.
//

import RealmSwift

class TagItemRealmObject: Object, TagItemType {
    
    dynamic var name: String = "Unknown"
    let items = LinkingObjects(fromType: URLItemRealmObject.self, property: "tagList")
    
    var itemCount: Int {
        return self.items.count
    }
    
    convenience init(name: String) {
        self.init()
        self.name = name
    }
    
    override static func primaryKey() -> String {
        return "name"
    }
}
