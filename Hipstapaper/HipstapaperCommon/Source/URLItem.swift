//
//  URLItem.swift
//  Hipstapaper
//
//  Created by Jeffrey Bergier on 12/20/16.
//  Copyright © 2016 Jeffrey Bergier. All rights reserved.
//

import RealmSwift

final public class URLItem: Object {
    
    // MARK: All the Properties
    
    @objc public internal(set) dynamic var uuid = UUID().uuidString
    @objc public internal(set) dynamic var urlString = "http://www.url.com"
    @objc public internal(set) dynamic var archived = false
    @objc public internal(set) dynamic var extras: URLItemExtras?
    @objc public internal(set) dynamic var creationDate = Date()
    @objc public internal(set) dynamic var modificationDate = Date()
    public internal(set) var tags = List<TagItem>()
    
    override public static func primaryKey() -> String {
        return #keyPath(URLItem.uuid)
    }
}
