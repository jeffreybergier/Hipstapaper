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
        var idName: String
        var displayName: String
    }
    
    public class func normalize(_ nameString: String) -> String {
        let lowerCase = nameString.lowercased()
        let characterSet = CharacterSet.alphanumerics.inverted
        let trimmed = lowerCase.components(separatedBy: characterSet).joined(separator: "")
        if trimmed == "" { return "untitledtag" } else { return trimmed }
    }
    
    public dynamic var name = "Untitled Tag"
    public dynamic var normalizedNameHash: String = TagItem.normalize("Untitled Tag")
    public let items = LinkingObjects(fromType: URLItem.self, property: "tags")
    
    override public static func primaryKey() -> String {
        return "normalizedNameHash"
    }
}

// used to show the relationship between URLItems and TagItems in the UI
public enum CheckboxState: Int {
    case mixed = -1
    case off = 0
    case on = 1
    
    var boolValue: Bool {
        switch self {
        case .on, .mixed:
            return true
        case .off:
            return false
        }
    }
}
