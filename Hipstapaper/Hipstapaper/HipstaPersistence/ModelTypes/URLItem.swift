//
//  URLItem.swift
//  Hipstapaper
//
//  Created by Jeffrey Bergier on 11/25/16.
//  Copyright © 2016 Jeffrey Bergier. All rights reserved.
//

import RealmSwift
import Foundation

protocol URLItemType {
    var realmID: String { get set }
    var cloudKitID: String { get set }
    var urlString: String { get set }
    var archived: Bool { get set }
    var tags: [TagItemType] { get set }
    var modificationDate: Date { get set }
}

enum URLItem {
    struct Value: URLItemType {
        var realmID: String
        var cloudKitID: String
        var urlString: String
        var archived: Bool
        var tags: [TagItemType]
        var modificationDate: Date
        
        init(realmID: String,
             cloudKitID: String,
             urlString: String,
             archived: Bool = false,
             tags: [TagItemType] = [],
             modificationDate: Date)
        {
            self.realmID = realmID
            self.cloudKitID = cloudKitID
            self.urlString = urlString
            self.archived = archived
            self.tags = tags
            self.modificationDate = modificationDate
        }
    }
}

extension URLItem.Value: Equatable {}
func ==(lhs: URLItem.Value, rhs: URLItem.Value) -> Bool {
    return lhs.realmID == rhs.realmID
}

extension URLItem.Value: Hashable {
    var hashValue: Int {
        return self.realmID.hashValue
    }
}

enum URLItemTypeComparison {
    case newer, older, same, notApplicable
}

extension URLItemType {
    func compare(with other: URLItemType) -> URLItemTypeComparison {
        guard self.cloudKitID == other.cloudKitID else { return .notApplicable }
        if self.urlString != other.urlString || self.archived != other.archived || self.tags.map({$0.name}) != other.tags.map({$0.name}) {
            if self.modificationDate >= other.modificationDate {
                return .newer
            } else {
                return .older
            }
        } else {
            return .same
        }
    }
}

extension Sequence where Iterator.Element == Result<URLItemType> {
    func mapSuccess() -> [URLItemType] {
        let items = self.map() { result -> URLItemType? in
            if case .success(let item) = result {
                return item
            }
            return .none
            }.filter({ $0 != nil }).map({ $0! })
        return items
    }
    func mapError() -> [Error] {
        let items = self.map() { result -> [Error]? in
            if case .error(let error) = result {
                return error
            }
            return .none
            }.filter({ $0 != nil }).map({ $0! }).flatMap({ $0 })
        return items
    }
}
