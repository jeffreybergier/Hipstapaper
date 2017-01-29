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
    
    public internal(set) dynamic var uuid = UUID().uuidString
    public internal(set) dynamic var urlString = "http://www.url.com"
    public internal(set) dynamic var archived = false
    public internal(set) dynamic var extras: URLItemExtras?
    public internal(set) var tags = List<TagItem>()
    public internal(set) dynamic var creationDate = Date()
    public internal(set) dynamic var modificationDate = Date()
    
    override public static func primaryKey() -> String {
        //return #keyPath(self.uuid) // Argument of '#keyPath' refers to non-'@objc' property 'self'
        return "uuid"
    }
    
}









