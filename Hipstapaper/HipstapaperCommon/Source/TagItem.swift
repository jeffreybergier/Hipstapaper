//
//  TagItem.swift
//  Hipstapaper
//
//  Created by Jeffrey Bergier on 12/21/16.
//  Copyright © 2016 Jeffrey Bergier. All rights reserved.
//

import RealmSwift

final public class TagItem: Object {
    
    public struct UIIdentifier {
        public var idName: String
        public var displayName: String
        
        public init(idName: String, displayName: String) {
            self.idName = idName
            self.displayName = displayName
        }
    }
    
    public class func normalize(_ nameString: String) -> String {
        let lowerCase = nameString.lowercased()
        let characterSet = CharacterSet.alphanumerics.inverted
        let trimmed = lowerCase.components(separatedBy: characterSet).joined(separator: "")
        if trimmed == "" { return "untitledtag" } else { return trimmed }
    }
    
    public internal(set) dynamic var name = "Untitled Tag"
    public internal(set) dynamic var normalizedNameHash: String = TagItem.normalize("Untitled Tag")
    public let items = LinkingObjects(fromType: URLItem.self, property: "tags")
    
    override public static func primaryKey() -> String {
        // return #keyPath(self.normalizedNameHash) // Argument of '#keyPath' refers to non-'@objc' property 'self'
        return "normalizedNameHash"
    }
}
