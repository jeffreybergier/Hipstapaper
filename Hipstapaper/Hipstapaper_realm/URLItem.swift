//
//  URLItem.swift
//  Hipstapaper
//
//  Created by Jeffrey Bergier on 12/20/16.
//  Copyright © 2016 Jeffrey Bergier. All rights reserved.
//

import RealmSwift

public protocol URLItemsToLoadChangeDelegate: class {
    var itemsToLoad: URLItem.ItemsToLoad { get }
    var filter: URLItem.ArchiveFilter { get }
    var sortOrder: URLItem.SortOrder { get }
    func didChange(itemsToLoad: URLItem.ItemsToLoad?, sortOrder: URLItem.SortOrder?, filter: URLItem.ArchiveFilter?, sender: ViewControllerSender)
}

public enum ViewControllerSender {
    case sourceListVC, contentVC, tertiaryVC
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

public extension URLItem {
    
    public enum ArchiveFilter: Int {
        case unarchived = 0, all
        
        public var keyPath: String {
            return #keyPath(URLItem.archived)
        }
        
        public static var count: Int {
            return 2
        }
        
        public var displayName: String {
            switch self {
            case .all:
                return "All"
            case .unarchived:
                return "Unarchived"
            }
        }
    }
}

public extension URLItem {

    public enum SortOrder: Int {
        case recentlyAddedOnTop = 0, recentlyAddedOnBottom, recentlyModifiedOnTop, recentlyModifiedOnBottom, urlAOnTop, urlZOnTop
        
        public var displayName: String {
            switch self {
            case .recentlyAddedOnTop:
                return "Recently Added on Top"
            case .recentlyAddedOnBottom:
                return "Recently Added on Bottom"
            case .recentlyModifiedOnTop:
                return "Recently Modified on Top"
            case .recentlyModifiedOnBottom:
                return "Recently Modified on Bottom"
            case .urlAOnTop:
                return "URL's with A on Top"
            case .urlZOnTop:
                return "URL's with Z on Top"
            }
        }
        
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
        
        private var ascending: Bool {
            switch self {
            case .recentlyAddedOnTop, .recentlyModifiedOnTop, .urlZOnTop:
                return false
            case .recentlyAddedOnBottom, .recentlyModifiedOnBottom, .urlAOnTop:
                return true
            }
        }
        
        func sort(results input: Results<URLItem>) -> Results<URLItem> {
            let keyPath = self.keyPath
            let ascending = self.ascending
            let output = input.sorted(byKeyPath: keyPath, ascending: ascending)
            return output
        }
        
        func sort(results input: LinkingObjects<URLItem>) -> Results<URLItem> {
            let keyPath = self.keyPath
            let ascending = self.ascending
            let output = input.sorted(byKeyPath: keyPath, ascending: ascending)
            return output
        }
        
        public static var count: Int {
            return 6
        }
    }
}

public extension URLItem {
    public enum ItemsToLoad {
        case all, tag(TagItem.UIIdentifier)
    }
}

extension URLItem.ItemsToLoad: Equatable { }

public func ==(lhs: URLItem.ItemsToLoad, rhs: URLItem.ItemsToLoad) -> Bool {
    switch lhs {
    case .all:
        if case .all = rhs { return true }
    case .tag(let lhsTag):
        if case .tag(let rhsTag) = rhs { return lhsTag.idName == rhsTag.idName }
    }
    
    return false
}

public extension URLItem {
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









