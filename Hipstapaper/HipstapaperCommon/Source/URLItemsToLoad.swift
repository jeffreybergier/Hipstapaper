//
//  URLItemsToLoad.swift
//  Pods
//
//  Created by Jeffrey Bergier on 1/29/17.
//
//

public extension URLItem {
    public enum ItemsToLoad {
        case all, tag(TagItem.UIIdentifier)
    }
}

extension URLItem.ItemsToLoad: Equatable { }

public func == (lhs: URLItem.ItemsToLoad, rhs: URLItem.ItemsToLoad) -> Bool {
    switch lhs {
    case .all:
        if case .all = rhs { return true }
    case .tag(let lhsTag):
        if case .tag(let rhsTag) = rhs { return lhsTag.idName == rhsTag.idName }
    }
    return false
}
