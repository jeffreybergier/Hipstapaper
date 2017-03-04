//
//  URLItemUIIdentifier.swift
//  Pods
//
//  Created by Jeffrey Bergier on 1/29/17.
//
//

public extension URLItem {
    public struct UIIdentifier {
        public var uuid: String
        public var urlString: String
        public var archived: Bool
        
        public init(uuid: String, urlString: String, archived: Bool) {
            self.uuid = uuid
            self.urlString = urlString
            self.archived = archived
        }
    }
}

extension URLItem.UIIdentifier: Hashable {
    public var hashValue: Int {
        return self.uuid.hashValue
    }
}

public func == (lhs: URLItem.UIIdentifier, rhs: URLItem.UIIdentifier) -> Bool {
    return lhs.hashValue == rhs.hashValue
}
