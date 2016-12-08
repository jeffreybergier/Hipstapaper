//
//  FrameworkExtensions.swift
//  Hipstapaper
//
//  Created by Jeffrey Bergier on 11/13/16.
//  Copyright © 2016 Jeffrey Bergier. All rights reserved.
//

import Foundation

extension Array where Element: Hashable {
    func deletedItems(from oldArray: Array<Element>) -> Array<Element>? {
        let oldSet = Set(oldArray)
        let selfSet = Set(self)
        let deleted = oldSet.subtracting(selfSet)
        return deleted.isEmpty == false ? Array(deleted) : .none
    }
    func addedItems(to oldArray: Array<Element>) -> Array<Element>? {
        let oldSet = Set(oldArray)
        let selfSet = Set(self)
        let added = selfSet.subtracting(oldSet)
        return added.isEmpty == false ? Array(added) : .none
    }
}
