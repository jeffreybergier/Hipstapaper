//
//  TagItem.swift
//  Hipstapaper
//
//  Created by Jeffrey Bergier on 12/21/16.
//  Copyright © 2016 Jeffrey Bergier. All rights reserved.
//

import RealmSwift

final public class TagItem: Object {
    
    class func normalize(nameString: String) -> String? {
        let lowerCase = nameString.lowercased()
        let characterSet = CharacterSet.alphanumerics.inverted
        let trimmed = lowerCase.components(separatedBy: characterSet).joined(separator: "")
        if trimmed == "" { return .none } else { return trimmed }
    }
    
    dynamic var name = "untitled"
    
    let items = LinkingObjects(fromType: URLItem.self, property: "tags")
    
    //    override public class func ignoredProperties() -> [String] {
    //        return ["name"]
    //    }
    
}
