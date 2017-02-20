//
//  URLItemSortOrder.swift
//  Pods
//
//  Created by Jeffrey Bergier on 1/29/17.
//
//

import RealmSwift

public extension URLItem {
    
    public enum SortOrder: Int {
        
        case recentlyAddedOnTop = 0, recentlyAddedOnBottom,
        recentlyModifiedOnTop, recentlyModifiedOnBottom,
        pageTitleAOnTop, pageTitleZOnTop,
        urlAOnTop, urlZOnTop,
        unarchivedOnTop, archivedOnTop
        
        public static var count: Int {
            return 10
        }
        
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
            case .archivedOnTop:
                return "Archived on Top"
            case .unarchivedOnTop:
                return "Unarchived on Top"
            case .pageTitleAOnTop:
                return "Page Titles with A on Top"
            case .pageTitleZOnTop:
                return "Page Titles with Z on Top"
            }
        }
        
        internal var keyPath: String {
            switch self {
            case .recentlyAddedOnTop, .recentlyAddedOnBottom:
                return #keyPath(URLItem.creationDate)
            case .recentlyModifiedOnTop, .recentlyModifiedOnBottom:
                return #keyPath(URLItem.modificationDate)
            case .urlAOnTop, .urlZOnTop:
                return #keyPath(URLItem.urlString)
            case .archivedOnTop, .unarchivedOnTop:
                return #keyPath(URLItem.archived)
            case .pageTitleAOnTop, .pageTitleZOnTop:
                return #keyPath(URLItem.extras.pageTitle)
            }
        }
        
        internal var ascending: Bool {
            switch self {
            case .recentlyAddedOnTop, .recentlyModifiedOnTop, .urlZOnTop, .archivedOnTop, .pageTitleZOnTop:
                return false
            case .recentlyAddedOnBottom, .recentlyModifiedOnBottom, .urlAOnTop, .unarchivedOnTop, .pageTitleAOnTop:
                return true
            }
        }
    }
}
