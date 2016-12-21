//
//  URLItem.swift
//  Hipstapaper
//
//  Created by Jeffrey Bergier on 12/20/16.
//  Copyright © 2016 Jeffrey Bergier. All rights reserved.
//

import RealmSwift

final public class URLItem: Object {
    
    // MARK: Private Realm Properties
    
    dynamic private var iTitle = "Unknown Page"
    dynamic private var iURLString = "http://www.url.com"
    dynamic private var iArchived = false
    public dynamic var imageData: Data? // public because Cocoa and iOS need separate extensions to convert into their imeage formats
    
    // MARK: Realm Properties Access by outside world directly
    
    public var tags = List<TagItem>()
    dynamic public private(set) var uuid = UUID().uuidString
    dynamic public var modificationDate = Date()
    dynamic public private(set) var creationDate = Date()
    
    // MARK: Computed Properties used by outside world
    
    public var title: String {
        get {
            return self.iTitle
        }
        set {
            self.iTitle = newValue
            self.modificationDate = Date()
        }
    }
    
    public var urlString: String {
        get {
            return self.iURLString
        }
        set {
            self.iURLString = newValue
            self.modificationDate = Date()
        }
    }
    
    public var archived: Bool {
        get {
            return self.iArchived
        }
        set {
            self.iArchived = newValue
            self.modificationDate = Date()
        }
    }
    
    // MARK: Special Notations for Realm engine
    
    override public class func ignoredProperties() -> [String] {
        return ["image", "title", "archived", "urlString"]
    }
    
    override public static func primaryKey() -> String {
        return "uuid"
    }
    
}

extension URLItem {
    public enum Selection {
        case unarchived, all, tag(TagItem)
    }
    
    public enum SortOrder {
        
        case creationDate(newestFirst: Bool)
        case modificationDate(newestFirst: Bool)
        case pageTitle(aFirst: Bool)
        case urlString(aFirst: Bool)
        case tagCount(mostFirst: Bool)
        case archived(archivedFirst: Bool)
        
        var keyPath: String {
            switch self {
            case .creationDate:
                return "creationDate"
            case .modificationDate:
                return "modificationDate"
            case .pageTitle:
                return "iTitle"
            case .urlString:
                return "iURLString"
            case .tagCount:
                return "tags.count"
            case .archived:
                return "iArchived"
            }
        }
        
        private var ascending: Bool {
            switch self {
            case .creationDate(let newestFirst):
                return !newestFirst
            case .modificationDate(let newestFirst):
                return !newestFirst
            case .pageTitle(let aFirst):
                return !aFirst
            case .urlString(let aFirst):
                return !aFirst
            case .tagCount(let mostFirst):
                return !mostFirst
            case .archived(let archivedFirst):
                return archivedFirst
            }
        }
        
        func sort(results input: Results<URLItem>) -> Results<URLItem> {
            let keyPath = self.keyPath
            let ascending = self.ascending
            let output = input.sorted(byProperty: keyPath, ascending: ascending)
            return output
        }
        
        func sort(results input: LinkingObjects<URLItem>) -> Results<URLItem> {
            let keyPath = self.keyPath
            let ascending = self.ascending
            let output = input.sorted(byProperty: keyPath, ascending: ascending)
            return output
        }
    }
}
