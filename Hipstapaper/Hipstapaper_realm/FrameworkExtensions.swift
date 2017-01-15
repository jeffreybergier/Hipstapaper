//
//  FrameworkExtensions.swift
//  Hipstapaper
//
//  Created by Jeffrey Bergier on 1/15/17.
//  Copyright © 2017 Jeffrey Bergier. All rights reserved.
//

import Foundation

extension UserDefaults {
    
    private enum Keys {
        fileprivate static let sortOrder = "kSortOrderKey"
        fileprivate static let filter = "kFilterKey"
        fileprivate static let tagDisplayName = "kTagDisplayNameKey"
        fileprivate static let tagUniqueName = "kTagUniqueNameKey"
    }
    
    var currentSelection: (itemsToLoad: URLItem.ItemsToLoad?, sortOrder: URLItem.SortOrder?, filter: URLItem.ArchiveFilter?) {
        get {
            let sortValue = (self.value(forKey: Keys.sortOrder) as? NSNumber)?.intValue ?? -1
            let filterValue = (self.value(forKey: Keys.filter) as? NSNumber)?.intValue ?? -1
            let tagDisplayName = self.value(forKey: Keys.tagDisplayName) as? String
            let tagUniqueName = self.value(forKey: Keys.tagUniqueName) as? String
            let sort = URLItem.SortOrder(rawValue: sortValue)
            let filter = URLItem.ArchiveFilter(rawValue: filterValue)
            let itemsToLoad: URLItem.ItemsToLoad
            if let tagDisplayName = tagDisplayName, let tagUniqueName = tagUniqueName {
                itemsToLoad = .tag(TagItem.UIIdentifier(idName: tagUniqueName, displayName: tagDisplayName))
            } else {
                itemsToLoad = .all
            }
            return (itemsToLoad: itemsToLoad, sortOrder: sort, filter: filter)
        }
        set {
            let sortNumber = NSNumber(integerLiteral: newValue.sortOrder?.rawValue ?? -1)
            let filterNumber = NSNumber(integerLiteral: newValue.filter?.rawValue ?? -1)
            self.set(sortNumber, forKey: Keys.sortOrder)
            self.set(filterNumber, forKey: Keys.filter)
            if let itemsToLoad = newValue.itemsToLoad, case .tag(let tagID) = itemsToLoad {
                self.set(tagID.displayName, forKey: Keys.tagDisplayName)
                self.set(tagID.idName, forKey: Keys.tagUniqueName)
            } else {
                self.set(nil, forKey: Keys.tagDisplayName)
                self.set(nil, forKey: Keys.tagUniqueName)
            }
        }
    }
}
