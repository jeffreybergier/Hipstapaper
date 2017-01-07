//
//  URLItem.swift
//  Hipstapaper
//
//  Created by Jeffrey Bergier on 12/20/16.
//  Copyright © 2016 Jeffrey Bergier. All rights reserved.
//

import RealmSwift

public protocol URLItemSelectionDelegate: class {
    var currentSelection: URLItem.Selection? { get }
    func didSelect(_: URLItem.Selection, from: NSObject?)
}

public protocol URLItemsToLoadChangeDelegate: class {
    var itemsToLoad: URLItem.ItemsToLoad { get }
    var filter: URLItem.ArchiveFilter { get }
    var sortOrder: URLItem.SortOrderA { get }
    func didChange(itemsToLoad: URLItem.ItemsToLoad?, sortOrder: URLItem.SortOrderA?, filter: URLItem.ArchiveFilter?, sender: NSObject?)
}

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
    
    public enum ArchiveFilter: Int {
        case unarchived = 0, all
        
        var keyPath: String {
            return #keyPath(URLItem.archived)
        }
    }
    
    public enum SortOrderA: Int {
        case recentlyAddedOnTop = 2, recentlyAddedOnBottom = 3, recentlyModifiedOnTop = 4, recentlyModifiedOnBottom = 5, urlAOnTop = 6, urlZOnTop = 7
        
        var keyPath: String {
            switch self {
            case .recentlyAddedOnTop, .recentlyAddedOnBottom:
                return #keyPath(URLItem.creationDate)
            case .recentlyModifiedOnTop, .recentlyModifiedOnBottom:
                return #keyPath(URLItem.modificationDate)
            case .urlAOnTop, .urlZOnTop:
                return #keyPath(URLItem.urlString)
            }
        }
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

extension URLItem {
    
    public enum ItemsToLoad {
        case all, tag(TagItem.UIIdentifier)
    }
    
    public enum Selection {
        // TODO: Get the actual tag object out of this selection, just store the display name and the ID
        case unarchived, all, tag(TagItem.UIIdentifier)
    }
}

extension URLItem.Selection: Equatable { }

public func ==(lhs: URLItem.Selection, rhs: URLItem.Selection) -> Bool {
    switch lhs {
    case .unarchived:
        if case .unarchived = rhs { return true }
    case .all:
        if case .all = rhs { return true }
    case .tag(let lhsTag):
        if case .tag(let rhsTag) = rhs { return lhsTag.idName == rhsTag.idName }
    }
    
    return false
}

extension URLItem {
    public struct UIIdentifier {
        var uuid: String
        var urlString: String
        var archived: Bool
    }
}

extension URLItem.UIIdentifier: Hashable {
    public var hashValue: Int {
        return self.uuid.hashValue
    }
}

public func ==(lhs: URLItem.UIIdentifier, rhs: URLItem.UIIdentifier) -> Bool {
    return lhs.hashValue == rhs.hashValue
}









