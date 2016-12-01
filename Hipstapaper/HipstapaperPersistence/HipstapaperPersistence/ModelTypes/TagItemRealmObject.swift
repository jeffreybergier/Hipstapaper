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
    
    convenience init(name: String) {
        self.init()
        self.name = name
    }
    
    override static func primaryKey() -> String {
        return "name"
    }
}
