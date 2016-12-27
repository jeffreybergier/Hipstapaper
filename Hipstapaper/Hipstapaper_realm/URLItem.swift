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
    
    public private(set) dynamic var uuid = UUID().uuidString
    public dynamic var urlString = "http://www.url.com"
    public dynamic var archived = false
    public dynamic var extras: URLItemExtras?
    public var tags = List<TagItem>()
    public dynamic var creationDate = Date()
    public dynamic var modificationDate = Date()
    
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
//        case pageTitle(aFirst: Bool) // sorting on key paths not possible yet
//        case tagCount(mostFirst: Bool) // sorting on key paths not possible yet
        case urlString(aFirst: Bool)
        case archived(archivedFirst: Bool)
        
        var keyPath: String {
            switch self {
            case .creationDate:
                return #keyPath(URLItem.creationDate)
            case .modificationDate:
                return #keyPath(URLItem.modificationDate)
//            case .pageTitle:
//                return #keyPath(URLItem.extras.pageTitle)
            case .urlString:
                return #keyPath(URLItem.urlString)
//            case .tagCount:
//                return "tags.count" //#keyPath(URLItem.tags.count)
            case .archived:
                return #keyPath(URLItem.archived)
            }
        }
        
        private var ascending: Bool {
            switch self {
            case .creationDate(let newestFirst):
                return !newestFirst
            case .modificationDate(let newestFirst):
                return !newestFirst
//            case .pageTitle(let aFirst):
//                return !aFirst
            case .urlString(let aFirst):
                return aFirst
//            case .tagCount(let mostFirst):
//                return !mostFirst
            case .archived(let archivedFirst):
                return !archivedFirst
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
